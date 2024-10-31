#!/bin/bash

# Loop through each provided argument (file)
for file in "$@";do
    line_count=$(grep -c "" "$file")
    file_name=$(basename "$file")
    
    # Print the file name and line count
    echo "File: $file_name"
    
    # Differentiate cases based on the number of lines
    if (( line_count == 0 )); then
      echo "The file is empty."
    elif (( line_count == 1 )); then
      echo "The file contains one line."
    else
      echo "The file contains $line_count lines."
    fi
    echo ""
done


