#!/bin/bash

# Verifica se o script está sendo executado como root
if [[ $EUID -ne 0 ]]; then
    echo "Este script deve ser executado como root"
    exit 1
fi

# Função para centralizar texto
print_centered() {
    term_width=$(tput cols)
    text="$1"
    padding=$(( (term_width - ${#text}) / 2 ))
    printf "%${padding}s" '' # Adiciona espaços antes do texto
    echo "$text"
}

# Função para simular uma barra de progresso
progress_bar() {
    echo -n "Progresso: ["
    for i in $(seq 1 $1); do
        echo -n "###"
        sleep 1
    done
    echo "] Completo!"
}

# Verificar se o Node.js já está instalado
if ! command -v node &> /dev/null
then
    print_centered "Node.js não está instalado. Instalando o Node.js..."
    sudo apt-get install -y nodejs &>/dev/null
    current_version=$(node -v | cut -d 'v' -f 2 | cut -d '.' -f 1)
    progress_bar 10
    print_centered "Node.js versão $current_version instalado com sucesso."
else
    current_version=$(node -v | cut -d 'v' -f 2 | cut -d '.' -f 1)
    print_centered "Node.js já está instalado. Versão atual: $current_version."
fi

# Verificando e instalando o npm se necessário
if ! command -v npm &> /dev/null; then
    print_centered "npm não está instalado. Instalando..."
    sudo apt install npm -y &>/dev/null
    progress_bar 5
else
    print_centered "npm já está instalado."
fi

# Verificando e instalando o dos2unix se necessário
if ! command -v dos2unix &> /dev/null; then
    print_centered "dos2unix não está instalado. Instalando..."
    sudo apt install dos2unix -y &>/dev/null
    progress_bar 5
else
    print_centered "dos2unix já está instalado."
fi

# Verificando e instalando o PM2 se necessário
if ! command -v pm2 &> /dev/null; then
    print_centered "PM2 não está instalado. Instalando..."
    npm install pm2@4.0.1 -g &>/dev/null
    progress_bar 5
else
    print_centered "PM2 já está instalado."
fi

# Verifica se o diretório /opt/myapp/ existe
if [ -d "/opt/myapp/" ]; then
    print_centered "Diretório /opt/myapp/ já existe. Parando e excluindo processo do PM2 se existir..."
    pm2 stop modulos-pro &>/dev/null
    pm2 delete modulos-pro &>/dev/null
    print_centered "Excluindo arquivos e pastas antigos..."
    sudo rm -rf /opt/myapp/
else
    print_centered "Diretório /opt/myapp/ não existe. Criando..."
fi

# Criar o diretório para o aplicativo
sudo mkdir -p /opt/myapp/

# Baixar o ZIP do repositório ModulosPro diretamente no diretório /opt/myapp/
print_centered "Baixando modulos-pro..."
sudo wget --timeout=30 -P /opt/myapp/ https://github.com/sshturbo/m-dulo/raw/main/modulos.zip &>/dev/null

# Extrair o ZIP diretamente no diretório /opt/myapp/ e remover o arquivo ZIP após a extração
print_centered "Extraindo arquivos..."
sudo unzip /opt/myapp/modulos.zip -d /opt/myapp/ &>/dev/null && sudo rm /opt/myapp/modulos.zip
progress_bar 5

# Dar permissão de execução para scripts .sh e converter para o formato Unix
print_centered "Atualizando permissões..."
files=(
    "SshturboMakeAccount.sh"
    "ExcluirExpiradoApi.sh"
    "killuser.sh"
)

for file in "${files[@]}"; do
    sudo chmod +x /opt/myapp/"$file"
    dos2unix /opt/myapp/"$file" &>/dev/null
done

# Instalar dependências e iniciar o serviço se o diretório existir
if [ -d "/opt/myapp/" ]; then
    print_centered "Instalando dependências do package.json..."
    npm install --prefix /opt/myapp/ &>/dev/null

    # Iniciar o serviço
    print_centered "Iniciando o serviço..."
    npm start --prefix /opt/myapp/ &>/dev/null

    pm2 startup &>/dev/null
    pm2 save &>/dev/null
    progress_bar 10
else
    print_centered "Falha na instalação. Diretório /opt/myapp/ não encontrado."
fi

print_centered "Instalação concluída com sucesso!"
