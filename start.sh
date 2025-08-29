if pm2 --version >/dev/null 2>&1; then
    echo "pm2 installed"
else
    npm i -g pm2
fi

pm2 start ./scripts/start_rl_swarm.sh --interpreter bash --name gensyn-rl-swarm
pm2 startup && pm2 save