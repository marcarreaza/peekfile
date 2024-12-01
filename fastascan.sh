# Script to process fasta files with optional arguments for folder and number of lines to display for fasta files. Enjoy it!

# Check if the second argument ($2) is provided
if [[ -n "$2" ]]; then
    # Ensure the second argument is a number
    if [[ "$2" != *[A-z]* ]]; then
        N="$2" # Assign the number to N
    else
        # Error if the argument is not an integer
        echo ERROR: Not starting the script ...
        echo You must provide an integer number
    fi
else
    N=0 # Default value for N if not provided
fi

# Check if the first argument ($1) is provided
if [[ -n "$1" ]]; then
    # If $1 is not a string, assume it's a number and set folder to the current directory
    if [[ $1 != *[A-z]* ]]; then
        folder=$PWD
        N=$1
    # If $1 is a readable directory, set it as the folder
    elif [[ -d $1 ]] && [[ -r $1 ]]; then
        folder="$1"
    else
        # Handle error cases where $1 is a directory without the necessary permissions or doesn't exist
        if [[ -d $1 ]]; then
            echo ERROR: Not starting the script ...
            echo The folder does not have the required permissions.
        else
            echo ERROR: Not starting the script ...
            echo You must provide an existing folder
        fi
    fi
else
    # Default folder is the current directory, if readable
    if [[ -r $PWD  ]]; then
        folder=$PWD
    else
        echo "ERROR: Not starting the script ..."
        echo "The current folder does not have the required permissions."
    fi
fi

# If both folder and N are defined, start processing
if [[ -n $folder ]] && [[ -n $N ]] ; then
    echo Starting the script ...
    echo Folder: $folder
    echo Number of lines displayed: $N
    echo -----------------
    # Count the number of fasta files in the folder
    n_files=$(find $folder -type f  \( -name "*fasta" -or -name "*fa" \) ! -name ".*" | wc -l)
    echo Number of fasta files of the $folder folder: $n_files

    # Count the number of unique fasta IDs across all files
    n_uniq_IDs=$(find $folder -type f  \( -name "*fasta" -or -name "*fa" \) ! -name ".*" | while read i; do
        grep ">" "$i" # Extract headers
    done | sort | uniq -c | wc -l)
    echo Number of unique fasta IDs: $n_uniq_IDs

    # Process each fasta file
    find $folder -type f  \( -name "*fasta" -or -name "*fa" \) ! -name "._*" | while read i
        do echo "===========" Filename: "$i"

        # Check if the file is empty        
        if [[ ! -s "$i" ]]; then
            echo File is empty
        else
            # Check if the file is a symbolic link
            if [[ -h "$i" ]]; then
                echo "###" File is a symlink
            else
                echo "###" File is not a symlink
            fi
            # Check if the file is readable
            if [[ -r $i ]]; then
                # Count the number of sequences
                echo "### Number of sequences: $(awk '/>/{n=n+1}END{print n}' "$i")"
                # Calculate total sequence length                
                sequence=$(awk '!/>/{gsub(/[- ]/, "", $0); print $0}' "$i" | tr -d '\n')
                length=$(echo "$sequence" | awk '{print length($0)}')
                echo "###" "Length of sequence: $length"
                # Determine the type of sequence
                if echo "$sequence" | grep -Eq '^[ACTGUNactgun]*$'; then
                    echo "###" Type of sequence: Nucleotide
                elif echo "$sequence" | grep -Eq '^[ACDEFGHIKLMNPQRSTUVWYXacdefghiklmnpqrstuvwyx]*$'; then
                    echo "###" Type of sequence: Amino acid
                else
                    echo "###" Type of sequence: Unknown
                fi
                # Display content based on the number of lines
                if [[ $N != 0 ]]; then
                    lines=$(grep -c "" "$i")
                    if [[ lines -le $((2 * $N)) ]]; then
                        echo ">>>>>>>>>>>>>>>>>>> Displaying file content"
                        cat "$i"
                    else
                        echo ">>>>>>>>>>>>>>>>>>> Displaying the first and last $N lines"
                        first_lines=$(head -n "$N" "$i")
                        last_lines=$(tail -n "$N" "$i")
                        echo "$first_lines"
                        echo "..."
                        echo "$last_lines"
                    fi
                fi
            else
                echo The fasta file does not have the required permissions
            fi
        fi
        echo ""
    done
fi

# Quote filenames to avoid errors with spaces or special characters