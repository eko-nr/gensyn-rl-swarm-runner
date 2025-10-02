# Gensyn RL Swarm Runner

This repository makes it easy to manage and run a Gensyn node for `rl-swarm`. It simplifies setup, execution, and monitoring of your local node.

## 🔧 System Requirements

### Good Specifications
- **RAM**: 24 GB
- **CPU**: 4 physical cores (e.g., quad-core processor)
- **Storage**: 60 GB SSD (solid-state drive)
- **Operating System**: Ubuntu 22.04 (recommended) or other Linux distributions with support for Docker and Python 3.8+

### Low Specification Support
- **RAM**: 8 GB (requires 20GB swap space)
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

### Standard Setup (RAM ≥ 20GB, everything works good)

1. Login to your account:
   ```bash
   ./login.sh
   ```

2. (Optional) Configure your environment:
   ```bash
   # Edit .env file if you want to change default settings
   nano .env
   ```

3. Start the application:
   ```bash
   ./start.sh
   ```

### Middle Specification Setup (RAM ≥ 12GB, stable, almost get the same training rewards as above, highly recommended)

If your VPS has lower specifications (RAM >= 12GB, e.g. 14GB), you can use the memory-optimized version:

1. **Important**: First, create a swap file of at least 20GB:
   ```bash
   # Create 20GB swap file
   sudo fallocate -l 20G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   
   # Set swappiness to 25 for better performance
   sudo sysctl vm.swappiness=25
   echo 'vm.swappiness=25' | sudo tee -a /etc/sysctl.conf
   
   # Make swap permanent
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   ```

2. Login to your account:
   ```bash
   ./login.sh
   ```

3. (Optional) Configure your environment:
   ```bash
   # Edit .env file if you want to change default settings
   nano .env
   ```

4. Start the application with memory optimization:
   ```bash
   ./start_max_ram_14GB.sh
   ```

### Low Specification Setup (RAM = 8GB, cheaper, lowest training reward, unstable, only won in participation numbers)

If your VPS has lower specifications (RAM = 8GB), you can use the memory-optimized version:

1. **Important**: First, create a swap file of at least 20GB:
   ```bash
   # Create 20GB swap file
   sudo fallocate -l 20G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   
   # Set swappiness to 25 for better performance
   sudo sysctl vm.swappiness=25
   echo 'vm.swappiness=25' | sudo tee -a /etc/sysctl.conf
   
   # Make swap permanent
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   ```

2. Login to your account:
   ```bash
   ./login.sh
   ```

3. (Optional) Configure your environment:
   ```bash
   # Edit .env file if you want to change default settings
   nano .env
   ```

4. Start the application with memory optimization:
   ```bash
   ./start_min_specs.sh
   ```

### Managing App

1. Mid-to-high specification setup:
- **Checking logs**: `pm2 logs --lines 200`
- **Kill rl-swarm**: `pm2 kill`
- **Restart rl-swarm**: `pm2 reload all`

2. Low specs:
- **Checking logs**: `journalctl -u gensyn-rl-swarm -fn 200 -o cat`
- **Stop rl-swarm**: `systemctl stop gensyn-rl-swarm`
- **Restart rl-swarm**: `systemctl restart gensyn-rl-swarm`

## 🔄 Version Updater (for the latest rl-swarm version update)

The version updater automatically updates your rl-swarm to the latest version:

```bash
sh ./version_updater/update_latest_version.sh
```

**Update Process:**
1. Clone the latest rl-swarm version
2. Apply updates while preserving your settings and .env configuration
3. Restart your rl-swarm

## ⚙️ Configuration

### Environment Configuration (.env)

The application now uses a `.env` file to manage rl-swarm configuration. The default configuration includes:

```env
MODEL_NAME="Gensyn/Qwen2.5-0.5B-Instruct"
HUGGINGFACE_ACCESS_TOKEN="None"
PRG_GAME=true
```

**Configuration Options:**

- **`MODEL_NAME`**: Specifies the AI model to use for training
  - Default: `"Gensyn/Qwen2.5-0.5B-Instruct"`
  - **Available open models that can be used directly:**
    - `"Gensyn/Qwen2.5-0.5B-Instruct"` (default, recommended for low specs)
    - `"Qwen/Qwen3-0.6B"` (small, efficient)
    - `"nvidia/AceInstruct-1.5B"` (good balance of size and performance)
    - `"dnotitia/Smoothie-Qwen3-1.7B"` (enhanced performance)
    - `"Gensyn/Qwen2.5-1.5B-Instruct"` (higher performance, requires more RAM)

- **`HUGGINGFACE_ACCESS_TOKEN`**: Your Hugging Face access token for private models
  - Default: `"None"` (for public models)
  - Set this if you need to access private models or increase rate limits

- **`PRG_GAME`**: Enables or disables the PRG game mode
  - Default: `true`
  - Set to `false` to disable game mode

### Editing Configuration

To modify the configuration:

```bash
# Edit the .env file
nano .env

# Or use your preferred text editor
vim .env
```

**Example configurations:**

