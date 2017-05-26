# Introduction

MT pipeline for Turkish-English translation

# Usage

```
usage: run.sh [-h] -s SOURCE -o OUTPUT [-n N] [-a]
```

This model uses large models. You need to submit this script via qsub.

```
echo "/export/b09/ws15gkumar/experiments/lorelei/mt_pipe/tr_en/run.sh -s [SOURCE] -o [OUTPUT] -a" \
  | qsub -l mem_free=40G,ram_free=40G -e [LOG_FILE]
```

eg.

```
echo "/export/b09/ws15gkumar/experiments/lorelei/mt_pipe/tr_en/run.sh \
  -s ~/work/experiments/lorelei/mt_pipe/tr_en/input.tr \
  -o ~/work/experiments/lorelei/mt_pipe/tr_en/out.en \
  -a" \
  | qsub -l mem_free=40G,ram_free=40G -e ~/work/experiments/lorelei/mt_pipe/tr_en/log/tr.err
```
