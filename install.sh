SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RL_SWARM="$SCRIPT_DIR/rl-swarm"

sudo chmod +x ./login.sh ./start.sh ./start_min_specs.sh ./start_max_ram_8GB.sh ./start_max_ram_12GB.sh 
sudo chmod +x ./scripts/login_rl_swarm.sh ./scripts/start_rl_swarm.sh

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
fi

npm install -g yarn
yarn -v
npm instal -g pm2
npm instal -g cloudflared

if [ -d "$RL_SWARM" ]; then
    echo "Official gensyn rl-swarm is exist"
else
    echo "official gensyn rl-swarm doesn't exist, clonning..."
    git clone https://github.com/gensyn-ai/rl-swarm
fi

python3 -m venv .venv

source .venv/bin/activate
# if not worked, then:
. .venv/bin/activate

echo ">> Getting requirements..."
pip install --upgrade pip

echo ">> Installing GenRL..."
pip install gensyn-genrl==0.1.4
pip install reasoning-gym>=0.1.20 # for reasoning gym env
pip install trl # for grpo config, will be deprecated soon
pip install hivemind@git+https://github.com/gensyn-ai/hivemind@639c964a8019de63135a2594663b5bec8e5356dd # We need the latest, 1.1.11 is broken

# fix conflict for current deps
pip install --force-reinstall transformers==4.51.3 trl==0.19.1
pip freeze