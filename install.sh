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


# Verifica se o diretório /opt/myapp/ existe
if [ -d "/opt/myapp/" ]; then
    echo "Diretório /opt/myapp/ já existe. Parando e excluindo processo do PM2 se existir..."
    
    # Parar e deletar o processo do PM2 se estiver em execução
    pm2 stop modulos-pro &>/dev/null
    pm2 delete modulos-pro &>/dev/null

    echo "Excluindo arquivos e pastas antigos..."
    sudo rm -rf /opt/myapp/
else
    echo "Diretório /opt/myapp/ não existe. Criando..."
fi

# Criar o diretório para o aplicativo
sudo mkdir -p /opt/myapp/

# Baixar o ZIP do repositório ModulosPro diretamente no diretório /opt/myapp/
echo "Baixando modulos-pro..."
sudo wget -P /opt/myapp/ https://github.com/sshturbo/m-dulo/raw/main/modulos-prov2.zip

# Extrair o ZIP diretamente no diretório /opt/myapp/ e remover o arquivo ZIP após a extração
echo "Extraindo arquivos..."
sudo unzip /opt/myapp/modulos-prov2.zip -d /opt/myapp/ && sudo rm /opt/myapp/modulos-prov2.zip

# Dar permissão de execução para scripts .sh
echo "Atualizando permissões..."
files=(
    "SshturboMakeAccount.sh"
    "ExcluirExpiradoApi.sh"
    "killuser.sh"
)

for file in "${files[@]}"; do
    sudo chmod +x /opt/myapp/"$file"
    # Converter para o formato Unix (se necessário)
    dos2unix /opt/myapp/"$file"
done

# Instalar dependências, executar build e iniciar o serviço apenas se o diretório existir e o clone for bem-sucedido
if [ -d "/opt/myapp/" ]; then
    echo "Instalando dependências do package.json..."
    npm install --prefix /opt/myapp/

    # Iniciar o serviço
    npm start --prefix /opt/myapp/
    
    pm2 startup

    # Salvar a lista de processos do PM2
    pm2 save
else
    echo "Falha na instalação. Diretório /opt/myapp/ não encontrado."
fi