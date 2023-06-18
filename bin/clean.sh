#!/bin/bash

# Define the list of violating words
violating_words=("gorilla" "spider" "bonobo")

# Function to remove violating, blank, and duplicate lines from a file
clean_file() {
    file="$1"
    temp_file=$(mktemp)

    # Remove violating lines
    for word in "${violating_words[@]}"; do
        sed -i "/\b$word\b/d" "$file"
    done

    # Remove blank lines
    sed -i '/^\s*$/d' "$file"

    # Remove duplicate lines
    awk '!seen[$0]++' "$file" > "$temp_file"
    mv "$temp_file" "$file"
}

# Function to count the number of lines in a file
count_lines() {
    file="$1"
    line_count=$(wc -l < "$file")
    echo "$line_count"
}

# Clean and test each file in the data directory
for file in data/*; do
    clean_file "$file"
    line_count=$(count_lines "$file")

    if [ "$line_count" -eq 500 ]; then
        echo "$file: complete"
    elif [ "$line_count" -lt 500 ]; then
        echo "$file: incomplete"
    else
        echo "$file: error: over fill"
    fi
done
