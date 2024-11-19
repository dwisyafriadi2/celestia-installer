#!/bin/bash

# Set environment variables
export NETWORK=celestia
export NODE_TYPE=light
export RPC_URL=http://public-celestia-consensus.numia.xyz

# Run Celestia Light Node start command in detached mode
echo "Running Celestia Light Node start..."
docker run -d -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
    ghcr.io/celestiaorg/celestia-node:v0.17.2 \
    celestia $NODE_TYPE start --core.ip $RPC_URL --p2p.network $NETWORK

# Wait 10 seconds
echo "Waiting for 10 seconds..."
sleep 10

# Get the container ID of the running container
CONTAINER_ID=$(docker ps -q --filter ancestor=ghcr.io/celestiaorg/celestia-node:v0.17.2)

# Check if the container is running, then stop it
if [ -n "$CONTAINER_ID" ]; then
    echo "Stopping the Celestia Light Node container..."
    docker stop $CONTAINER_ID
else
    echo "No running container found!"
fi

# Save logs to generateaddress.log
echo "Saving logs to generateaddress.log..."
docker logs $CONTAINER_ID > generateaddress.log

# Create my-node-store directory if not exist, remove if exist
echo "Creating and setting up my-node-store directory..."
cd $HOME
if [ -d "$HOME/my-node-store" ]; then
    echo "Directory already exists. Removing..."
    sudo rm -rf $HOME/my-node-store
fi
cd $HOME
mkdir my-node-store
cd $HOME
# Ensure correct permissions for my-node-store directory
echo "Setting ownership for my-node-store..."
sudo chown -R $USER:$USER $HOME/my-node-store
sudo chown 10001:10001 $HOME/my-node-store

# Initialize the node store and key
echo "Initializing the node store..."
docker run -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
    -v $HOME/my-node-store:/home/celestia \
    ghcr.io/celestiaorg/celestia-node:v0.17.2 \
    celestia light init --p2p.network $NETWORK

# Start the Celestia node in the background and save logs
echo "Starting Celestia Light Node..."
docker run -d -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
    -v $HOME/my-node-store:/home/celestia \
    ghcr.io/celestiaorg/celestia-node:v0.17.2 \
    celestia light start --core.ip $RPC_URL --p2p.network $NETWORK

# Save the background logs to celestia.log
echo "Saving Celestia Light Node logs to celestia.log..."
docker logs $(docker ps -q --filter ancestor=ghcr.io/celestiaorg/celestia-node:v0.17.2) > celestia.log

echo "Process complete!"

