#!/bin/bash

#First argument is the file
#Second argument is the number of lines to display on each end

file="$1"

# Check if the second argument is provided; if not, default to 3
if [[ -z "$2" ]]; then
    lines=3
else
    lines="$2"
fi

total_lines=$(grep -c "" "$file")

# Determine whether to display the full content or partial content
if (( total_lines <= 2*lines )); then
    # Display the full content if the file has 2X lines or less
    cat "$file"
else
    echo "Warning: File is longer than $((2*lines)) lines."
    first_lines=$(head -n "$lines" "$file")
    last_lines=$(tail -n "$lines" "$file")
    echo "$first_lines"
    echo "..."
    echo "$last_lines"
fi


