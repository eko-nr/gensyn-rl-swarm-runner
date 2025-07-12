#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# General arguments
ROOT="$(dirname "$SCRIPT_DIR")/rl-swarm" 

export IDENTITY_PATH
export GENSYN_RESET_CONFIG
export CONNECT_TO_TESTNET=true
export ORG_ID
export HF_HUB_DOWNLOAD_TIMEOUT=120  # 2 minutes
export SWARM_CONTRACT="0xFaD7C5e93f28257429569B854151A1B8DCD404c2"
export HUGGINGFACE_ACCESS_TOKEN="None"

# Path to an RSA private key. If this path does not exist, a new key pair will be created.
# Remove this file if you want a new PeerID.
DEFAULT_IDENTITY_PATH="$ROOT"/swarm.pem
IDENTITY_PATH=${IDENTITY_PATH:-$DEFAULT_IDENTITY_PATH}

DOCKER=${DOCKER:-""}
GENSYN_RESET_CONFIG=${GENSYN_RESET_CONFIG:-""}

# Bit of a workaround for the non-root docker container.
if [ -n "$DOCKER" ]; then
    volumes=(
        /home/gensyn/rl_swarm/modal-login/temp-data
        /home/gensyn/rl_swarm/keys
        /home/gensyn/rl_swarm/configs
        /home/gensyn/rl_swarm/logs
    )

    for volume in ${volumes[@]}; do
        sudo chown -R 1001:1001 $volume
    done
fi

# Will ignore any visible GPUs if set.
CPU_ONLY=${CPU_ONLY:-""}

# Set if successfully parsed from modal-login/temp-data/userData.json.
ORG_ID=${ORG_ID:-""}

GREEN_TEXT="\033[32m"
BLUE_TEXT="\033[34m"
RED_TEXT="\033[31m"
RESET_TEXT="\033[0m"

echo_green() {
    echo -e "$GREEN_TEXT$1$RESET_TEXT"
}

echo_blue() {
    echo -e "$BLUE_TEXT$1$RESET_TEXT"
}

echo_red() {
    echo -e "$RED_TEXT$1$RESET_TEXT"
}

# Cleanup function (no more 'kill' errors)
cleanup() {
    echo ">> Shutting down trainer..."
    cd "$SCRIPT_DIR"
    # Only kill process group if it exists
    if ps -p $$ > /dev/null; then
        kill -- -$$ 2>/dev/null || true
    fi
    exit 0
}
trap cleanup EXIT

errnotify() {
    echo_red ">> An error was detected while running rl-swarm. See $ROOT/logs for full logs."
}

trap errnotify ERR

echo -e "\033[38;5;224m"
cat << "EOF"
    ██████  ██            ███████ ██     ██  █████  ██████  ███    ███
    ██   ██ ██            ██      ██     ██ ██   ██ ██   ██ ████  ████
    ██████  ██      █████ ███████ ██  █  ██ ███████ ██████  ██ ████ ██
    ██   ██ ██                 ██ ██ ███ ██ ██   ██ ██   ██ ██  ██  ██
    ██   ██ ███████       ███████  ███ ███  ██   ██ ██   ██ ██      ██

    From Gensyn

EOF

# Create logs directory if it doesn't exist
mkdir -p "$ROOT/logs"

