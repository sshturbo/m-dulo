#!/bin/bash

# Atualizando e atualizando os pacotes
sudo apt update
sudo apt upgrade -y

# Verificando e instalando o Node.js se necessário
if ! command -v node > /dev/null 2>&1; then
    echo "Node.js não está instalado. Instalando..."
    wget https://raw.githubusercontent.com/sshturbo/m-dulo/main/nodesource_setup.sh -O nodesource_setup.sh
    chmod +x nodesource_setup.sh
    sudo ./nodesource_setup.sh
    sudo apt-get install -y nodejs
else
    echo "Node.js já está instalado."
fi

# Verificando e instalando o npm se necessário
if ! command -v npm > /dev/null 2>&1; then
    echo "npm não está instalado. Instalando..."
    sudo apt install npm
else
    echo "npm já está instalado."
fi

# Verificando e instalando o dos2unix se necessário
if ! command -v dos2unix > /dev/null 2>&1; then
    echo "dos2unix não está instalado. Instalando..."
    sudo apt install dos2unix
else
    echo "dos2unix já está instalado."
fi
