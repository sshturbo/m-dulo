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

# Verificando e instalando o PM2 se necessário
if ! command -v pm2 > /dev/null 2>&1; then
    echo "PM2 não está instalado. Instalando..."
    sudo npm install pm2@latest -g
else
    echo "PM2 já está instalado."
fi

# Baixando, dando permissão e executando o arquivo install.sh
echo "Baixando e executando install.sh..."
wget https://raw.githubusercontent.com/sshturbo/m-dulo/main/install.sh -O install.sh
chmod +x install.sh
sudo ./install.sh
