# Gensyn RL Swarm Runner

This repository makes it easy to manage and run a Gensyn node for `rl-swarm`. It simplifies setup, execution, and monitoring of your local node.

## 🔧 System Requirements

### Recommended Specifications
- **RAM**: 24 GB
- **CPU**: 4 physical cores (e.g., quad-core processor)
- **Storage**: 60 GB SSD (solid-state drive)
- **Operating System**: Ubuntu 22.04 (recommended) or other Linux distributions with support for Docker and Python 3.8+

### Low Specification Support
- **RAM**: 10 GB (requires 20GB swap space)
- **CPU**: 4 physical cores (e.g., quad-core processor)
- **Storage**: 60 GB SSD (solid-state drive)
- **Operating System**: Ubuntu 22.04 (recommended) or other Linux distributions with support for Docker and Python 3.8+

## 📦 Installation

Clone this repository:

```bash
git clone https://github.com/eko-nr/gensyn-rl-swarm-runner.git
cd gensyn-rl-swarm-runner
sudo sh ./install.sh
```

## 🚀 Running the Application

### Standard Setup (RAM ≥ 20GB)

1. Create a new screen session named `gensyn`:
   ```bash
   screen -S gensyn
   ```

2. Start the application:
   ```bash
   ./start.sh
   ```

3. To detach from the screen session, press `Ctrl+A` then `D`

4. To reattach to the screen session later:
   ```bash
   screen -r gensyn
   ```

### Low Specification Setup (RAM = 10GB)

If your VPS has lower specifications (RAM = 10GB), you can use the memory-optimized version:

1. **Important**: First, create a swap file of at least 20GB:
   ```bash
   # Create 20GB swap file
   sudo fallocate -l 20G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   
   # Set swappiness to 10 for better performance
   sudo sysctl vm.swappiness=10
   echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
   
   # Make swap permanent
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   ```

2. Create a screen session:
   ```bash
   screen -S gensyn
   ```

3. Start the application with memory optimization:
   ```bash
   ./start_max_ram_8GB.sh
   ```

### Managing Screen Sessions

- **List all screen sessions**: `screen -ls`
- **Detach from current session**: `Ctrl+A` then `D`
- **Reattach to session**: `screen -r gensyn`
- **Kill session**: `screen -X -S gensyn quit`

## 📊 Monitoring

Once running, you can monitor your node's performance and status through the application interface. The screen session will maintain the process running in the background, allowing you to safely disconnect from your VPS while keeping the node operational.

## 🛠️ Additional Commands

### Swarm Manager
The swarm manager utility helps you manage your swarm.pem file and related configurations:

#### 1. Find Swarm.pem
Search for swarm.pem files in the /root directory:

```bash
sh ./swarm_manager/find_swarm.sh
```

This command will:
- Scan the entire /root directory for swarm.pem files
- Display all found swarm.pem files with their locations

#### 2. Backup Swarm.pem
Create a backup of your current swarm.pem file:

```bash
sh ./swarm_manager/backup_swarm.sh
```

This command will:
- Automatically backup your swarm.pem
- Create a timestamped backup in the `./backup` directory

**Backup directory structure:**
```
backup/
├── swarm.pem
```

#### 3. Recovery Swarm.pem
Recover/restore an old swarm.pem file from backups:

```bash
sh ./swarm_manager/recovery_swarm.sh
```

This command will:
- Restore your old swarm.pem

### Version Updater
The version updater automatically updates your rl-swarm to the latest version:

```bash
sh ./version_updater/update_latest_version.sh
```

**Update Process:**
1. Clone the latest rl-swarm version
2. Apply updates while preserving your settings

## 🔧 Troubleshooting

If you encounter issues:

1. Check if the screen session is still running: `screen -ls`
2. Reattach to the session to view logs: `screen -r gensyn`
3. Ensure all system requirements are met
4. For low-spec setups (8GB RAM), verify that swap space is properly configured: `free -h`
5. Use swarm manager to validate your configuration: `./swarm_manager.sh --validate`
6. Check for updates: `./version_updater.sh`

### Common Issues

**Swarm.pem Issues:**
- Invalid or corrupted swarm.pem file: Use `sh ./swarm_manager/find_swarm.sh` to locate files
- Missing swarm.pem file: Use `sh ./swarm_manager/find_swarm.sh` to search for existing files
- Need to backup current configuration: Use `sh ./swarm_manager/backup_swarm.sh`
- Need to restore previous configuration: Use `sh ./swarm_manager/recovery_swarm.sh`
- Permission issues: Ensure proper file permissions with `chmod 600 swarm.pem`

**Version Issues:**
- Outdated rl-swarm version: Use `./version_updater.sh --update`

## 📝 Notes

- Always use screen sessions when running on a VPS to prevent process termination when SSH connection is lost
- For production deployments, consider using systemd services for automatic startup and management
- Monitor your system resources regularly to ensure optimal performance
- Keep regular backups of your swarm.pem file using `sh ./swarm_manager/backup_swarm.sh`
- Check for updates regularly to ensure you're running the latest version of rl-swarm
- The swarm manager automatically creates timestamped backups in the backup/ directory
- Version updater maintains a rollback capability for the last 3 versions

## 🔒 Security Recommendations

- Regularly backup your swarm.pem file using `sh ./swarm_manager/backup_swarm.sh`
- Keep your rl-swarm version updated with `./version_updater.sh --update`
- Store backups of swarm.pem in a secure location (backups are saved in backup/ directory)
- Monitor logs regularly for any suspicious activity
- Use strong passwords and SSH keys for VPS access
- Use recovery function when needed with `sh ./swarm_manager/recovery_swarm.sh`

## 📞 Support

For additional support or questions:
- Check the troubleshooting section above
- Review logs in the screen session
- Validate your configuration using the swarm manager
- Ensure you're running the latest version