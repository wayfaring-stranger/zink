#!/bin/bash
# Zink Installation Script
# This script automatically installs shell script aliases by modifying the user's .zshrc file
# It manages aliases for all .sh files found in the src/ directory

SRC_DIRPATH=$(realpath $(dirname $0))  # Absolute path to the directory containing this script
CONFIG_PATH="$SRC_DIRPATH/.config"  # Path to the configuration file

# if config path does not exist:
if [ ! -f "$CONFIG_PATH" ]; then
    # create it
    
    # get user input for BASH_PROFILE_PATH
    read -p "Enter the path to your shell configuration file:" BASH_PROFILE_PATH

    # if bash profile path does not have $HOME in it, add it
    if [[ $BASH_PROFILE_PATH != $HOME* ]]; then
        BASH_PROFILE_PATH="$HOME/$BASH_PROFILE_PATH"
    fi

    # ensure BASH_PROFILE_PATH exists
    if [ ! -f "$BASH_PROFILE_PATH" ]; then
        echo "Error: BASH_PROFILE_PATH [$BASH_PROFILE_PATH] does not exist"
        exit 1
    fi
    touch $CONFIG_PATH

    # add BASH_PROFILE_PATH to it
    echo "BASH_PROFILE_PATH=$BASH_PROFILE_PATH" >>$CONFIG_PATH

fi




if [ -f "$CONFIG_PATH" ]; then
    # Import config
    export $(cat $CONFIG_PATH | sed 's/#.*//g' | xargs)
else
    echo "Error: .config file not found"
    exit 1
fi


# Script identification and markers
NAME="Zink"
HEADER_MARKER="### $NAME ###"  # Marker to identify this script's section in .zshrc
START_MARKER="###    Aliases-Start    ###"  # Start marker for alias section
END_MARKER="###    Aliases-End    ###"  # End marker for alias section
INSTALL_FMT_NAME=$(echo $NAME | sed 's/-/_/g')  # Convert NAME to valid variable name format
UPPERCASED_NAME=$(echo $NAME | tr '[:lower:]' '[:upper:]')
INSTALL_DIRPATH_VAR="$UPPERCASED_NAME"_DIR  # Environment variable name for script directory
INSTALL_DIRPATH_VAR_VALUE="\"$SRC_DIRPATH\""  # Value for the environment variable
EXPORT_VAR="export $INSTALL_DIRPATH_VAR=$INSTALL_DIRPATH_VAR_VALUE"  # Full export statement

# Self-installation command for silent mode
INSTALL_COMMAND="bash $SRC_DIRPATH/install.sh silent"

# Self-installation command for silent mode
INSTALL_COMMAND="bash $SRC_DIRPATH/install.sh silent"
SILENT=$1  # First command line argument (for silent mode)

# Logging function - only prints messages unless silent mode is enabled
log() {
    # if SILENT is not set or is not "silent", print the message
    if [ -z "$SILENT" ] || [ "$SILENT" != "silent" ]; then
        echo "$NAME: $1"
    fi
}

safe_sed() {
    # usage: safe_sed "pattern" "filename"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "$1" "$2"  # macOS
    else
        sed -i "$1" "$2"     # Linux
    fi
}

# Extract alias name from script path (removes .sh extension)
get_alias_name() {
    local alias_path=$1
    local alias_path_basename=$(basename $alias_path)  # Get filename without path
    local alias_name=$(echo $alias_path_basename | sed 's/\.sh$//')  # Remove .sh extension
    echo $alias_name
}

# Generate the alias command string for a given script path
get_alias_command() {
    local alias_path=$1
    local alias_name=$(get_alias_name $alias_path)
    local alias_command="alias $alias_name=\"bash $alias_path\";"  # Create alias command
    echo $alias_command
}

# Check if a specific text exists in the bash profile
bash_profile_contains_text() {
    local text=$1
    if grep -q "$text" $BASH_PROFILE_PATH; then
        return 0  # Text found
    else
        return 1  # Text not found
    fi
}

# Add a new alias to the bash profile just before the END_MARKER
add_alias_to_path() {
    local alias_path=$1
    local alias_name=$(get_alias_name $alias_path)
    local alias_command=$(get_alias_command $alias_path)
    # Escape special regex characters in the alias command for sed
    local escaped_alias_command=$(echo "$alias_command" | sed 's/[[\.*^$()+?{|]/\\&/g')
    # Insert the alias command before the END_MARKER
    safe_sed "/$END_MARKER/i\\
$escaped_alias_command
" "$BASH_PROFILE_PATH"
}

