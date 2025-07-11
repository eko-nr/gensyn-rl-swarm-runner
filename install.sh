ROOT="$HOME"/app
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo chmod +x ./start.sh ./run_unless_stop.sh ./start_max_ram_8.5GB.sh

mkdir -p $ROOT && cd $ROOT

sudo apt update -y
apt install screen curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev  -y
apt install python3 python3-pip python3-venv python3-dev -y

# Check if Node.js exists
if node --version >/dev/null 2>&1; then
    echo "Node.js is already installed: $(node --version)"
else
    echo "Node.js not found. Installing..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt install -y nodejs
    node -v
    npm install -g yarn
    yarn -v
fi

if [ -d "$ROOT/rl-swarm" ]; then
    echo "Official gensyn rl-swarm is exist"
else
    echo "official gensyn rl-swarm doesn't exist, clonning..."
    git clone https://github.com/gensyn-ai/rl-swarm
fi

cd $SCRIPT_DIR