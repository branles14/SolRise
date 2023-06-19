#!/bin/bash

build_example() {
    local msg_1
    local msg_2
    local msg_3
    local msg_4

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
    for i in {1..4}; do
        if [[ ! -f "data/$i.txt" || $(wc -l < "data/$i.txt") -lt 500 ]]; then
            echo "Error: 'data/$i.txt' either doesn't exist or contains less than 500 lines."
            exit 1
        fi
    done

    # Generate 'data/train.txt'
    while [[ $(wc -l < "data/train.txt") -lt 10000 ]]; do
        build_example >> "data/train.txt"
        sort -u -o "data/train.txt" "data/train.txt"
    done
}

main
