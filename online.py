import subprocess
import re
import time
import sys

# Importação condicional para requests
try:
    import requests
except ImportError:
    # Pode ser necessário instalar 'requests' manualmente em ambientes Python 2
    raise ImportError("A biblioteca 'requests' é necessária. Instale-a com 'pip install requests'.")

# Compatibilidade com Python 2 e 3 para 'input' e 'print'
try:
    input = raw_input
except NameError:
    pass

def get_connected_users():
    # Comando modificado para ser compatível com Python 2 e 3
    process = subprocess.Popen(['ps', 'aux'], stdout=subprocess.PIPE)
    output, _ = process.communicate()
    # Decodificar para UTF-8 em Python 3
    if sys.version_info[0] >= 3:
        output = output.decode('utf-8')

    users = set()
    for line in output.split('\n'):
        if 'priv' in line and 'Ss' in line:
            columns = line.split()
            if len(columns) > 11:
                users.add(columns[11])

    try:
        with open('/etc/openvpn/openvpn-status.log', 'r') as file:
            for line in file:
                match = re.match(r"^[a-zA-Z0-9_-]+,[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+", line)
                if match:
                    users.add(line.split(',')[0])
    except (IOError, FileNotFoundError):
        pass

    return ','.join(users)

def send_users_to_server(user_list, url):
    requests.post(url, data={'users': user_list})

def start_loop(url):
    while True:
        user_list = get_connected_users()
        send_users_to_server(user_list, url)
        time.sleep(3)

url = sys.argv[1] if len(sys.argv) > 1 else "https://example.com/"
start_loop(url)
