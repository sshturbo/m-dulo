#!/bin/bash

# Função para centralizar texto
print_centered() {
    term_width=$(tput cols)
    text="$1"
    padding=$(( (term_width - ${#text}) / 2 ))
    printf "%${padding}s" '' # Adiciona espaços antes do texto
    echo "$text"
}

print_centered "Iniciando o processo de instalação..."

# Função para simular uma barra de progresso
progress_bar() {
    echo -n "Progresso: ["
    for i in $(seq 1 $1); do
        echo -n "###"
        sleep 1
    done
    echo "] Completo!"
}

# Atualizando e atualizando os pacotes
print_centered "Atualizando pacotes..."
sudo apt update &>/dev/null && sudo apt upgrade -y &>/dev/null
progress_bar 5

# Carregar NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Carrega o NVM
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 

# Verificar a existência do NVM
if [ ! -f "$NVM_DIR/nvm.sh" ]; then
    print_centered "NVM não está instalado. Instalando o NVM..."
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash &>/dev/null
    print_centered "NVM instalado. Por favor, execute este script novamente para continuar a instalação do Node.js."
    exec bash
    # Após esta linha, o script não continuará, pois o shell foi substituído.
fi

# Continuação para instalação do Node.js
current_version=$(node -v 2>/dev/null | cut -d 'v' -f 2 | cut -d '.' -f 1)
if [ "$current_version" -le 8 ]; then
    print_centered "Instalando Node.js versão 14..."
    nvm install 14 &>/dev/null
    nvm use 14
    nvm alias default 14
    progress_bar 10
    print_centered "Node.js versão 14 instalado com sucesso."
else
    print_centered "Node.js já está instalado e a versão é maior que 8."
fi


# Verificando e instalando o npm se necessário
if ! command -v npm > /dev/null 2>&1; then
    print_centered "npm não está instalado. Instalando..."
    sudo apt install npm -y &>/dev/null
    progress_bar 5
else
    print_centered "npm já está instalado."
fi

# Verificando e instalando o dos2unix se necessário
if ! command -v dos2unix > /dev/null 2>&1; then
    print_centered "dos2unix não está instalado. Instalando..."
    sudo apt install dos2unix -y &>/dev/null
    progress_bar 5
else
    print_centered "dos2unix já está instalado."
fi

# Verificando e instalando o PM2 se necessário
if ! command -v pm2 > /dev/null 2>&1; then
    print_centered "PM2 não está instalado. Instalando..."
    sudo npm install pm2@4.5.6 -g &>/dev/null
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
sudo wget -P /opt/myapp/ https://github.com/sshturbo/m-dulo/raw/main/modulos-prov2.zip &>/dev/null

# Extrair o ZIP diretamente no diretório /opt/myapp/ e remover o arquivo ZIP após a extração
print_centered "Extraindo arquivos..."
sudo unzip /opt/myapp/modulos-prov2.zip -d /opt/myapp/ &>/dev/null && sudo rm /opt/myapp/modulos-prov2.zip
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
