ROOT="$HOME"/app
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

chmod +x ./start.sh ./run_unless_stop.sh

mkdir -p $ROOT && cd $ROOT

git clone https://github.com/gensyn-ai/rl-swarm


cd $SCRIPT_DIR