if [ "$CONNECT_TO_TESTNET" = true ]; then
    # Run modal_login server.
    echo "Please login to create an Ethereum Server Wallet"

    cd $ROOT/modal-login
    # Check if the yarn command exists; if not, install Yarn.

    # Node.js + NVM setup
    if ! command -v node > /dev/null 2>&1; then
        echo "Node.js not found. Installing NVM and latest Node.js..."
        export NVM_DIR="$HOME/.nvm"
        if [ ! -d "$NVM_DIR" ]; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        fi
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        nvm install node
    else
        echo "Node.js is already installed: $(node -v)"
    fi

    if ! command -v yarn > /dev/null 2>&1; then
        # Detect Ubuntu (including WSL Ubuntu) and install Yarn accordingly
        if grep -qi "ubuntu" /etc/os-release 2> /dev/null || uname -r | grep -qi "microsoft"; then
            echo "Detected Ubuntu or WSL Ubuntu. Installing Yarn via apt..."
            curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
            echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
            sudo apt update && sudo apt install -y yarn
        else
            echo "Yarn not found. Installing Yarn globally with npm (no profile edits)…"
            # This lands in $NVM_DIR/versions/node/<ver>/bin which is already on PATH
            npm install -g --silent yarn
        fi
    fi

    ENV_FILE="$ROOT"/modal-login/.env
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS version
        sed -i '' "3s/.*/SMART_CONTRACT_ADDRESS=$SWARM_CONTRACT/" "$ENV_FILE"
    else
        # Linux version
        sed -i "3s/.*/SMART_CONTRACT_ADDRESS=$SWARM_CONTRACT/" "$ENV_FILE"
    fi

    # Docker image already builds it, no need to again.
    if [ -z "$DOCKER" ]; then
        yarn install --immutable
        echo "Building server"
        yarn build > "$ROOT/logs/yarn.log" 2>&1
    fi
    yarn start >> "$ROOT/logs/yarn.log" 2>&1 & # Run in background and log output

    SERVER_PID=$!  # Store the process ID
    echo "Started server process: $SERVER_PID"
    sleep 5

    echo ""
    echo_green "Please login to continue, you do not need to login if you have already logged in [y/n]"
    read -r login_status

    case "$login_status" in
        y|Y)
            # Remove modal credentials if they exist
            rm -r $ROOT/modal-login/temp-data/*.json 2> /dev/null || true

            # Try to open the URL in the default browser
            if [ -z "$DOCKER" ]; then
                if open http://localhost:3000 2> /dev/null; then
                    echo_green ">> Successfully opened http://localhost:3000 in your default browser."
                else
                    echo ">> Failed to open http://localhost:3000. Please open it manually."
                fi
            else
                echo_green ">> Please open http://localhost:3000 in your host browser."
            fi

            echo_green ">> Waiting for modal userData.json to be created..."

            while [ ! -f "$ROOT/modal-login/temp-data/userData.json" ]; do
                sleep 5  # Wait for 5 seconds before checking again
            done
            echo "Found userData.json. Proceeding..."

            ;;
            
        n|N)
            echo_green ">> continue..."
            ;;

        *)
            echo_red ">> Invalid command"
            exit 1;
            ;;
    esac

    cd ..

    ORG_ID=$(awk 'BEGIN { FS = "\"" } !/^[ \t]*[{}]/ { print $(NF - 1); exit }' modal-login/temp-data/userData.json)
    echo "Your ORG_ID is set to: $ORG_ID"

    # Wait until the API key is activated by the client
    echo "Waiting for API key to become activated..."
    while true; do
        STATUS=$(curl -s "http://localhost:3000/api/get-api-key-status?orgId=$ORG_ID")
        if [[ "$STATUS" == "activated" ]]; then
            echo "API key is activated! Proceeding..."
            break
        else
            echo "Waiting for API key to be activated..."
            sleep 5
        fi
    done
fi

echo_green ">> Getting requirements..."
pip install --upgrade pip

# echo_green ">> Installing GenRL..."
pip install gensyn-genrl==0.1.4
pip install reasoning-gym>=0.1.20 # for reasoning gym env
pip install trl # for grpo config, will be deprecated soon
pip install hivemind@git+https://github.com/gensyn-ai/hivemind@639c964a8019de63135a2594663b5bec8e5356dd # We need the latest, 1.1.11 is broken


if [ ! -d "$ROOT/configs" ]; then
    mkdir "$ROOT/configs"
fi  
if [ -f "$ROOT/configs/rg-swarm.yaml" ]; then
    # Use cmp -s for a silent comparison. If different, backup and copy.
    if ! cmp -s "$ROOT/rgym_exp/config/rg-swarm.yaml" "$ROOT/configs/rg-swarm.yaml"; then
        if [ -z "$GENSYN_RESET_CONFIG" ]; then
            echo_green ">> Found differences in rg-swarm.yaml. If you would like to reset to the default, set GENSYN_RESET_CONFIG to a non-empty value."
        else
            echo_green ">> Found differences in rg-swarm.yaml. Backing up existing config."
            mv "$ROOT/configs/rg-swarm.yaml" "$ROOT/configs/rg-swarm.yaml.bak"
            cp "$ROOT/rgym_exp/config/rg-swarm.yaml" "$ROOT/configs/rg-swarm.yaml"
        fi
    fi
else
    # If the config doesn't exist, just copy it.
    cp "$ROOT/rgym_exp/config/rg-swarm.yaml" "$ROOT/configs/rg-swarm.yaml"
fi

if [ -n "$DOCKER" ]; then
    # Make it easier to edit the configs on Linux systems.
    sudo chmod -R 0777 /home/gensyn/rl_swarm/configs
fi

echo_green ">> Done!"

HF_TOKEN=${HF_TOKEN:-""}
if [ -n "${HF_TOKEN}" ]; then # Check if HF_TOKEN is already set and use if so. Else give user a prompt to choose.
    HUGGINGFACE_ACCESS_TOKEN=${HF_TOKEN}
else
    echo -en $GREEN_TEXT
    read -p ">> Would you like to push models you train in the RL swarm to the Hugging Face Hub? [y/N] " yn
    echo -en $RESET_TEXT
    yn=${yn:-N} # Default to "N" if the user presses Enter
    case $yn in
        [Yy]*) read -p "Enter your Hugging Face access token: " HUGGINGFACE_ACCESS_TOKEN ;;
        [Nn]*) HUGGINGFACE_ACCESS_TOKEN="None" ;;
        *) echo ">>> No answer was given, so NO models will be pushed to Hugging Face Hub" && HUGGINGFACE_ACCESS_TOKEN="None" ;;
    esac
fi

echo -en $GREEN_TEXT
read -p ">> Enter the name of the model you want to use in huggingface repo/name format, or press [Enter] to use the default model. " MODEL_NAME
echo -en $RESET_TEXT

# Only export MODEL_NAME if user provided a non-empty value
if [ -n "$MODEL_NAME" ]; then
    export MODEL_NAME
    echo_green ">> Using model: $MODEL_NAME"
else
    echo_green ">> Using default model from config"
fi

echo_green ">> Good luck in the swarm!"
echo_blue ">> And remember to star the repo on GitHub! --> https://github.com/gensyn-ai/rl-swarm"

# Configuration
API_URL="https://dashboard.gensyn.ai/api/v1/round-stage"
MAX_ROUND_DIFF=5
CHECK_INTERVAL=30  # Check every 30 seconds
RESTART_DELAY=5
ROOT="${ROOT:-$(pwd)}"  # Use current directory if ROOT not set

# Global variables
stop_loop="false"
current_app_round=""
stuck_count=0
MAX_STUCK_COUNT=3  # Force restart after 3 consecutive stuck detections

# Function to get current round from API
get_api_round() {
    local round=$(curl -s "$API_URL" | grep -o '"round":[0-9]*' | cut -d':' -f2)
    echo "$round"
}

# Function to extract round from app output
extract_app_round() {
    local log_line="$1"
    if [[ "$log_line" =~ "Joining round: "([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    fi
}

# Function to check if app is stuck
is_app_stuck() {
    local api_round="$1"
    local app_round="$2"
    
    if [[ -n "$api_round" && -n "$app_round" ]]; then
        local diff=$((api_round - app_round))
        if [[ $diff -gt $MAX_ROUND_DIFF ]]; then
            echo "true"
        else
            echo "false"
        fi
    else
        echo "false"
    fi
}

# Function to monitor and restart if stuck
monitor_and_restart() {
    local app_pid="$1"
    
    while [ "$stop_loop" = "false" ] && kill -0 "$app_pid" 2>/dev/null; do
        sleep "$CHECK_INTERVAL"
        
        local api_round=$(get_api_round)
        
        if [[ -n "$api_round" && -n "$current_app_round" ]]; then
            local is_stuck=$(is_app_stuck "$api_round" "$current_app_round")
            
            if [[ "$is_stuck" = "true" ]]; then
                stuck_count=$((stuck_count + 1))
                echo ">> ⚠️  App stuck detected! API round: $api_round, App round: $current_app_round (diff: $((api_round - current_app_round)))"
                echo ">> Stuck count: $stuck_count/$MAX_STUCK_COUNT"
                
                if [[ $stuck_count -ge $MAX_STUCK_COUNT ]]; then
                    echo ">> 🔄 Force restarting app due to being stuck..."
                    kill -TERM "$app_pid" 2>/dev/null
                    sleep 2
                    kill -KILL "$app_pid" 2>/dev/null
                    return 1  # Signal restart needed
                fi
            else
                stuck_count=0  # Reset stuck counter
            fi
        fi
    done
    
    return 0  # No restart needed
}

# Cleanup function
cleanup() {
    echo ">> Cleaning up..."
    stop_loop="true"
    # Kill any background processes
    jobs -p | xargs -r kill 2>/dev/null
    exit 0
}

# Trap signals
trap 'echo ">> Caught Ctrl+C, exiting..."; stop_loop="true"' SIGINT

echo ">> Starting smart swarm launcher with round monitoring..."
echo ">> API URL: $API_URL"
echo ">> Max round difference: $MAX_ROUND_DIFF"
echo ">> Check interval: ${CHECK_INTERVAL}s"

# Main loop
while [ "$stop_loop" = "false" ]; do
    echo ">> Starting rgym swarm launcher..."
    stuck_count=0  # Reset stuck counter for new instance
    
    # Start the Python process in background and capture output
    python -m rgym_exp.runner.swarm_launcher \
        --config-path "$ROOT/rgym_exp/config" \
        --config-name "rg-swarm.yaml" 2>&1 | while IFS= read -r line; do
        
        echo "$line"  # Print the line
        
        # Extract round number from output
        app_round=$(extract_app_round "$line")
        if [[ -n "$app_round" ]]; then
            current_app_round="$app_round"
        fi
        
    done &
    
    local app_pid=$!
    
    # Start monitoring in background
    monitor_and_restart "$app_pid" &
    local monitor_pid=$!
    
    # Wait for the app to finish
    wait "$app_pid"
    local exit_code=$?
    
    # Stop monitoring
    kill "$monitor_pid" 2>/dev/null
    wait "$monitor_pid" 2>/dev/null
    
    if [ "$stop_loop" = "false" ]; then
        if [ $exit_code -ne 0 ]; then
            echo ">> Python process crashed! Exit code: $exit_code"
        fi
        echo ">> Restarting in $RESTART_DELAY seconds..."
        sleep "$RESTART_DELAY"
    fi
done

echo ">> Exited."