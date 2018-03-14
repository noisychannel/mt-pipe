import sys

seg_file = open(sys.argv[1])
line = seg_file.readline()
line = line.replace('\n','')
cols = line.split(" ")
prev_audio_id = cols[0]
concat = prev_audio_id
for col in cols[1:]:
  concat = concat + " " + col
for line in seg_file:
  line = line.replace('\n','')
  cols = line.split(" ")
  #print cols
  cur_audio_id = cols[0]
  if cur_audio_id == prev_audio_id:
    for col in cols[1:]:
      if len(col) > 1:
        concat = concat + " " + col
  else:
    concat = concat + "\n" + cur_audio_id
    for col in cols[1:]:                                                        
      if len(col) > 1:                                                          
        concat = concat + " " + col 
    prev_audio_id = cur_audio_id
print concat