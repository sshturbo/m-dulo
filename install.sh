#!/bin/bash


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

# Baixar o ZIP do repositório ModulosPro
echo "Baixando modulos-pro..."
wget https://github.com/sshturbo/m-dulo/raw/main/Modulos-pro-V1.0.0.zip

# Extrair o ZIP diretamente no diretório /opt/myapp/
echo "Extraindo arquivos..."
sudo unzip /opt/myapp/Modulos-pro-V1.0.0.zip -d /opt/myapp/ && sudo rm /opt/myapp/Modulos-pro-V1.0.0.zip

# Dar permissão de execução para scripts .sh
echo "Atualizando permissões..."
files=(
    "SshturboMakeAccount.sh"
    "ExcluirExpiradoApi.sh"
    "killuser.sh"
    "install.sh"
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

    # Executar build
    echo "Executando npm run build..."
    npm run build --prefix /opt/myapp/

    # Iniciar o serviço
    npm start --prefix /opt/myapp/
    
    pm2 startup

    # Salvar a lista de processos do PM2
    pm2 save --force
    pm2 save
else
    echo "Falha na instalação. Diretório /opt/myapp/ não encontrado."
fi