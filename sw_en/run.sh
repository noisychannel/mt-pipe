#!/bin/bash
#
# Uses a pre-trained MT model to decode a test set
# For Turkish-Engligh
#
# gkumar@cs.jhu.edu

OPTIND=1
UNIQ_RUN_NUM=`date '+%Y%m%d%H%M%S'`

MOSES=/home/pkoehn/moses
PIPE_HOME=/export/b09/ws15gkumar/experiments/lorelei/mt_pipe/sw_en
MODEL_DIR=$PIPE_HOME/model
TMP_DIR=$PIPE_HOME/tmp

#####################################################################
# Model definition
#####################################################################

INI=/home/pkoehn/experiment/material-sw-en/tuning/moses.ini.1
SOURCE_TC_MODEL=/home/pkoehn/experiment/material-sw-en/truecaser/truecase-model.1.sw

#####################################################################
# Utility functions
#####################################################################

function errcho() {
  >&2 echo $1
}

function clean_exit() {
  errcho $1
  rm $MODEL_DIR/moses.ini 2> /dev/null
  exit 1
}

function check_file_exists() {
  if [ ! -f $1 ]; then
    clean_exit "FATAL: Could not find $1"
  fi
}

function show_help() {
  errcho "MT pipeline for SW-EN translation"
  errcho "usage: run.sh [-h] -s SOURCE -o OUTPUT [-n N] [-a] [-d]"
}

#####################################################################
# User supplied args
#####################################################################

# N-best N
N=1
SOURCE=""
OUTPUT=""
ASR_CTM_INPUT=false
DROP_UNK=false

local_INI=$MODEL_DIR/moses.ini

while getopts ":h?s:o:n:ad" opt; do
  case "$opt" in
  h|\?)
    show_help
    exit 0
    ;;
  s)  SOURCE=$OPTARG
    ;;
  o)  OUTPUT=$OPTARG
    ;;
  n)  N=$OPTARG
    ;;
  a)  ASR_CTM_INPUT=true
    ;;
  d)  DROP_UNK=true
    ;;
  esac
done

if [ -z $SOURCE ] || [ -z $OUTPUT ]; then
  errcho "Missing arguments"
  show_help
  exit 1
fi

errcho "Checking if source file exists"
check_file_exists $SOURCE
errcho "Done checking if the source file exists"

#####################################################################
# Optimize models (only once per model)
#####################################################################

errcho "Starting with INI file at $INI"
if [ ! -f $MODEL_DIR/moses.ini ]; then
  cp $INI $MODEL_DIR/moses.ini

  # Number of features in the phrase table
  N_PT_SCORES=`grep PhraseDictionary $INI | grep num-features | sed 's/.*num-features=\([[:digit:]]*\).*/\1/'`
  errcho "Phrase table has $N_PT_SCORES features"

  # Convert Phrase table to minphr format
  # Make sure you don't regenerate it if it already exists
  # and the input phrase table has not changed
  if grep -Fq "PhraseDictionaryMemory" $INI; then
    # We need to binarize
    diskPT=`grep "PhraseDictionaryMemory" $INI | sed -e 's/.*path=\([^ ]*\).*/\1/g' | sed s:.bin::`
    diskPT="${diskPT}.gz"
    check_file_exists $diskPT
    errcho "Disk based phrase table found at $diskPT";

    out_min_PT=$MODEL_DIR/`basename $diskPT | sed 's:.gz::'`
    errcho "Looking for a min phrase table at $out_min_PT"

    if [ ! -f ${out_min_PT}.minphr ]; then
      errcho "Did not find the min phrase table. Creating it."
      gzip -cd $diskPT \
        | LC_ALL=C sort --compress-program gzip -T $TMP_DIR \
        | gzip - > ${out_min_PT}.sorted.gz
      $MOSES/bin/processPhraseTableMin -in ${out_min_PT}.sorted.gz \
        -out ${out_min_PT}.minphr -nscores $N_PT_SCORES -threads 1
      rm ${out_min_PT}.sorted.gz
      # Record this in our local moses.ini
      sed -i 's:PhraseDictionaryMemory:PhraseDictionaryCompact:' $local_INI
      sed -i "s:\(PhraseDictionaryCompact.*path=\)\([^ ]*\)\(.*\):\1${out_min_PT}\3:g" $local_INI
    else
      errcho "Found a min phrase table at ${out_min_PT}.minphr. Using that."
    fi
  else
    errcho "Binary table found. Using that."
  fi

  # Convert Lexical translation table to minphr format
  # Make sure you don't regenerate it if it already exists
  # and the input phrase table has not changed
  echo "****************************************"
  lexT=`grep "LexicalReordering" $INI | grep path | sed -e 's/.*path=\([^ ]*\).*/\1/g'`
  errcho "Looking for a lexical translation table at ${lexT}.minlexr"
  if [ ! -f ${lexT}.minlexr ]; then
    errcho "Did not find the min lexical translation table at the exp dir."

    out_min_LT=$MODEL_DIR/`basename $lexT`
    if [ ! -f ${out_min_LT}.minlexr ]; then
      errcho "Did not find the min lexical translation table at ${out_min_LT}. Creating it"
      check_file_exists $lexT

      gzip -cd $lexT \
        | LC_ALL=C sort --compress-program gzip -T $TMP_DIR \
        | gzip - > ${out_min_LT}.sorted.gz
      $MOSES/bin/processLexicalTableMin -in ${out_min_LT}.sorted.gz \
        -out ${out_min_LT}.minlexr -threads 1
      rm ${out_min_LT}.sorted.gz
      # Record this in our local moses.ini
      sed -i "s:\(LexicalReordering.*path=\)\([^ ]*\)\(.*\):\1${out_min_LT}\3:g" $local_INI
    else
        errcho "Found a min lex table at ${out_min_LT}.minlexr. Using that."
    fi
  fi
