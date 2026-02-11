# Guía de Capturas para P5.3

## Capturas que ya tienes añadidas:

✅ 1. docker_ps.png → `5.2 Captura 3.png`  
✅ 2. docker_logs.png → `5.2 Captura 2.png`  
✅ 3. curl_hello.png → `5.2 Captura 8.png`  
✅ 4. ls_config.png → `5.2 Captura 10.png`  
✅ 5. build_gradle.png → `5.2 Captura 11.png`  
✅ 6. nginx_conf.png → `5.2 Captura 12.png`  
✅ 7. docker_ps_ports.png → `5.2 Captura 3.png` (misma que #1)  
✅ 8. add_user.png → `5.2 Captura 10.png`  
✅ 9. browser_hello.png → `5.2 Captura 8.png`  
✅ 10. browser_pojo.png → `5.2 Captura 9.png`  

---

## Capturas que FALTAN (Apartado g):

### ❌ 11. curl_tests.png
**Qué hacer:**
1. Abre PowerShell en el directorio del proyecto
2. Ejecuta estos comandos UNO POR UNO y captura la pantalla con todas las respuestas:

```powershell
# Test 1: GET hello
curl.exe http://localhost:8080/myproject/module/backend/api/myservice/hello

# Test 2: GET lista
curl.exe http://localhost:8080/myproject/module/backend/api/myservice/pojo/list

# Test 3: POST crear
curl.exe -X POST -H "Content-Type: application/json" -d '{\"id\":\"123\", \"name\":\"Test\"}' http://localhost:8080/myproject/module/backend/api/myservice/pojo/new

# Test 4: PUT actualizar
curl.exe -X PUT -H "Content-Type: application/json" -d '{\"id\":\"55\", \"name\":\"Raul\"}' http://localhost:8080/myproject/module/backend/api/myservice/pojo/update

# Test 5: DELETE borrar
curl.exe -X DELETE "http://localhost:8080/myproject/module/backend/api/myservice/pojo/remove?id=3"
```

**Importante:** 
- Usa `curl.exe` no `curl` (porque curl es un alias de Invoke-WebRequest en PowerShell)
- Las comillas dobles dentro del JSON deben escaparse con `\"`
- Captura la pantalla mostrando TODOS los comandos ejecutados

---

### ❌ 12. ab_test.png
**Qué hacer:**

**Opción A: Si tienes ApacheBench (viene con XAMPP o Apache)**
```powershell
ab.exe -n 1000 -c 10 http://localhost:8080/myproject/module/backend/api/myservice/pojo/list
```

**Opción B: Si NO tienes ApacheBench**

Instala primero:
```powershell
# Instalar Chocolatey (si no lo tienes)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Instalar wrk
choco install wrk

# Ejecutar prueba
wrk -t10 -c10 -d30s http://localhost:8080/myproject/module/backend/api/myservice/pojo/list
```

**Opción C: Si no quieres instalar nada**

Puedes usar este script de PowerShell:
```powershell
# Guardar este código en test-performance.ps1
$url = "http://localhost:8080/myproject/module/backend/api/myservice/pojo/list"
$requests = 1000
$concurrent = 10

Write-Host "Ejecutando $requests peticiones con $concurrent concurrentes..."
$start = Get-Date

$jobs = 1..$concurrent | ForEach-Object {
    Start-Job -ScriptBlock {
        param($url, $count)
        $results = @()
        for ($i = 0; $i -lt $count; $i++) {
            $time = Measure-Command {
                try {
                    $response = Invoke-WebRequest -Uri $url -UseBasicParsing
                    $results += [PSCustomObject]@{
                        Success = $true
                        StatusCode = $response.StatusCode
                    }
                } catch {
                    $results += [PSCustomObject]@{
                        Success = $false
                        StatusCode = 0
                    }
                }
            }
        }
        return $results
    } -ArgumentList $url, ($requests / $concurrent)
}

$jobs | Wait-Job | Receive-Job
$end = Get-Date
$duration = ($end - $start).TotalSeconds

Write-Host "`nResultados:"
Write-Host "Total tiempo: $duration segundos"
Write-Host "Peticiones por segundo: $($requests / $duration)"
Write-Host "Tiempo por petición: $(($duration * 1000) / $requests) ms"
```

**Captura:** Una vez ejecutado, captura la salida mostrando:
- Requests per second
- Time per request
- Failed requests
- Percentiles si están disponibles

---

## Capturas que FALTAN (Apartado i):

### ❌ 13. docker_compose_yml.png
**Qué hacer:**
1. Abre el archivo `docker-compose.yml` en VS Code
2. Asegúrate de que se ve TODO el contenido (services, volumes, networks)
3. Captura la pantalla completa del editor

**Nota:** El archivo ya existe en tu proyecto, solo ábrelo y captura

---

### ❌ 14. docker_compose_ps.png
**Qué hacer:**
1. Primero levanta docker-compose (si no lo has hecho):

```powershell
# Compilar el WAR primero
cd practica-jakarta-wildfly
mvn clean package
cd ..

# Levantar docker-compose
docker-compose up -d

# Esperar unos segundos para que arranque todo
Start-Sleep -Seconds 10

# Ver estado
docker-compose ps
```

2. Captura la salida del comando `docker-compose ps`
3. Debería mostrar dos servicios: `nginx` y `wildfly` con status "running" o "healthy"

---

### ❌ 15. nginx_access.png
**Qué hacer:**

**Opción A: Con navegador**
1. Con docker-compose levantado, abre el navegador
2. Ve a: `http://localhost/api/myservice/hello`
3. Debería mostrar `hello!`
4. Captura la pantalla mostrando la URL y la respuesta

**Opción B: Con curl (más fácil para captura)**
```powershell
# Acceso HTTP
curl.exe http://localhost/api/myservice/hello

# Acceso HTTPS (si generaste certificados)
curl.exe -k https://localhost/api/myservice/hello
```

**Nota importante:** Para que funcione Nginx necesitas:
- Haber ejecutado `docker-compose up -d`
- Que el archivo `nginx.conf` esté configurado correctamente
- Que los certificados estén en la carpeta `certs/` (para HTTPS)

Si no has generado certificados aún:
```powershell
mkdir certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/server.key -out certs/server.crt -subj "/CN=localhost"
```

---

## Resumen de lo que falta:

| # | Captura | Estado | Dificultad |
|---|---------|--------|------------|
| 11 | curl_tests.png | ❌ PENDIENTE | ⭐ Fácil |
| 12 | ab_test.png | ❌ PENDIENTE | ⭐⭐ Media (requiere instalar herramienta) |
| 13 | docker_compose_yml.png | ❌ PENDIENTE | ⭐ Muy fácil (solo abrir archivo) |
| 14 | docker_compose_ps.png | ❌ PENDIENTE | ⭐⭐ Media (requiere levantar docker-compose) |
| 15 | nginx_access.png | ❌ PENDIENTE | ⭐⭐⭐ Media-Alta (requiere docker-compose + certificados) |

---

## Orden recomendado para hacer las capturas:

1. **Primero la más fácil:** `docker_compose_yml.png` (solo abre el archivo y captura)
2. **Pruebas curl:** `curl_tests.png` (ejecuta los comandos y captura)
3. **Docker Compose:** Compila el WAR y levanta docker-compose
4. **Estado de compose:** `docker_compose_ps.png`
5. **Acceso Nginx:** `nginx_access.png`
6. **Performance test:** `ab_test.png` (la última porque requiere instalar herramienta)

---

## Tip para capturas de terminal:

En PowerShell puedes hacer scroll hacia arriba para ver todos los comandos ejecutados y capturar una imagen con todos los resultados juntos. Usa la herramienta de recortes de Windows:

**Windows + Shift + S** → Seleccionar área rectangular → Se guarda en portapapeles → Pegar en Paint o editor de imágenes → Guardar en carpeta `capturas/`

¡Mucha suerte con las capturas! 🎯
