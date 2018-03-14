#!/usr/bin/env bash

# Measures BLEU across the following settings
# 1. Baseline; no changes to ref or output
# 2. After removing special tokens
# 3. Lowercased

UNIQ_RUN_NUM=`date '+%Y%m%d%H%M%S'`
TMP=/export/b09/ws15gkumar/experiments/lorelei/mt_pipe/scripts/tmp

MOSES=/home/pkoehn/moses
ASR_TAGS_IN_OUTPUT=true
ASR_TAGS_IN_REF=true

output_dir=/export/a05/mahsay/MATERIAL/t2/ANALYSIS1/1A
output=${output_dir}/ANALYSIS1.1A.full.txt.en
#output=${output_dir}/out.segmented_1000ms.concat.en
reference=${output_dir}/reference.txt

if $ASR_TAGS_IN_REF; then
  cat $reference | awk '{$1=""; print $0}' | sed 's: *::' > ${TMP}/${UNIQ_RUN_NUM}.ref
  reference=${TMP}/${UNIQ_RUN_NUM}.ref
fi

if $ASR_TAGS_IN_OUTPUT; then
  cat $output | awk '{$1=""; print $0}' | sed 's: *::' > ${TMP}/${UNIQ_RUN_NUM}.out
  output=${TMP}/${UNIQ_RUN_NUM}.out
fi

# Remove speech events
cat $reference | sed 's:%incomplete::g' | sed 's:(())::g' | sed 's:--::g' \
  | sed 's:<no-speech>::g' | sed 's:<misc>::g' | sed 's:*::g' \
  | sed 's:^ *::g' | sed 's: *$::g' | sed 's:  *: :g' \
  > ${TMP}/${UNIQ_RUN_NUM}.ref.no_speech
reference_no_speech=${TMP}/${UNIQ_RUN_NUM}.ref.no_speech

cat $output | sed 's:<noise>::g' | sed 's:<sil>::g' | sed 's:<spnoise>::g' \
  | sed 's:^ *::g' | sed 's: *$::g' | sed 's:  *: :g' \
  > ${TMP}/${UNIQ_RUN_NUM}.out.no_speech
output_no_speech=${TMP}/${UNIQ_RUN_NUM}.out.no_speech

cat $reference_no_speech | sed 's:mmhm ::g' | sed 's:mm ::g'  \
  | sed 's:\. \. \. \.:.:g' | sed 's:\. \. \.:.:g' | sed 's:\. \.:.:g' | sed 's:? ?:.:g' \
  | sed 's:^\. *::g' | sed 's:^? *::g' \
  | sed 's:^ *::g' | sed 's: *$::g' | sed 's:  *: :g' \
  > ${TMP}/${UNIQ_RUN_NUM}.ref.no_hes
reference_no_hes=${TMP}/${UNIQ_RUN_NUM}.ref.no_hes

cat $output_no_speech | sed 's:mmhm ::g' | sed 's:mm ::g' \
  | sed 's:\. \. \. \.:.:g' | sed 's:\. \. \.:.:g' | sed 's:\. \.:.:g' | sed 's:? ?:.:g' \
  | sed 's:^\. *::g' | sed 's:^? *::g' \
  | sed 's:^ *::g' | sed 's: *$::g' | sed 's:  *: :g' \
  > ${TMP}/${UNIQ_RUN_NUM}.out.no_hes
output_no_hes=${TMP}/${UNIQ_RUN_NUM}.out.no_hes

cat $reference_no_hes | tr -d '[:punct:]' > ${TMP}/${UNIQ_RUN_NUM}.ref.no_punct
reference_no_punct=${TMP}/${UNIQ_RUN_NUM}.ref.no_punct
cat $output_no_hes | tr -d '[:punct:]' > ${TMP}/${UNIQ_RUN_NUM}.out.no_punct
output_no_punct=${TMP}/${UNIQ_RUN_NUM}.out.no_punct

$MOSES/scripts/generic/multi-bleu.perl $reference < $output
$MOSES/scripts/generic/multi-bleu.perl -lc $reference < $output
$MOSES/scripts/generic/multi-bleu.perl $reference_no_speech < $output_no_speech
$MOSES/scripts/generic/multi-bleu.perl -lc $reference_no_speech < $output_no_speech
$MOSES/scripts/generic/multi-bleu.perl $reference_no_hes < $output_no_hes
$MOSES/scripts/generic/multi-bleu.perl -lc $reference_no_hes < $output_no_hes
$MOSES/scripts/generic/multi-bleu.perl $reference_no_punct < $output_no_punct
$MOSES/scripts/generic/multi-bleu.perl -lc $reference_no_punct < $output_no_punct
