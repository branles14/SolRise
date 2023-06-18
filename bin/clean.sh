#!/bin/bash

clean_file() {
  local file="$1"
  local temp_file=$(mktemp)
  local violating_words=("gorilla" "spider" "bonobo")

  # Remove violating lines, incomplete lines, blank lines in a single sed command
  sed -E -e "/\\b($(IFS='|'; echo "${violating_words[*]}"))\\b/d" \
         -e '/^[^[:upper:]]/d; /[^.?!]$/d; /^\s*$/d' \
         "$file" > "$temp_file"

  # Remove duplicate lines
  awk '!seen[$0]++' "$temp_file" > "$file"
  rm "$temp_file"
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

generate_readme() {
  local dir="data"
  local readme_file="$dir/README.md"

  # Header for the README
  cat > "$readme_file" <<EOF
# Data Directory

This directory contains the following text files:

EOF

  # Generate file information
  for file in "$dir"/*.txt; do
    local filename=$(basename "$file")
    local line_count=$(wc -l < "$file")
    local file_info=""

    if [ "$line_count" -eq 500 ]; then
      file_info="Status: Complete"
    elif [ "$line_count" -lt 500 ]; then
      file_info="Status: Incomplete"
    else
      file_info="Status: Reduced to 500 lines"
    fi

    # Append file information to README
    cat >> "$readme_file" <<EOF

## $filename

- Lines: $line_count
- $file_info
EOF
  done
}

main() {
  local dir="data"

  if [[ ! -d "$dir" ]] || [[ -z "$(ls -A "$dir")" ]]; then
    echo "Either directory $dir does not exist or is empty."
    exit 1
  fi

  local files=("$dir"/*)
  if [ ${#files[@]} -eq 0 ]; then
    echo "No files found in $dir."
    exit 1
  fi

  for file in "${files[@]}"; do
    clean_file "$file"
    local line_count
    line_count=$(wc -l < "$file") || { echo "Failed to count lines."; exit 1; }

    if [ "$line_count" -eq 500 ]; then
      echo "$file: complete"
    elif [ "$line_count" -lt 500 ]; then
      echo "$file: incomplete"
    else
      reduce_lines "$file" "$line_count"
      echo "$file: reduced to 500 lines"
    fi
  done

  generate_readme
}

main "$@"
