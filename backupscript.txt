#!/bin/bash

# Fungsi untuk menampilkan banner
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

# Memanggil fungsi print_banner
print_banner

# Memeriksa apakah Docker sudah terinstal
install_docker() {
    echo "===================================================="
    echo "Memeriksa instalasi Docker..."
    echo "===================================================="
    if ! command -v docker &> /dev/null; then
        echo "===================================================="
        echo "Docker tidak ditemukan. Menginstal Docker..."
        echo "===================================================="
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker $USER
        echo "===================================================="
        echo "Docker berhasil diinstal. Silakan logout dan login kembali untuk menerapkan perubahan grup."
        echo "===================================================="
        exit 0
    else
        echo "===================================================="
        echo "Docker sudah terinstal."
        echo "===================================================="
    fi
}

# Memeriksa apakah Node.js sudah terinstal
install_nodejs() {
    echo "===================================================="
    echo "Memeriksa instalasi Node.js..."
    echo "===================================================="
    if ! command -v node &> /dev/null; then
        echo "===================================================="
        echo "Node.js tidak ditemukan. Menginstal Node.js..."
        echo "===================================================="
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
        echo "===================================================="
        echo "Node.js berhasil diinstal."
        echo "===================================================="
    else
        echo "===================================================="
        echo "Node.js sudah terinstal."
        echo "===================================================="
    fi
}

# Memeriksa apakah Docker Compose sudah terinstal
install_docker_compose() {
    echo "===================================================="
    echo "Memeriksa instalasi Docker Compose..."
    echo "===================================================="
    if ! command -v docker-compose &> /dev/null; then
        echo "===================================================="
        echo "Docker Compose tidak ditemukan. Menginstal Docker Compose..."
        echo "===================================================="
        curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        echo "===================================================="
        echo "Docker Compose berhasil diinstal."
        echo "===================================================="
    else
        echo "===================================================="
        echo "Docker Compose sudah terinstal."
        echo "===================================================="
    fi
}

# Mengatur dan menjalankan Celestia Light Node
setup_celestia_node() {
    echo "===================================================="
    echo "Mengatur Celestia Light Node..."
    echo "===================================================="
    export NETWORK=celestia
    export NODE_TYPE=light
    export RPC_URL=rpc.celestia.pops.one

    mkdir -p $HOME/celestia-node
    sudo chown 10001:10001 $HOME/celestia-node

    docker run -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
      -v $HOME/celestia-node:/home/celestia \
      ghcr.io/celestiaorg/celestia-node:v0.17.2 \
      celestia light init --p2p.network $NETWORK

    echo "===================================================="
    echo "Memulai Celestia Light Node..."
    echo "===================================================="
    docker run -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
      -v $HOME/celestia-node:/home/celestia \
      ghcr.io/celestiaorg/celestia-node:v0.17.2 \
      celestia light start --core.ip $RPC_URL --p2p.network $NETWORK

    echo "===================================================="
    echo "Instalasi dan pengaturan Celestia Light Node selesai!"
    echo "===================================================="
}

# Memulai proses instalasi
install_docker
install_nodejs
install_docker_compose
setup_celestia_node
