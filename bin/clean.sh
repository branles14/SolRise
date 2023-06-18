#!/bin/bash

# Define the list of violating words
violating_words=("word1" "word2" "word3")

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

# Clean each file in the data directory
for file in data/*; do
    clean_file "$file"
done

echo "done"
exit 0
