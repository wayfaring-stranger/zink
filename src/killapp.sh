
run_killapp() {
    local app_name=$1
    echo "Killing app $app_name"
    # get all processes with the name
    local app_pids=$(ps aux | grep -i $app_name | grep -v grep | awk '{print $2}')
    if [ -z "$app_pids" ]; then
        echo "No process found for $app_name"
        return 1
    fi
    for app_pid in $app_pids; do
        echo "Killing process $app_pid for $app_name"
        kill -9 $app_pid
    done
}

if [ -z "$1" ]; then
    echo "Usage: $0 <app_name>"
    exit 1
fi

run_killapp "$@"