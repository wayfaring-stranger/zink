SRC_DIRPATH=$(dirname $(realpath $0))
echo "ALIASES_DIRPATH: $ALIASES_DIRPATH"
source $SRC_DIRPATH/constants.sh
source $SRC_DIRPATH/utils.sh


run_add_alias() {
    local alias_path="$1"
    local alias_name=$(get_alias_name $alias_path)
    local alias_command=$(get_alias_command $alias_path)
    # if alias path does not exist, raise an error
    if [ ! -f "$alias_path" ]; then
        echo "Error: Alias path [$alias_path] does not exist"
        exit 1
    fi

    if ! grep -q "$alias_path" "$CACHED_ALIAS_PATHS_FILE"; then
        echo "$alias_path" >> "$CACHED_ALIAS_PATHS_FILE"
    fi
    local expected_alias_path="$ALIASES_DIRPATH/$alias_name.sh"
    cp "$alias_path" "$expected_alias_path"

    echo "reinstalling aliases"
    eval "$INSTALL_COMMAND"
}

run_remove_alias() {
    local alias_name=$1
    local expected_alias_path="$ALIASES_DIRPATH/$alias_name.sh"
    # if the alias name does not exist, raise an error
    if [ ! -f "$expected_alias_path" ]; then
        echo "Error: Alias name [$alias_name] does not exist"
        exit 1
    fi
    rm "$expected_alias_path"

    # remove the alias from the cache
    if grep -q "$expected_alias_path" "$CACHED_ALIAS_PATHS_FILE"; then
        sed -i '' "/$expected_alias_path/d" "$CACHED_ALIAS_PATHS_FILE"
    fi



    # re-run the install task
    echo "reinstalling aliases"
    eval "$INSTALL_COMMAND"

    
}

run_task() {
    local task_name=$1
    if [ -z "$task_name" ]; then
        echo "Error: Task name not provided"
        exit 1
    fi
    case "$task_name" in
        "add")
            run_add_alias "${@:2}"
            ;;
        "remove")
            run_remove_alias "${@:2}"
            ;;
        *)
            echo "Error: Task '$task_name' not found"
            exit 1
            ;;
    esac
}

run_task "$@"