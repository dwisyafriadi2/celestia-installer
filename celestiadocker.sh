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

# Update the package list
echo "===================================================="
echo ""
echo "Updating package list..."
echo "===================================================="
echo ""
sudo apt update -y

# Install necessary dependencies
echo "===================================================="
echo ""
echo "Installing dependencies..."
echo "===================================================="
echo ""
sudo apt install -y curl build-essential git jq

# Check if Docker is installed
if ! command -v sudo docker &> /dev/null; then
  echo "===================================================="
  echo ""
  echo "Docker not found. Installing Docker..."
  echo "===================================================="
  echo ""
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker $USER
  echo "===================================================="
  echo ""
  echo "Docker installed successfully. Please log out and log back in to apply group changes."
  echo "===================================================="
  echo ""
  exit 0
else
  echo "===================================================="
  echo ""
  echo "Docker is already installed."
  echo "===================================================="
  echo ""
fi

# Set environment variables
export NETWORK=celestia
export NODE_TYPE=light
export RPC_URL=rpc.celestia.pops.one

# Create a directory for persistent storage
echo "===================================================="
echo ""
echo "Creating directory for persistent storage..."
echo "===================================================="
echo ""
mkdir -p $HOME/celestia-node
sudo chown 10001:10001 $HOME/celestia-node

# Initialize the node store and key
echo "===================================================="
echo ""
echo "Initializing the node store and key..."
echo "===================================================="
echo ""
docker run -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
  -v $HOME/celestia-node:/home/celestia \
  ghcr.io/celestiaorg/celestia-node:v0.17.2 \
  celestia light init --p2p.network $NETWORK

# Start the node
echo "===================================================="
echo ""
echo "Starting the Celestia Light Node..."
echo "===================================================="
echo ""
docker run -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
  -v $HOME/celestia-node:/home/celestia \
  ghcr.io/celestiaorg/celestia-node:v0.17.2 \
  celestia light start --core.ip $RPC_URL --p2p.network $NETWORK

echo "===================================================="
echo ""
echo "Celestia Light Node installation and setup complete!"
echo "===================================================="
echo ""
