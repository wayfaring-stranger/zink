

#realpath of this script
SCRIPT_PATH=$(realpath $0)

#get the directory of this script
SCRIPT_DIR=$(dirname $SCRIPT_PATH)

# for file that ends in .sh, get the name of the file and add it to the aliases

alias_paths=$(find $SCRIPT_DIR -name "*.sh")
#number of alias paths:
number_of_aliases=0
for alias_path in $alias_paths; do
    number_of_aliases=$((number_of_aliases + 1))
done

echo ""
echo "$number_of_aliases aliases:"
echo ""
for alias_path in $alias_paths; do
    # get the name of the file
    file_name=$(basename $alias_path)
    alias_name=$(echo $file_name | sed 's/\.sh//')
    # add the file name to the aliases
    echo "    $alias_name"
done
echo ""

