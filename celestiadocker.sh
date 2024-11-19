#!/bin/bash

# Display the banner from the given URL
echo -e '\n\e[42mDisplay Banner\e[0m\n' && sleep 1
sleep 1 && curl -s https://raw.githubusercontent.com/dwisyafriadi2/celestia-installer/refs/heads/main/banner.sh | bash && sleep 1

# Set environment variables
export NETWORK=celestia
export NODE_TYPE=light
export RPC_URL=http://public-celestia-consensus.numia.xyz

# Inform user about running the Celestia Light Node
echo -e '\n\e[42mRunning Celestia Light Node start...\e[0m\n' && sleep 1
docker run -d -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
    ghcr.io/celestiaorg/celestia-node:v0.17.2 \
    celestia $NODE_TYPE start --core.ip $RPC_URL --p2p.network $NETWORK

# Wait 10 seconds for initialization
echo -e '\n\e[42mWaiting for 10 seconds...\e[0m\n' && sleep 10

# Get the container ID of the running container
CONTAINER_ID=$(docker ps -q --filter ancestor=ghcr.io/celestiaorg/celestia-node:v0.17.2)

# Check if the container is running, then stop it
if [ -n "$CONTAINER_ID" ]; then
    echo -e '\n\e[42mStopping Celestia Light Node container...\e[0m\n' && sleep 1
    docker stop $CONTAINER_ID
else
    echo "No running container found!"
fi

# Save logs to generateaddress.log
echo -e '\n\e[42mSaving logs to generateaddress.log...\e[0m\n' && sleep 1
docker logs $CONTAINER_ID > generateaddress.log

# Create my-node-store directory if not exist, remove if exists
echo -e '\n\e[42mCreating and setting up my-node-store directory...\e[0m\n' && sleep 1
cd $HOME
if [ -d "$HOME/my-node-store" ]; then
    echo -e "Directory already exists. Removing..." && sleep 1
    sudo rm -rf $HOME/my-node-store
fi
mkdir my-node-store

# Ensure correct permissions for my-node-store directory
echo -e '\n\e[42mSetting ownership for my-node-store...\e[0m\n' && sleep 1
sudo chown -R $USER:$USER $HOME/my-node-store
sudo chown 10001:10001 $HOME/my-node-store

# Initialize the node store and key
echo -e '\n\e[42mInitializing the node store...\e[0m\n' && sleep 1
docker run -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
    -v $HOME/my-node-store:/home/celestia \
    ghcr.io/celestiaorg/celestia-node:v0.17.2 \
    celestia light init --p2p.network $NETWORK

# Start the Celestia node in the background and save logs
echo -e '\n\e[42mStarting Celestia Light Node...\e[0m\n' && sleep 1
docker run -d -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
    -v $HOME/my-node-store:/home/celestia \
    ghcr.io/celestiaorg/celestia-node:v0.17.2 \
    celestia light start --core.ip $RPC_URL --p2p.network $NETWORK

# Save the background logs to celestia.log
echo -e '\n\e[42mSaving Celestia Light Node logs to celestia.log...\e[0m\n' && sleep 1
docker logs $(docker ps -q --filter ancestor=ghcr.io/celestiaorg/celestia-node:v0.17.2) > celestia.log

echo -e '\n\e[42mProcess complete!\e[0m\n' && sleep 1