else
  errcho "Found local INI file at $MODEL_DIR/moses.ini. Using that."
fi

#####################################################################
# Pre-process input file
#####################################################################
# Remove ASR seg IDs if they exist
INPUT=$SOURCE
if [ "$ASR_CTM_INPUT" = true ]; then
  cat $SOURCE | cut -d' ' '-f1' > $TMP_DIR/${UNIQ_RUN_NUM}.input.ctm_tags
  cat $SOURCE | cut -d' ' '-f2-' > $TMP_DIR/${UNIQ_RUN_NUM}.input
  INPUT=$TMP_DIR/${UNIQ_RUN_NUM}.input
fi

# Normalize punctuation and tokenize input
$MOSES/scripts/tokenizer/normalize-punctuation.perl tr < $INPUT \
  | $MOSES/scripts/tokenizer/tokenizer.perl -a -l tr  > ${INPUT}.tok

# Truecase
$MOSES/scripts/recaser/truecase.perl -model $SOURCE_TC_MODEL \
  < ${INPUT}.tok > ${INPUT}.tc

INPUT=${INPUT}.tc

#####################################################################
# Decode
#####################################################################

n_best_cmd=""
if [ $N -gt 1 ]; then
  n_best_cmd="-n-best-list output.best$N $N"
fi


drop_unk_cmd=""
if [ "$DROP_UNK" = true ]; then
  drop_unk_cmd="-drop-unknown"
fi

$MOSES/bin/moses.2016-08-22 -search-algorithm 1 -cube-pruning-pop-limit 5000 -s 5000 \
  -threads 6 -text-type "test" -v 0 -f  $local_INI \
  $n_best_cmd $drop_unk_cmd \
  < $INPUT > $TMP_DIR/${UNIQ_RUN_NUM}.output


#####################################################################
# Post-process
#####################################################################

# Remove markup
$MOSES/scripts/ems/support/remove-segmentation-markup.perl \
  < $TMP_DIR/${UNIQ_RUN_NUM}.output \
  > $TMP_DIR/${UNIQ_RUN_NUM}.output.cleaned

# De-truecase output
${MOSES}/scripts/recaser/detruecase.perl \
  < $TMP_DIR/${UNIQ_RUN_NUM}.output.cleaned \
  > $TMP_DIR/${UNIQ_RUN_NUM}.output.truecased

# De-tokenize output
$MOSES/scripts/tokenizer/detokenizer.perl -l en \
  < $TMP_DIR/${UNIQ_RUN_NUM}.output.truecased \
  > $TMP_DIR/${UNIQ_RUN_NUM}.output.detokenized

# Add CTM tags if ASR output
if [ "$ASR_CTM_INPUT" = true ]; then
  paste -d ' ' $TMP_DIR/${UNIQ_RUN_NUM}.input.ctm_tags $TMP_DIR/${UNIQ_RUN_NUM}.output.detokenized \
    > $OUTPUT
else
  cp $TMP_DIR/${UNIQ_RUN_NUM}.output.detokenized $OUTPUT
fi

# Cleanup
rm $TMP_DIR/${UNIQ_RUN_NUM}.*
