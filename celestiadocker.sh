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

# Install Docker if not present
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

# Create user and group for Celestia node
echo "===================================================="
echo "Creating user and group for Celestia node..."
echo "===================================================="
sudo groupadd -f celestia
sudo useradd -g celestia -m celestia

# Setup Celestia node directory and permissions
echo "===================================================="
echo "Setting up Celestia node directory..."
echo "===================================================="
sudo mkdir -p /home/celestia/celestia-node
sudo chown celestia:celestia /home/celestia/celestia-node

# Initialize the node store and key
echo "===================================================="
echo "Initializing Celestia node..."
echo "===================================================="
sudo docker run -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
  -v /home/celestia/celestia-node:/home/celestia \
  ghcr.io/celestiaorg/celestia-node:v0.17.2 \
  celestia light init --p2p.network $NETWORK

# Start the Celestia node
echo "===================================================="
echo "Starting Celestia Light Node..."
echo "===================================================="
sudo docker run -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
  -v /home/celestia/celestia-node:/home/celestia \
  ghcr.io/celestiaorg/celestia-node:v0.17.2 \
  celestia light start --core.ip $RPC_URL --p2p.network $NETWORK

echo "===================================================="
echo "Celestia Light Node setup complete!"
echo "===================================================="
