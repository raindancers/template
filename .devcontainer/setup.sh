#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Debug: pwd=$(pwd), user=$(whoami), home=$HOME, script_dir=$SCRIPT_DIR" > /home/node/setup.log
echo 'Starting setup...' >> /home/node/setup.log

# Fix ownership on volume-mounted directories (Docker creates them as root)
sudo chown -R node:node /home/node/.kiro /home/node/.local 2>/dev/null || true
mkdir -p /home/node/.local/bin /home/node/.local/share/kiro-cli

# Run individual setup scripts with error handling using absolute paths
if "$SCRIPT_DIR/scripts/git-setup.sh"; then
    echo 'Git setup done' >> /home/node/setup.log
else
    echo 'Git setup failed' >> /home/node/setup.log
fi

if "$SCRIPT_DIR/scripts/aws-setup.sh"; then
    echo 'AWS setup done' >> /home/node/setup.log
else
    echo 'AWS setup failed' >> /home/node/setup.log
fi

if "$SCRIPT_DIR/scripts/uvx-setup.sh"; then
    echo 'uvx setup done' >> /home/node/setup.log
else
    echo 'uvx setup failed' >> /home/node/setup.log
fi

if "$SCRIPT_DIR/scripts/kiro-setup.sh"; then
    echo 'Kiro CLI setup done' >> /home/node/setup.log
else
    echo 'Kiro CLI setup failed' >> /home/node/setup.log
fi

if "$SCRIPT_DIR/scripts/mcp-setup.sh"; then
    echo 'MCP setup done' >> /home/node/setup.log
else
    echo 'MCP setup failed' >> /home/node/setup.log
fi

echo 'Setup completed successfully' >> /home/node/setup.log
