#!/bin/bash
# Script to process fasta files with optional folder and line count arguments. Cheer up. Enjoy it! 
# Super improved final version (with ai).

# Function to print error and exit
error_exit() {
    echo "ERROR: $1"
    exit 1
}

# Default values
if [[ -r $PWD  ]]; then
    folder="."
    absolute_folder=$PWD
else
    error_exit "The current folder does not have the required permissions."
fi
N=0

# Parse arguments
if [[ -n "$1" ]]; then
    if [[ -d "$1" && -r "$1" ]]; then
        if [[ "$1" == "." ]] then
            folder="$1"
            absolute_folder="$PWD"
        else
            folder="$1"
            absolute_folder="$1"
        fi
    else
        error_exit "Invalid folder. Ensure it exists and has read permissions."
    fi
fi

if [[ -n "$2" ]]; then
    if [[ "$2" =~ ^[0-9]+$ ]]; then
        N="$2"
    else
        error_exit "Second argument must be a non-negative integer."
    fi
fi

# Report starting
echo "Starting the script..."
echo "Folder: $absolute_folder"
echo "Number of lines displayed: $N"
echo "----------------------------"

# Count fasta files
fasta_files=$(find "$folder" \( -type f -o -type l \) \( -iname "*.fasta" -o -iname "*.fa" \) ! -iname ".*" 2>/dev/null) # -iname to handle case sensitivity; 2>/dev/null to quiter errors in folders without fasta_files. -L ensures symlinks are followed
echo "Number of fasta files: $(echo "$fasta_files" | grep -c .)" # grep -c . counts non-empty lines
# Count unique fasta IDs
echo "Number of unique fasta IDs: $(echo "$fasta_files" | xargs -I {} grep -h "^>" {} | sort -u | wc -l)"
# xargs runs grep for each file, extracting headers (lines starting with ">") # -h suppresses filenames, sort -u removes duplicates, wc -l counts unique IDs
echo "--------------------------"

# Process each fasta file
echo "$fasta_files" | while read -r file; do
    [[ -z "$file" ]] && continue # Skip if there are no fasta files
    echo "========== File: $file =========="

    # Check if file is empty
    if [[ ! -s "$file" ]]; then
        echo "File is empty" && continue
    fi

    # Symlink check
    echo "### File is $(if [[ -h "$file" ]]; then echo "a symlink"; else echo "not a symlink"; fi)"

    # Count sequences and total length
    total_length=$(awk '!/^>/ {gsub(/[- ]/, ""); total += length} END {print total}' "$file" 2>&1) || { echo "awk error: $total_length"; continue; }
    sequences=$(grep -c "^>" "$file")
    echo "### Number of sequences: $sequences"
    echo "### Total sequence length: $total_length"

    # Determine sequence type
    sequence_content=$(awk '!/^>/ {gsub(/[- ]/, ""); print}' "$file" | tr -d '\n')
    echo "### Sequence type: $( 
    if [[ "$sequence_content" =~ ^[ACTGUNactgun]*$ ]]; then  echo "Nucleotide"; 
    elif [[ "$sequence_content" =~ ^[ACDEFGHIKLMNPQRSTUVWYXacdefghiklmnpqrstuvwyx]*$ ]]; then echo "Amino acid"; 
    else echo "Unknown"; 
    fi )"

    # Display file content if N > 0
    if [[ "$N" -gt 0 ]]; then
        total_lines=$(wc -l < "$file")
        if [[ "$total_lines" -le $((2 * N)) ]]; then
            echo ">>> Full content of the file:"
            cat "$file"
        else
            echo ">>> First $N lines:"
            head -n "$N" "$file"
            echo "..."
            echo ">>> Last $N lines:"
            tail -n "$N" "$file"
        fi
    fi
    echo "---------------------------------"
done