#!/bin/bash

clean_file() {
  local file="$1"
  local temp_file=$(mktemp)
  local violating_words=("gorilla" "spider" "bonobo" "baboon" "orangutan" "lemur")

  # Remove violating lines, incomplete lines & blank lines
  sed -E -e "/\\b($(IFS='|'; echo "${violating_words[*]}"))\\b/d" \
         -e '/^[^[:upper:]]/d; /[^.?!]$/d; /^\s*$/d' \
         "$file" > "$temp_file"

  # Remove duplicate lines
  awk '!seen[$0]++' "$temp_file" > "$file" && rm "$temp_file"
}

reduce_lines() {
  local file="$1"
  local line_count="$2"

  while [ "$line_count" -gt 500 ]; do
    local shortest_line=$(awk '{ print length, NR }' "$file" | sort -n | awk 'NR == 1 { print $2 }')
    head -n $((shortest_line - 1)) "$file" > "$file.tmp"
    tail -n +"$((shortest_line + 1))" "$file" >> "$file.tmp"
    mv "$file.tmp" "$file"
    line_count=$(wc -l < "$file")
  done
}

shuffle_lines() {
  local file="$1"
  local temp_file=$(mktemp)
  shuf "$file" > "$temp_file"
  mv "$temp_file" "$file"
}

main() {
  # Error checks
  if [[ ! -d "data" ]]; then
    echo "Error: Missing dir: data"
    exit 1
  elif [[ -z "$(ls -A "data")" ]]; then
    echo "Error: Empty dir: data"
    exit 1
  fi

  # Start README file
  echo "# Data Directory" > "data/README.md"

  # Process data files
  for file in data/*.txt; do
    echo "## $(basename "$file")" >> "data/README.md"
    clean_file "$file"
    local line_count
    line_count=$(wc -l < "$file") || { echo "Failed to count lines."; exit 1; }
    if [[ "$line_count" -eq 500 ]]; then
      shuffle_lines "$file"
      echo "- Lines: $line_count" >> "data/README.md"
      echo "- Status: Complete" >> "data/README.md"
    elif [[ "$line_count" -lt 500 ]]; then
      echo "- Lines: $line_count" >> "data/README.md"
      echo "- Status: Incomplete" >> "data/README.md"
    else
      reduce_lines "$file" "$line_count"
      echo "- Lines: 500" >> "data/README.md"
      echo "- Status: Complete [Reduced]" >> "data/README.md"
    fi
  done
}

main "$@"
