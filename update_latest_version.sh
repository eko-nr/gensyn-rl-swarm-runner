ROOT="$HOME"/app
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $ROOT/rl-swarm

git pull

cd $SCRIPT_DIR