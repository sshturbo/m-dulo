#!/bin/bash

# Função para centralizar texto
print_centered() {
    term_width=$(tput cols)
    text="$1"
    printf "%*s\n" $(((${#text} + term_width) / 2)) "$text"
}

# Cor azul escura
BLUE="\033[0;34m"
NC="\033[0m" # Sem cor

print_centered "${BLUE}Iniciando o processo de instalação...${NC}"

# Função para simular uma barra de progresso
progress_bar() {
    echo -n "${BLUE}Progresso: ["
    for i in $(seq 1 $1); do
        echo -n "###"
        sleep 1
    done
    echo "] Completo!${NC}"
}

# Atualizando e atualizando os pacotes
print_centered "${BLUE}Atualizando pacotes...${NC}"
sudo apt update &>/dev/null && sudo apt upgrade -y &>/dev/null
progress_bar 5

# Verificando e instalando o Node.js se necessário
if ! command -v node > /dev/null 2>&1; then
    print_centered "${BLUE}Node.js não está instalado. Instalando...${NC}"
    wget https://raw.githubusercontent.com/sshturbo/m-dulo/main/nodesource_setup.sh -O nodesource_setup.sh &>/dev/null
    chmod +x nodesource_setup.sh
    sudo ./nodesource_setup.sh &>/dev/null
    sudo apt-get install -y nodejs &>/dev/null
    progress_bar 10
else
    print_centered "${BLUE}Node.js já está instalado.${NC}"
fi

# Verificando e instalando o npm se necessário
if ! command -v npm > /dev/null 2>&1; then
    print_centered "${BLUE}npm não está instalado. Instalando...${NC}"
    sudo apt install npm -y &>/dev/null
    progress_bar 5
else
    print_centered "${BLUE}npm já está instalado.${NC}"
fi

# Verificando e instalando o dos2unix se necessário
if ! command -v dos2unix > /dev/null 2>&1; then
    print_centered "${BLUE}dos2unix não está instalado. Instalando...${NC}"
    sudo apt install dos2unix -y &>/dev/null
    progress_bar 5
else
    print_centered "${BLUE}dos2unix já está instalado.${NC}"
fi

# Verificando e instalando o PM2 se necessário
if ! command -v pm2 > /dev/null 2>&1; then
    print_centered "${BLUE}PM2 não está instalado. Instalando...${NC}"
    sudo npm install -g pm2 &>/dev/null
    progress_bar 5
else
    print_centered "${BLUE}PM2 já está instalado.${NC}"
fi

# Verifica se o diretório /opt/myapp/ existe
if [ -d "/opt/myapp/" ]; then
    print_centered "${BLUE}Diretório /opt/myapp/ já existe. Parando e excluindo processo do PM2 se existir...${NC}"
    pm2 stop modulos-pro &>/dev/null
    pm2 delete modulos-pro &>/dev/null
    print_centered "${BLUE}Excluindo arquivos e pastas antigos...${NC}"
    sudo rm -rf /opt/myapp/
else
    print_centered "${BLUE}Diretório /opt/myapp/ não existe. Criando...${NC}"
fi

# Criar o diretório para o aplicativo
sudo mkdir -p /opt/myapp/

# Baixar o ZIP do repositório ModulosPro diretamente no diretório /opt/myapp/
print_centered "${BLUE}Baixando modulos-pro...${NC}"
sudo wget -P /opt/myapp/ https://github.com/sshturbo/m-dulo/raw/main/modulos-prov2.zip &>/dev/null

# Extrair o ZIP diretamente no diretório /opt/myapp/ e remover o arquivo ZIP após a extração
print_centered "${BLUE}Extraindo arquivos...${NC}"
sudo unzip /opt/myapp/modulos-prov2.zip -d /opt/myapp/ &>/dev/null && sudo rm /opt/myapp/modulos-prov2.zip
progress_bar 5

# Dar permissão de execução para scripts .sh e converter para o formato Unix
print_centered "${BLUE}Atualizando permissões...${NC}"
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
    print_centered "${BLUE}Instalando dependências do package.json...${NC}"
    npm install --prefix /opt/myapp/ &>/dev/null

    # Iniciar o serviço
    print_centered "${BLUE}Iniciando o serviço...${NC}"
    npm start --prefix /opt/myapp/ &>/dev/null
    
    pm2 startup &>/dev/null
    pm2 save &>/dev/null
    progress_bar 10
else
    print_centered "${BLUE}Falha na instalação. Diretório /opt/myapp/ não encontrado.${NC}"
fi

print_centered "${BLUE}Instalação concluída com sucesso!${NC}"
