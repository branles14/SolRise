#!/bin/bash
violating_words=("gorilla" "spider" "bonobo")

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

count_lines() {
  file="$1"
  line_count=$(wc -l < "$file")
  echo "$line_count"
}

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
