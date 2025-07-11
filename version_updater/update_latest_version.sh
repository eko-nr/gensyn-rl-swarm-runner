SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SWARM_RL_DIR="$(dirname "$SCRIPT_DIR")/rl-swarm" 

cd $SWARM_RL_DIR

git reset --hard HEAD
git pull