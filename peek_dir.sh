#!/bin/bash

#First argument is the direcotry

directory="$1"

find "$directory" -type f -name "*txt" | while read i; do
  lines=$(grep -c "" "$i")
  
  if (( lines <= 20 )); then
     echo ">>>>>>>>>>>>>>>>>>> File $i"
     cat $i
  else
   echo ">>>>>>>>>>>>>>>>>>>>Warning: File $i is longer than 20 lines."
    first_lines=$(head -n "$lines" "$i")
    last_lines=$(tail -n "$lines" "$i")
    echo "$first_lines"
    echo "..."
    echo "$last_lines"
  fi
  echo ""
done
