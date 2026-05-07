#!/bin/bash

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m' # No Color

usage() {
    echo -e "${BOLD}Usage:${NC} $0 --url <URL> --userlist <FILE>"
    echo ""
    echo "  --url        Target GitLab URL (e.g., http://gitlab.htb)"
    echo "  --userlist   File containing usernames to enumerate"
}

# Parsing de argumentos (basado en tu estructura)
args=("$@")
for ((i=0; i<$#; i++)); do
    case ${args[$i]} in
        --url)
            URL=${args[$((i+1))]}
            ;;
        --userlist)
            user_list=${args[$((i+1))]}
            ;;
        -h | --help)
            usage
            exit 0
            ;;
    esac
done

## Checking mandatory parameters
if [ -z "$URL" ] || [ -z "$user_list" ]; then
    usage
    echo -e "\n${RED}${BOLD}[!] Missing parameters. Check URL and Userlist.${NC}"
    exit 1
fi

# User Enumeration Function
enumeration() {
    if [ ! -f "$user_list" ]; then
        echo -e "${RED}${BOLD}[!] Error: File $user_list not found.${NC}"
        exit 1
    fi

    echo -e "${BOLD}[*] Starting enumeration on: $URL${NC}\n"

    while IFS= read -r line
    do
        # Realiza la petición y captura solo el código de estado
        HTTP_Code=$(curl -s -o /dev/null -w "%{http_code}" "$URL/$line")

        if [ "$HTTP_Code" -eq 200 ]; then
            echo -e "${GREEN}${BOLD}[+]${NC} The username ${GREEN}${BOLD}$line${NC} exists!"
        elif [ "$HTTP_Code" -eq 000 ]; then
            echo -e "${BOLD}${RED}[!]${NC} The target is unreachable. Check connection/URL."
            exit 1
        fi
    done < "$user_list"
}

# Main
enumeration
