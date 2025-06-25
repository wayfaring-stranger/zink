#!/bin/bash
# Usage: ftree.sh <directory>
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
    local rhs="${2:-|   }"
    local basename=$(basename "$root")
    if [[ "$rhs" == "|   " ]]; then
        echo "|-- $basename"
    else
        echo "${rhs}|-- $basename"
    fi
    local files=()
    while IFS= read -r -d $'\0' file; do
        files+=("$file")
    done < <(find "$root" -mindepth 1 -maxdepth 1 -print0 | sort -z)
    for file in "${files[@]}"; do
        local fname=$(basename "$file")
        should_exclude "$fname" && continue
        if [[ -d "$file" ]]; then
            create_ftree "$file" "$rhs"
        else
            echo "${rhs}|-- $fname"
        fi
    done
}

run_ftree() {
    local root=$1
    # if not provided, use current directory
    if [[ -z "$root" ]]; then
        root=$(pwd)
    fi
    create_ftree "$root"
}

run_ftree "$@"