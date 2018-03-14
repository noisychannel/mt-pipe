#!/usr/bin/bash

ASR_output='/export/a05/mahsay/MATERIAL/s1/ANALYSIS1/1A/full.txt'
MT_ref='/export/a05/mahsay/MATERIAL/t1/ANALYSIS1/1A/reference.txt'
MT_out='/export/a05/mahsay/MATERIAL/t1/ANALYSIS1/1A/full.txt'

clear

for tag in `cat ${MT_ref} | awk '{print $1}'`;
do
  grep $tag $ASR_output $MT_ref $MT_out
  read
  clear
done
