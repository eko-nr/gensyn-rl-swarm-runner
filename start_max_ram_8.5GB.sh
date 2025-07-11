sudo mkdir -p /sys/fs/cgroup/gensyn

# Set limits
echo 9126805504 | sudo tee /sys/fs/cgroup/gensyn/memory.max
echo max | sudo tee /sys/fs/cgroup/gensyn/memory.swap.max

python3 -m venv .venv

source .venv/bin/activate
# if not worked, then:
. .venv/bin/activate


# Add current process to cgroup
echo $$ | sudo tee /sys/fs/cgroup/gensyn/cgroup.procs

./run_unless_stop.sh