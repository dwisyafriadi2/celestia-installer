#!/bin/bash

# Function to print the banner
print_banner() {
  clear
  echo """
    ____                       
   / __ \____ __________ ______
  / / / / __ \`/ ___/ __ \`/ ___/
 / /_/ / /_/ (__  ) /_/ / /    
/_____/_\\__,_/____/\\__,_/_/     

    ____                       __
   / __ \___  ____ ___  __  __/ /_  ______  ____ _
  / /_/ / _ \\/ __ \`__ \\/ / / / / / / / __ \\/ __ \`/
 / ____/  __/ / / / / / /_/ / / /_/ / / / / /_/ / 
/_/    \\___/_/ /_/ /_/\\__,_/_/\\__,_/_/ /_/\\__, /  
                                         /____/    

====================================================
     Automation         : Auto Install Node
     Telegram Channel   : @dasarpemulung
     Telegram Group     : @parapemulung
     Date and Time      : $(date)
====================================================
"""
}

# Call the print_banner function
print_banner

# Update and install dependencies
echo "===================================================="
echo "Updating system and installing dependencies..."
echo "===================================================="
sudo apt update -y
sudo apt install -y curl build-essential git jq

# Check if Docker is installed
echo "===================================================="
echo "Checking Docker installation..."
echo "===================================================="
if ! command -v docker &> /dev/null; then
  echo "Docker not found. Installing..."
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker $USER
  echo "Docker installed successfully. Please log out and log back in."
  exit 0
else
  echo "Docker is already installed."
fi

# Set environment variables
export NETWORK=celestia
export NODE_TYPE=light
export RPC_URL=rpc.celestia.pops.one

# Set the appropriate directory based on whether it's root or a user
echo "===================================================="
echo "Creating Celestia node directory..."
echo "===================================================="
if [ "$(id -u)" -eq 0 ]; then
  # If running as root, use /root
  NODE_DIR="/root/celestia-node"
  CEL_DIR="/root/celestia"
else
  # If running as a regular user, use /home/<user>
  NODE_DIR="/home/$USER/celestia-node"
  CEL_DIR="/home/$USER/celestia"
fi

# Create the directories and set the correct ownership
sudo mkdir -p $NODE_DIR
sudo mkdir -p $CEL_DIR
sudo chown -R $USER:$USER $NODE_DIR
sudo chown -R $USER:$USER $CEL_DIR

# Create the celestia-node-data directory as per the documentation
echo "===================================================="
echo "Creating celestia-node-data directory..."
echo "===================================================="
mkdir -p $HOME/celestia-node-data

# Set the ownership of the created directory
echo "===================================================="
echo "Setting ownership of celestia-node-data directory..."
echo "===================================================="
sudo chown 10001:10001 $HOME/celestia-node-data

# Initialize the node store and key
echo "===================================================="
echo "Initializing the node store and key..."
echo "===================================================="
sudo docker run -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
  -v $CEL_DIR:/home/celestia \
  ghcr.io/celestiaorg/celestia-node:v0.17.2 \
  celestia light init --p2p.network $NETWORK

# Start the Celestia node
echo "===================================================="
echo "Starting Celestia Light Node..."
echo "===================================================="
sudo docker run -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
  -v $CEL_DIR:/home/celestia \
  ghcr.io/celestiaorg/celestia-node:v0.17.2 \
  celestia light start --core.ip $RPC_URL --p2p.network $NETWORK

echo "===================================================="
echo "Celestia Light Node setup complete!"
echo "===================================================="
