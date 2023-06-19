#!/bin/bash

build_example() {
  local msg_1 msg_2 msg_3 msg_4

  while [[ -z $msg_1 || -z $msg_2 || -z $msg_3 || -z $msg_4 ]]; do
    msg_1=$(shuf -n 1 data/1.txt)
    msg_2=$(shuf -n 1 data/2.txt)
    msg_3=$(shuf -n 1 data/3.txt)
    msg_4=$(shuf -n 1 data/4.txt)
  done

  echo "<|first|>$msg_1<|second|>$msg_2<|third|>$msg_3<|forth|>$msg_4<|endoftext|>"
}

main() {
  # Error checks
  if [[ ! -f "data/1.txt" || ! -f "data/2.txt" || ! -f "data/3.txt" || ! -f "data/4.txt" ]]; then
    echo "Error: One or more data files are missing."
    exit 1
  elif [[ $(wc -l < data/1.txt) -lt 500 || $(wc -l < data/2.txt) -lt 500 || $(wc -l < data/3.txt) -lt 500 || $(wc -l < data/4.txt) -lt 500 ]]; then
    echo "Error: One or more data files have less than 500 lines."
    exit 1
  fi

  # Generate examples and output to data/train.txt
  while [[ $(wc -l < data/train.txt) -lt 100000 ]]; do
    build_example >> data/train.txt
    sort -u -o data/train.txt data/train.txt
  done

  # Shuffle lines in data/train.txt
  shuf -o data/train.txt data/train.txt
}

main
echo "Done"
exit 0
