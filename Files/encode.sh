#!/bin/bash

touch /config/files.txt
output_format=mkv
parameters="-c:v hevc_nvenc -c:a copy"

while getopts i:o: option; do
  case $option in
    i) input_dir=$OPTARG;;
    o) output_dir=$OPTARG;;
    *) echo "usage: $0 [-v] [-r]" >&2
      exit 1 ;;
esac
done

eval processes=( $(ps aux | grep -i "ffmpeg -i" | awk '{print $11}') )
should_start_new_encode=true

IN="$parameters"
arrIN=(${IN//;/ })

function loop() {

  shopt -s nullglob
  shopt -s globstar

  for file in "$input_dir"/**
  do
  file_name="${file##*/}" #cabc.def
  echo "$file_name"
  short_file="$(basename "${file%.*}")" #cabc
  folder_path="${file%/*}" #/home
  file_trim="$(echo -e "$file_name" | tr -d '[:space:]')"
  completed_trim=$(</config/files.txt)
  completed_trim="$(echo -e "$completed_trim" | tr -d '[:space:]')"

  ## If $file is a file
  if [ -f "$file" ] ;then
        if grep -Fq "$file_trim" /config/files.txt ;then
                echo "Allready exists in files.txt"
                # move_original
        else    
                  start_encode
                  update_file
        fi
  else
  echo "Not a file."
  fi
done
}

start_encode(){
  ffmpeg -n -i "$file" \
  "${arrIN[@]}" \
  "$output_dir"/"$short_file"."$output_format" \
  > /dev/stdout 
 # >> /config/log/ffmpeg.log 2>&1
}

update_file(){
  echo "Updating files.txt"
  echo $file_trim >> /config/files.txt
}

process_check(){
  for i in $processes; do
    if [ $i == "ffmpeg" ] ;then
      should_start_new_encode=false
      echo 'ffmpeg is already running'
    fi 
  done
}

# move_original(){
  # echo "Moving file to /copy folder..."
  # mv "$file" "$move_source_dir"/"$file_name"
  # loop "$input_dir"
# }

echo `date +"%Y-%m-%d-%T"`
process_check
if [ $should_start_new_encode == "true" ] ; then
  loop "$input_dir"
fi