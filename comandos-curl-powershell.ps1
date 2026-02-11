# Comandos para probar la API REST en PowerShell
# Puedes ejecutarlos uno por uno o copiarlos

# ============================================
# OPCIÓN A: Usando curl.exe (curl real)
# ============================================

# GET /hello
curl.exe http://localhost:8080/myproject/module/backend/api/myservice/hello

# GET /pojo/list
curl.exe http://localhost:8080/myproject/module/backend/api/myservice/pojo/list

# POST /pojo/new
curl.exe -X POST -H "Content-Type: application/json" -d '{\"id\":\"123\", \"name\":\"Test\"}' http://localhost:8080/myproject/module/backend/api/myservice/pojo/new

# PUT /pojo/update
curl.exe -X PUT -H "Content-Type: application/json" -d '{\"id\":\"55\", \"name\":\"Raul\"}' http://localhost:8080/myproject/module/backend/api/myservice/pojo/update

# DELETE /pojo/remove
curl.exe -X DELETE "http://localhost:8080/myproject/module/backend/api/myservice/pojo/remove?id=3"


# ============================================
# OPCIÓN B: Usando Invoke-WebRequest (nativo PowerShell)
# ============================================

# GET /hello
Invoke-WebRequest -Uri "http://localhost:8080/myproject/module/backend/api/myservice/hello" | Select-Object -ExpandProperty Content

# GET /pojo/list
Invoke-WebRequest -Uri "http://localhost:8080/myproject/module/backend/api/myservice/pojo/list" | Select-Object -ExpandProperty Content

# POST /pojo/new
Invoke-WebRequest -Uri "http://localhost:8080/myproject/module/backend/api/myservice/pojo/new" `
    -Method POST `
    -Headers @{"Content-Type"="application/json"} `
    -Body '{"id":"123", "name":"Test"}' | Select-Object StatusCode, StatusDescription

# PUT /pojo/update
Invoke-WebRequest -Uri "http://localhost:8080/myproject/module/backend/api/myservice/pojo/update" `
    -Method PUT `
    -Headers @{"Content-Type"="application/json"} `
    -Body '{"id":"55", "name":"Raul"}' | Select-Object StatusCode, StatusDescription

# DELETE /pojo/remove
Invoke-WebRequest -Uri "http://localhost:8080/myproject/module/backend/api/myservice/pojo/remove?id=3" `
    -Method DELETE | Select-Object StatusCode, StatusDescription


# ============================================
# Para ApacheBench (prueba de rendimiento)
# ============================================

# Si tienes ApacheBench instalado (viene con Apache o XAMPP):
ab.exe -n 1000 -c 10 http://localhost:8080/myproject/module/backend/api/myservice/pojo/list

# Si no tienes ApacheBench, puedes instalar wrk con Chocolatey:
# choco install wrk
# wrk -t10 -c10 -d30s http://localhost:8080/myproject/module/backend/api/myservice/pojo/list
