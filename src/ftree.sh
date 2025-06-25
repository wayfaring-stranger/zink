#!/bin/bash
# Usage: ftree.sh [--max-depth=N] <directory>
# Prints a directory tree, excluding certain files

EXCLUDES=(".DS_Store" "pycache__" ".pyc" ".pyo" ".log" ".tmp")

function should_exclude() {
    local name="$1"
    for pat in "${EXCLUDES[@]}"; do
        if [[ "$name" == *"$pat" ]]; then
            return 0
        fi
    done
    return 1
}

function create_ftree() {
    local root="$1"
    local rhs="${2:-}"
    local current_depth="${3:-0}"
    local max_depth="${4:-999}"
    local basename=$(basename "$root")
    
    # Print the current directory/file
    if [[ "$rhs" == "" ]]; then
        echo "|-- $basename"
    else
        echo "${rhs}|-- $basename"
    fi
    
    # Check if we've reached max depth
    if [[ $current_depth -ge $max_depth ]]; then
        return
    fi
    
    # Get all items in the directory
    local items=()
    while IFS= read -r -d $'\0' item; do
        items+=("$item")
    done < <(find "$root" -mindepth 1 -maxdepth 1 -print0 | sort -z)
    
    # Process directories first, then files
    local dirs=()
    local files=()
    
    for item in "${items[@]}"; do
        local fname=$(basename "$item")
        should_exclude "$fname" && continue
        
        if [[ -d "$item" ]]; then
            dirs+=("$item")
        else
            files+=("$item")
        fi
    done
    
    # Process directories
    for dir in "${dirs[@]}"; do
        local fname=$(basename "$dir")
        local new_rhs="${rhs}|   "
        create_ftree "$dir" "$new_rhs" $((current_depth + 1)) "$max_depth"
    done
    
    # Process files
    for file in "${files[@]}"; do
        local fname=$(basename "$file")
        echo "${rhs}|   |-- $fname"
    done
}

run_ftree() {
    local root=""
    local max_depth=999
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --max-depth=*)
                max_depth="${1#*=}"
                shift
                ;;
            --max-depth)
                if [[ -n "$2" && "$2" != --* ]]; then
                    max_depth="$2"
                    shift 2
                else
                    echo "Error: --max-depth requires a value"
                    exit 1
                fi
                ;;
            -*)
                echo "Error: Unknown option $1"
                exit 1
                ;;
            *)
                root="$1"
                shift
                ;;
        esac
    done
    
    # if not provided, use current directory
    if [[ -z "$root" ]]; then
        root=$(pwd)
    fi
    
    # Validate max_depth is a number
    if ! [[ "$max_depth" =~ ^[0-9]+$ ]]; then
        echo "Error: max-depth must be a positive integer"
        exit 1
    fi
    
    create_ftree "$root" "" 0 "$max_depth"
}

run_ftree "$@"
