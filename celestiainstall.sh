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
echo "Updating package list..."
sudo apt update -y

# Install necessary dependencies
echo "Installing dependencies..."
sudo apt install -y curl build-essential git jq

# Check if Go is installed
if ! command -v go &> /dev/null; then
  echo "Go is not installed. Installing Go version 1.23.0..."
  GO_VERSION="1.23.2"
  wget "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
  echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
  source ~/.bashrc
  echo "Go version $GO_VERSION installed successfully."
else
  echo "Go is already installed. Skipping Go installation."
fi

# Verify Go installation
go version

# Clone the Celestia Node repository
echo "Cloning Celestia Node repository..."
cd $HOME
git clone https://github.com/celestiaorg/celestia-node.git
cd celestia-node

# Build the Celestia binary
echo "Building Celestia binary..."
make build

# Verify Celestia installation
celestia version

# Initialize the light node
echo "Initializing the light node..."
celestia light init

# Start the light node with the specified gRPC endpoint
GRPC_ENDPOINT="rpc.celestia.pops.one"
P2P_NETWORK="celestia"
echo "Starting the light node with gRPC endpoint $GRPC_ENDPOINT and p2p network $P2P_NETWORK..."
celestia light start --core.ip $GRPC_ENDPOINT --p2p.network $P2P_NETWORK

echo "Celestia Light Node installation and setup complete!"