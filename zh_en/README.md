# Introduction

MT pipeline for Mandarin-English translation

# Usage

```
usage: run.sh [-h] -s SOURCE -o OUTPUT [-n N] [-a] [-d]
-s SOURCE : The source document to translate
-o OUTPUT : The file which will contain the translations
-n N : (Optional) If you want an n-best file, specify n here
-a : (Optional) Treat the first column of the SOURCE as sentenceIDs; dont't translate
-d : (Optional) Drop OOVs
```
eg.

```
/export/b09/ws15gkumar/experiments/lorelei/mt_pipe/zh_en/run.sh \
  -s /export/b04/cliu1/kaldi-trunk/egs/babel/s5c-105-turkish-fullLP/data/CHN_DEV_20160831/decode_audio.sgmm/forMT/decode_lm12.txt-eval-mt \
  -o out.zh \
  -a -d
```
