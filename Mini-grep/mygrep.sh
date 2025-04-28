#!/bin/bash

# Define usage function
usage() {
    echo "Usage: $0 [options] 'pattern' [file]"
    echo "Search for patterns in files (case-insensitive)"
    echo "Options:"
    echo "  -n              Show line numbers"
    echo "  -v              Invert match (print non-matching lines)"
    echo "  -vn, -nv        Combination of -v and -n"
    echo "  --help          Display this help message"
    exit 0
}

# Initialize options
show_line_numbers=0
invert_match=0
pattern=""
file=""

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n)
            show_line_numbers=1
            shift
            ;;
        -v)
            invert_match=1
            shift
            ;;
        -nv|-vn)
            show_line_numbers=1
            invert_match=1
            shift
            ;;
        --help)
            usage
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            exit 1
            ;;
        *)
            # Assign non-option arguments: first is pattern, second is file
            if [[ -z "$pattern" ]]; then
                pattern="$1"
            else
                file="$1"
            fi
            shift
            ;;
    esac
done


# Check if pattern resembles a .txt filename (case-insensitive)
if [[ "${pattern,,}" == *.txt ]]; then
    echo "Error: Pattern '$pattern' looks like a filename. Did you swap the pattern and file?" >&2
    echo "Example: $0 'search_term' file.txt" >&2
    exit 1
fi


if [ -z "$file" ]; then
    echo "Error: No file provided" >&2
    echo "See './mygrep.sh  --help'" >&2
    exit 1
else
	if [ ! -f "$file" ]; then
		echo "Error: File '$file' not found" >&2
		exit 1
	fi
fi


# Perform the search
line_number=0
while IFS= read -r line; do
    line_number=$((line_number + 1))
    
    # Case-insensitive match check
    if [[ "${line,,}" == *"${pattern,,}"* ]]; then
        match=1
    else
        match=0
    fi
    
    # Handle output based on options
    if (( invert_match )); then
        if (( !match )); then
            if (( show_line_numbers )); then
                echo "$line_number:$line"
            else
                echo "$line"
            fi
        fi
    else
        if (( match )); then
            if (( show_line_numbers )); then
                echo "$line_number:$line"
            else
                echo "$line"
            fi
        fi
    fi
done < "$file"
