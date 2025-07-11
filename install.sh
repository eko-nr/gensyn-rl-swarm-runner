ROOT="$HOME"/app
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

chmod +x ./start.sh ./run_unless_stop.sh

mkdir -p $ROOT && cd $ROOT

apt install screen curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev  -y
apt install python3 python3-pip python3-venv python3-dev -y

git clone https://github.com/gensyn-ai/rl-swarm


cd $SCRIPT_DIR