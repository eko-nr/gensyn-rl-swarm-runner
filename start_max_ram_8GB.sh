#!/bin/bash

# Check if cgroup v2 is mounted
is_cgroup_v2() {
    [ -f /sys/fs/cgroup/cgroup.controllers ]
}

# Try to enable cgroup v2 on supported systems
enable_cgroup_v2() {
    echo ">> Trying to enable cgroup v2..."

    # Only attempt on GRUB-based distros with systemd
    if [ -f /etc/default/grub ] && command -v grub-mkconfig > /dev/null; then
        sudo sed -i 's/^GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=1 /' /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg

        echo ">> Updated GRUB. Please reboot the system to apply cgroup v2 changes."
    else
        echo ">> Your system doesn't support automatic cgroup v2 enabling via GRUB."
        echo ">> You may need to manually enable it via bootloader (e.g., add: systemd.unified_cgroup_hierarchy=1)."
    fi

    exit 0
}

# Main logic
if is_cgroup_v2; then
    echo "✅ cgroup v2 is already enabled."
else
    echo "⚠️  cgroup v2 is not enabled."

    # Ask user if they want to attempt enabling
    read -p "Do you want to try enabling it now? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        enable_cgroup_v2
    else
        echo "❌ Skipping cgroup v2 enabling."
    fi
fi

sudo mkdir -p /sys/fs/cgroup/gensyn
echo 8589934592 | sudo tee /sys/fs/cgroup/gensyn/memory.max
echo max | sudo tee /sys/fs/cgroup/gensyn/memory.swap.max

pm2 start ./scripts/start_rl_swarm.sh --interpreter bash --name gensyn-rl-swarm
sleep 2
pid=$(pm2 pid gensyn-rl-swarm)

echo "$pid" | sudo tee /sys/fs/cgroup/gensyn/cgroup.procs

pm2 startup && pm2 save