# Usage

This model uses large models. You need to use this script via qsub.

```
echo "/home/ws15gkumar/work/experiments/lorelei/mt_pipe/tr_en/run.sh -s [SOURCE] -o [OUTPUT]" \
  | qsub -l mem_free=40G,ram_free=40G -e [LOG_FILE]```
```

eg.

```
echo "~/work/experiments/lorelei/mt_pipe/tr_en/run.sh \
  -s ~/work/experiments/lorelei/mt_pipe/tr_en/input.tr \
  -o ~/work/experiments/lorelei/mt_pipe/tr_en/out.en -a" \
  | qsub -l mem_free=40G,ram_free=40G -e ~/work/experiments/lorelei/mt_pipe/tr_en/log/tr.err`
```
