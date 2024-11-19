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

# Install Go (if not already installed)
GO_VERSION="1.23.0"
echo "Installing Go version $GO_VERSION..."
wget "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
source ~/.bashrc

# Clone the Celestia Node repository
echo "Cloning Celestia Node repository..."
cd $HOME
git clone https://github.com/celestiaorg/celestia-node.git
cd celestia-node

# Build the Celestia binary
echo "Building Celestia binary..."
make build

# Initialize the light node
echo "Initializing the light node..."
celestia light init

# Create a Systemd service file
echo "Creating Systemd service file..."
sudo tee /etc/systemd/system/celestia-lightd.service > /dev/null <<EOF
[Unit]
Description=Celestia Light Node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which celestia) light start --core.ip rpc.celestia.pops.one --p2p.network celestia
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Reload Systemd to recognize the new service
echo "Reloading Systemd..."
sudo systemctl daemon-reload

# Enable and start the Celestia Light Node service
echo "Enabling and starting Celestia Light Node service..."
sudo systemctl enable celestia-lightd
sudo systemctl start celestia-lightd

# Check the status of the service
echo "Checking the status of the Celestia Light Node service..."
sudo systemctl status celestia-lightd

echo "Celestia Light Node installation and setup complete!"
