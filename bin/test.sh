#!/bin/bash

# Function to count the number of lines in a file
count_lines() {
    file="$1"
    line_count=$(wc -l < "$file")
    echo "$line_count"
}

# Test each file in the data directory
for file in data/*; do
    line_count=$(count_lines "$file")

    if [ "$line_count" -eq 500 ]; then
        echo "$file: complete"
    elif [ "$line_count" -lt 500 ]; then
        echo "$file: incomplete"
    else
        echo "$file: error: over fill"
    fi
done

echo "done"
exit 0
