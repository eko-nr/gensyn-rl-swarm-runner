#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
SERVICE_NAME="gensyn-rl-swarm"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
START_SCRIPT="${PROJECT_DIR}/scripts/start_rl_swarm.sh"

# Check if systemd is available
if ! pidof systemd > /dev/null; then
  echo "❌ systemd is not running on this system. Exiting."
  exit 1
fi

# Create systemd service
echo "🔧 Creating systemd service: $SERVICE_NAME"

sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Run Gensyn RL Swarm Script
After=network.target

[Service]
Type=simple
WorkingDirectory=${PROJECT_DIR}
ExecStart=/bin/bash ${START_SCRIPT}
Restart=always
RestartSec=5
MemoryMax=7216192768
MemorySwapMax=infinity
CPUQuota=352%

[Install]
WantedBy=multi-user.target
EOF

# Reload and start the service
echo "🔄 Reloading systemd daemon..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

echo "✅ Enabling and starting ${SERVICE_NAME}..."
sudo systemctl enable --now "$SERVICE_NAME"

# Final confirmation
echo "✅ Service '${SERVICE_NAME}' has been created and started successfully!"
echo "📄 To check logs: journalctl -u ${SERVICE_NAME} -f"