For different open models:
```env
# Lightweight model for low specs
MODEL_NAME="Gensyn/Qwen2.5-0.5B-Instruct"
HUGGINGFACE_ACCESS_TOKEN="None"
PRG_GAME=true

# Slightly larger model
MODEL_NAME="Qwen/Qwen3-0.6B"
HUGGINGFACE_ACCESS_TOKEN="None"
PRG_GAME=true

# Balanced performance model
MODEL_NAME="nvidia/AceInstruct-1.5B"
HUGGINGFACE_ACCESS_TOKEN="None"
PRG_GAME=true

# Enhanced performance model
MODEL_NAME="dnotitia/Smoothie-Qwen3-1.7B"
HUGGINGFACE_ACCESS_TOKEN="None"
PRG_GAME=true

# Higher performance model (requires more RAM)
MODEL_NAME="Gensyn/Qwen2.5-1.5B-Instruct"
HUGGINGFACE_ACCESS_TOKEN="None"
PRG_GAME=true
```

For private model access:
```env
MODEL_NAME="your-org/private-model"
HUGGINGFACE_ACCESS_TOKEN="hf_your_actual_token"
PRG_GAME=false
```

### Model Selection Guide

**For Low Specs (8GB RAM):**
- `"Gensyn/Qwen2.5-0.5B-Instruct"` (recommended)
- `"Qwen/Qwen3-0.6B"`

**For Middle Specs (12-14GB RAM):**
- `"nvidia/AceInstruct-1.5B"` (recommended)
- `"dnotitia/Smoothie-Qwen3-1.7B"`

**For High Specs (20GB+ RAM):**
- `"Gensyn/Qwen2.5-1.5B-Instruct"` (recommended for best performance)
- Any of the above models

## 📊 Monitoring

Once running, you can monitor your node's performance and status through the application interface. The screen session will maintain the process running in the background, allowing you to safely disconnect from your VPS while keeping the node operational.

## 🛠️ Additional Commands

### Configuration Management
View current configuration:
```bash
# Display current .env configuration
cat .env
```

Reset to default configuration:
```bash
# Backup current config and reset to defaults
cp .env .env.backup
echo 'MODEL_NAME="Gensyn/Qwen2.5-0.5B-Instruct"' > .env
echo 'HUGGINGFACE_ACCESS_TOKEN="None"' >> .env
echo 'PRG_GAME=true' >> .env
```

Switch to a different model:
```bash
# Example: Switch to nvidia/AceInstruct-1.5B
cp .env .env.backup
echo 'MODEL_NAME="nvidia/AceInstruct-1.5B"' > .env
echo 'HUGGINGFACE_ACCESS_TOKEN="None"' >> .env
echo 'PRG_GAME=true' >> .env
```

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

### Common Issues

**Configuration Issues:**
- Invalid model name: Use one of the supported open models listed in the configuration section
- Model too large for your specs: Choose a smaller model based on the model selection guide
- Authentication errors: Verify your `HUGGINGFACE_ACCESS_TOKEN` in `.env` (use "None" for open models)
- Permission denied: Ensure `.env` file has proper permissions (`chmod 600 .env`)
- Out of memory errors: Switch to a smaller model or increase swap space

**Swarm.pem Issues:**
- Invalid or corrupted swarm.pem file: Use `sh ./swarm_manager/find_swarm.sh` to locate files
- Missing swarm.pem file: Use `sh ./swarm_manager/find_swarm.sh` to search for existing files
- Need to backup current configuration: Use `sh ./swarm_manager/backup_swarm.sh`
- Need to restore previous configuration: Use `sh ./swarm_manager/recovery_swarm.sh`
- Permission issues: Ensure proper file permissions with `chmod 600 swarm.pem`

**Version Issues:**
- Outdated rl-swarm version: Use `sh ./version_updater/update_latest_version.sh`

## 📝 Notes

- The `.env` file is automatically loaded when starting the application
- Configuration changes require a restart to take effect
- Always backup your `.env` file before making major changes
- Always use screen sessions when running on a VPS to prevent process termination when SSH connection is lost
- For production deployments, consider using systemd services for automatic startup and management
- Monitor your system resources regularly to ensure optimal performance
- Keep regular backups of your swarm.pem file using `sh ./swarm_manager/backup_swarm.sh`
- Check for updates regularly to ensure you're running the latest version of rl-swarm
- The swarm manager automatically creates timestamped backups in the backup/ directory
- Version updater maintains a rollback capability for the last 3 versions

## 🔒 Security Recommendations

- Keep your `.env` file secure and never share your `HUGGINGFACE_ACCESS_TOKEN`
- Set appropriate file permissions for `.env`: `chmod 600 .env`
- Regularly backup your swarm.pem file using `sh ./swarm_manager/backup_swarm.sh`
- Keep your rl-swarm version updated with `sh ./version_updater/update_latest_version.sh`
- Store backups of swarm.pem in a secure location (backups are saved in backup/ directory)
- Monitor logs regularly for any suspicious activity
- Use strong passwords and SSH keys for VPS access
- Use recovery function when needed with `sh ./swarm_manager/recovery_swarm.sh`
- Never commit `.env` files to version control if they contain sensitive tokens