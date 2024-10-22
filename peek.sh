#!/bin/bash

# Use command substitution to store the first and last three lines in variables
first_three_lines=$(head -n "$2" "$1")
last_three_lines=$(tail -n "$2" "$1")

# Print the first three lines followed by the last three lines
echo "$first_three_lines"
echo "..."
echo "$last_three_lines"

