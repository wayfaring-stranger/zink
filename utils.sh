
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