# Replace a specific line in the bash profile with a new alias command
replace_line_in_bash_profile() {
    local line_number=$1
    local new_line=$2
    # Replace the line at the specified line number
    safe_sed "${line_number}c\\
$new_line
" $BASH_PROFILE_PATH
}

# Ensure the required markers and configuration are present in the bash profile
ensure_install() {
    # Add header section if it doesn't exist
    if ! bash_profile_contains_text "$HEADER_MARKER"; then
        log "adding: [$HEADER_MARKER]"
        echo "" >>$BASH_PROFILE_PATH  # Add blank line
        echo "$HEADER_MARKER" >>$BASH_PROFILE_PATH  # Add header marker
        echo "$EXPORT_VAR" >>$BASH_PROFILE_PATH  # Add environment variable export
        echo "$INSTALL_COMMAND" >>$BASH_PROFILE_PATH  # Add self-installation command
    fi
    
    # Add start marker if it doesn't exist
    if ! bash_profile_contains_text "$START_MARKER"; then
        log "adding: [$START_MARKER]"
        echo "$START_MARKER" >>$BASH_PROFILE_PATH
    fi

    # Add end marker if it doesn't exist
    if ! bash_profile_contains_text "$END_MARKER"; then
        log "adding: [$END_MARKER]"
        echo "$END_MARKER" >>$BASH_PROFILE_PATH
    fi
}

# Main installation function
run_install() {
    log "installing aliases"

    # Ensure all required markers are in place
    ensure_install

    # Find all .sh files in the src directory that need to be installed as aliases
    local alias_paths_to_install=$(find $SRC_DIRPATH/src -name "*.sh")
    local alias_names_to_install=()

    # Build array of alias names from the script paths
    for alias_path in $alias_paths_to_install; do
        local alias_name=$(get_alias_name $alias_path)
        alias_names_to_install+=("$alias_name")
    done

    # Find the line numbers of the start and end markers
    local start_marker_line_number=$(grep -n "$START_MARKER" $BASH_PROFILE_PATH | cut -d: -f1)
    local end_marker_line_number=$(grep -n "$END_MARKER" $BASH_PROFILE_PATH | cut -d: -f1)
    # Adjust to get the actual range of alias lines (exclude the markers themselves)
    start_marker_line_number=$((start_marker_line_number + 1))
    end_marker_line_number=$((end_marker_line_number - 1))

    # Process existing aliases in the bash profile
    local active_alias_names=()
    for line_number in $(seq $start_marker_line_number $end_marker_line_number); do
        local line_text=$(sed -n "${line_number}p" $BASH_PROFILE_PATH)
        if [[ $line_text == alias* ]]; then  # Check if line contains an alias
            local line_alias_name=$(echo $line_text | sed 's/alias //' | sed 's/=.*//')  # Extract alias name
            active_alias_names+=("$line_alias_name")
            
            # Update existing aliases if the script still exists
            for alias_path in $alias_paths_to_install; do
                local alias_name=$(get_alias_name $alias_path)
                if [[ $line_alias_name == $alias_name ]]; then
                    local alias_command=$(get_alias_command $alias_path)
                    replace_line_in_bash_profile $line_number "$alias_command"
                    break
                fi
            done
        fi
    done

    # Remove aliases that no longer have corresponding script files
    for active_alias_name in "${active_alias_names[@]}"; do
        if ! echo "${alias_names_to_install[@]}" | grep -q "$active_alias_name"; then
            # Find and remove the alias line
            for line_number in $(seq $start_marker_line_number $end_marker_line_number); do
                local line_text=$(sed -n "${line_number}p" $BASH_PROFILE_PATH)
                if [[ $line_text == "alias $active_alias_name="* ]]; then
                    log "removing alias: $active_alias_name"
                    safe_sed "${line_number}d" $BASH_PROFILE_PATH
                    break
                fi
            done
        fi
    done

    # Add new aliases for scripts that don't have existing aliases
    for alias_path_to_install in $alias_paths_to_install; do
        local alias_name=$(get_alias_name $alias_path_to_install)
        if ! echo "${active_alias_names[@]}" | grep -q "$alias_name"; then
            log "adding alias: $alias_name ($alias_path_to_install)"
            add_alias_to_path $alias_path_to_install
        fi
    done

    # Ensure the header marker appears after the end marker (for self-installation)
    if ! grep -A1 "$END_MARKER" $BASH_PROFILE_PATH | grep -q "$HEADER_MARKER"; then
        safe_sed "/$END_MARKER/a\\
$HEADER_MARKER
" $BASH_PROFILE_PATH
    fi

    log "done"
}

# Execute the installation
run_install
