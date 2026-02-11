# Script de prueba de rendimiento simple para PowerShell
# Sin necesidad de instalar ApacheBench

param(
    [string]$url = "http://localhost:8080/myproject/module/backend/api/myservice/pojo/list",
    [int]$totalRequests = 1000,
    [int]$concurrent = 10
)

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Prueba de Rendimiento - WildFly API" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "URL         : $url" -ForegroundColor Yellow
Write-Host "Peticiones  : $totalRequests" -ForegroundColor Yellow
Write-Host "Concurrentes: $concurrent" -ForegroundColor Yellow
Write-Host ""
Write-Host "Iniciando prueba..." -ForegroundColor Green
Write-Host ""

$requestsPerJob = [math]::Floor($totalRequests / $concurrent)
$startTime = Get-Date

# Crear trabajos concurrentes
$jobs = 1..$concurrent | ForEach-Object {
    Start-Job -ScriptBlock {
        param($url, $count)
        
        $times = @()
        $successes = 0
        $failures = 0
        
        for ($i = 0; $i -lt $count; $i++) {
            try {
                $sw = [System.Diagnostics.Stopwatch]::StartNew()
                $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
                $sw.Stop()
                
                if ($response.StatusCode -eq 200) {
                    $successes++
                    $times += $sw.Elapsed.TotalMilliseconds
                }
            }
            catch {
                $failures++
            }
        }
        
        return @{
            Times = $times
            Successes = $successes
            Failures = $failures
        }
    } -ArgumentList $url, $requestsPerJob
}

# Esperar a que terminen todos los trabajos
Write-Host "Ejecutando peticiones..." -ForegroundColor Cyan
$results = $jobs | Wait-Job | Receive-Job
$jobs | Remove-Job

$endTime = Get-Date
$totalTime = ($endTime - $startTime).TotalSeconds

# Procesar resultados
$allTimes = @()
$totalSuccesses = 0
$totalFailures = 0

foreach ($result in $results) {
    $allTimes += $result.Times
    $totalSuccesses += $result.Successes
    $totalFailures += $result.Failures
}

$allTimes = $allTimes | Sort-Object

# Calcular estadísticas
$avgTime = ($allTimes | Measure-Object -Average).Average
$minTime = ($allTimes | Measure-Object -Minimum).Minimum
$maxTime = ($allTimes | Measure-Object -Maximum).Maximum

$requestsPerSecond = [math]::Round($totalSuccesses / $totalTime, 2)
$timePerRequest = [math]::Round($avgTime, 2)

# Calcular percentiles
$p50Index = [math]::Floor($allTimes.Count * 0.50)
$p66Index = [math]::Floor($allTimes.Count * 0.66)
$p75Index = [math]::Floor($allTimes.Count * 0.75)
$p80Index = [math]::Floor($allTimes.Count * 0.80)
$p90Index = [math]::Floor($allTimes.Count * 0.90)
$p95Index = [math]::Floor($allTimes.Count * 0.95)
$p99Index = [math]::Floor($allTimes.Count * 0.99)

# Mostrar resultados
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "RESULTADOS" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Resumen General:" -ForegroundColor Yellow
Write-Host "  Tiempo total           : $([math]::Round($totalTime, 3)) segundos"
Write-Host "  Peticiones completadas : $totalSuccesses"
Write-Host "  Peticiones fallidas    : $totalFailures" -ForegroundColor $(if($totalFailures -gt 0){"Red"}else{"Green"})
Write-Host ""
Write-Host "Rendimiento:" -ForegroundColor Yellow
Write-Host "  Peticiones/segundo     : $requestsPerSecond req/s" -ForegroundColor Green
Write-Host "  Tiempo por petición    : $timePerRequest ms (media)"
Write-Host "  Tiempo mínimo          : $([math]::Round($minTime, 2)) ms"
Write-Host "  Tiempo máximo          : $([math]::Round($maxTime, 2)) ms"
Write-Host ""
Write-Host "Percentiles (tiempo en ms):" -ForegroundColor Yellow
Write-Host "  50%  : $([math]::Round($allTimes[$p50Index], 0)) ms"
Write-Host "  66%  : $([math]::Round($allTimes[$p66Index], 0)) ms"
Write-Host "  75%  : $([math]::Round($allTimes[$p75Index], 0)) ms"
Write-Host "  80%  : $([math]::Round($allTimes[$p80Index], 0)) ms"
Write-Host "  90%  : $([math]::Round($allTimes[$p90Index], 0)) ms"
Write-Host "  95%  : $([math]::Round($allTimes[$p95Index], 0)) ms"
Write-Host "  99%  : $([math]::Round($allTimes[$p99Index], 0)) ms"
Write-Host "  100% : $([math]::Round($maxTime, 0)) ms (peor caso)"
Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Prueba completada exitosamente!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
