#Arxius permissos.

if [[ -n "$2" ]]; then
    if [[ $2 != *[A-z]* ]]; then
        N=$2
    else
        echo ERROR: Not starting the script ...
        echo You must provide an integer number
    fi
else
    N=0
fi

if [[ -n "$1" ]]; then
    if [[ $1 != *[A-z]* ]]; then
        folder=$PWD
        N=$1
    elif [[ -d $1 ]] && [[ -r $1 ]]; then
        folder="$1"
    else
        if [[ -d $1 ]]; then
            echo ERROR: Not starting the script ...
            echo The folder does not have the required permissions.
        else
            echo ERROR: Not starting the script ...
            echo You must provide an existing folder
        fi
    fi
else
    echo "Hola"
    if [[ -r $PWD  ]]; then
        folder=$PWD
    else
        echo "ERROR: Not starting the script ..."
        echo "The current folder does not have the required permissions."
    fi
fi

if [[ -n $folder ]] && [[ -n $N ]] ; then
    echo Starting the script ...
    echo Folder: $folder
    echo Number of lines displayed: $N
    echo -----------------
    #How many fasta files there are:
    n_files=$(find $folder -type f  \( -name "*fasta" -or -name "*fa" \) ! -name ".*" | wc -l)
    echo Number of fasta files of the $folder folder: $n_files

    #How many unique fasta IDs there are:
    n_uniq_IDs=$(find $folder -type f  \( -name "*fasta" -or -name "*fa" \) ! -name ".*" | while read i; do
        grep ">" "$i"
    done | sort | uniq -c | wc -l)
    echo Number of unique fasta IDs: $n_uniq_IDs

    find $folder -type f  \( -name "*fasta" -or -name "*fa" \) ! -name "._*" | while read i
        do echo "===========" Filename: "$i"
        if [[ ! -s "$i" ]]; then
            echo File is empty
        else
            if [[ -h "$i" ]]; then
                echo "###" File is a symlink
            else
                echo "###" File is not a symlink
            fi
            echo "### Number of sequences: $(awk '/>/{n=n+1}END{print n}' "$i")"
            sequence=$(awk '!/>/{gsub(/[- ]/, "", $0); print $0}' "$i" | tr -d '\n')
            length=$(echo "$sequence" | awk '{print length($0)}')
            echo "###" "Length of sequence: $length"
            if echo "$sequence" | grep -Eq '^[ACTGUNactgun]*$'; then
                echo "###" Type of sequence: Nucleotide
            elif echo "$sequence" | grep -Eq '^[ACDEFGHIKLMNPQRSTUVWYXacdefghiklmnpqrstuvwyx]*$'; then
                echo "###" Type of sequence: Amino acid
            else
                echo "###" Type of sequence: Unknown
            fi

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
        fi
        echo ""
    done
fi
#Putting "" to aovid errors in files with spaces, i.e "hhh (Copy).fa"