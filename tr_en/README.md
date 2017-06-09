# Introduction

MT pipeline for Turkish-English translation

# Usage

```
usage: run.sh [-h] -s SOURCE -o OUTPUT [-n N] [-a] [-d]
-s SOURCE : The source document to translate
-o OUTPUT : The file which will contain the translations
-n N : (Optional) If you want an n-best file, specify n here
-a : (Optional) Treat the first column of the SOURCE as sentenceIDs; dont't translate
-d : (Optional) Drop OOVs
```

This model uses large models. You need to submit this script via qsub.

```
echo "/export/b09/ws15gkumar/experiments/lorelei/mt_pipe/tr_en/run.sh -s [SOURCE] -o [OUTPUT] -a -d" \
  | qsub -l mem_free=40G,ram_free=40G -e [LOG_FILE]```
```

eg.

```
echo "/export/b09/ws15gkumar/experiments/lorelei/mt_pipe/tr_en/run.sh \
  -s ~/work/experiments/lorelei/mt_pipe/tr_en/input.tr \
  -o ~/work/experiments/lorelei/mt_pipe/tr_en/out.en \
<<<<<<< HEAD
  -a -d" \
  | qsub -l mem_free=40G,ram_free=40G -e ~/work/experiments/lorelei/mt_pipe/tr_en/log/tr.err`
=======
  -a" \
  | qsub -l mem_free=40G,ram_free=40G -e ~/work/experiments/lorelei/mt_pipe/tr_en/log/tr.err
>>>>>>> 523e3f29591154579893236dc83fd27aa1f581e0
```
