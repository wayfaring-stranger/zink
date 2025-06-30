SRC_DIRPATH=$(realpath $(dirname $0))  # Absolute path to the directory containing this script
CONFIG_PATH="$SRC_DIRPATH/.config"  # Path to the configuration file


# if config path does not exist:
if [ ! -f "$CONFIG_PATH" ]; then
    # create it and alias file
    touch $CONFIG_PATH

    
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
PROGRAM_ALIAS_NAME="zink"
HEADER_MARKER="### $NAME ###"  # Marker to identify this script's section in bash profile
START_MARKER="###    Aliases-Start    ###"  # Start marker for alias section
END_MARKER="###    Aliases-End    ###"  # End marker for alias section
INSTALL_FMT_NAME=$(echo $NAME | sed 's/-/_/g')  # Convert NAME to valid variable name format
UPPERCASED_NAME=$(echo $NAME | tr '[:lower:]' '[:upper:]')
INSTALL_DIRPATH_VAR="$UPPERCASED_NAME"_DIR  # Environment variable name for script directory
INSTALL_DIRPATH_VAR_VALUE="\"$SRC_DIRPATH\""  # Value for the environment variable
EXPORT_VAR="export $INSTALL_DIRPATH_VAR=$INSTALL_DIRPATH_VAR_VALUE"  # Full export statement
INSTALL_COMMAND="bash $SRC_DIRPATH/install.sh silent"
ALIASES_DIRPATH="$SRC_DIRPATH/src"
PROGRAM_ALIAS_PATH="$SRC_DIRPATH/$PROGRAM_ALIAS_NAME.sh"
CACHED_ALIAS_PATHS_FILE="$SRC_DIRPATH/.cache"