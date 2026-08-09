# ============================================================================
# GENERAR CANDIDATOS DE IMÁGENES - LFV XPRIZE
# Ejecución: PowerShell
# ============================================================================

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "GENERADOR DE CANDIDATOS - LFV TEASER" -ForegroundColor Yellow
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que estamos en el directorio correcto
$projectPath = "C:\Users\DELL\Downloads\lfv-teaser-pipeline-scaffold"
if ((Get-Location).Path -ne $projectPath) {
    Set-Location $projectPath
    Write-Host "Cambiado a: $projectPath" -ForegroundColor Cyan
}

# Verificar API Key
if (-not $env:GEMINI_API_KEY) {
    Write-Host "❌ ERROR: Variable GEMINI_API_KEY no configurada" -ForegroundColor Red
    Write-Host ""
    Write-Host "Configúrala con:" -ForegroundColor Yellow
    Write-Host '  $env:GEMINI_API_KEY = "TU_API_KEY"' -ForegroundColor White
    Write-Host ""
    exit
}

Write-Host "✅ API Key detectada" -ForegroundColor Green
Write-Host ""

# MENÚ DE OPCIONES
Write-Host "¿Qué deseas generar?" -ForegroundColor Cyan
Write-Host ""
Write-Host "1) P04 - Yaya (candidatos)" -ForegroundColor Yellow
Write-Host "2) P05 - Gael (candidatos)" -ForegroundColor Yellow
Write-Host "3) Ambos (P04 + P05)" -ForegroundColor Yellow
Write-Host "4) Personalizado (especificar shot y variantes)" -ForegroundColor Yellow
Write-Host ""

$choice = Read-Host "Selecciona opción (1-4)"

$shot = ""
$variants = 2
$imageSize = "1K"
$model = "gemini-3.1-flash-image"

switch ($choice) {
    "1" {
        $shot = "P04"
        Write-Host "Generando candidatos para P04 (Yaya)..." -ForegroundColor Green
    }
    "2" {
        $shot = "P05"
        Write-Host "Generando candidatos para P05 (Gael)..." -ForegroundColor Green
    }
    "3" {
        Write-Host "Generando candidatos para P04 (Yaya) y P05 (Gael)..." -ForegroundColor Green
        
        # P04
        Write-Host ""
        Write-Host "--- GENERANDO P04 (Yaya) ---" -ForegroundColor Cyan
        python scripts/generate_image_gemini.py `
            --shot P04 `
            --variants 2 `
            --model $model `
            --image-size $imageSize
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ P04 completado" -ForegroundColor Green
        } else {
            Write-Host "❌ Error en P04" -ForegroundColor Red
        }
        
        # P05
        Write-Host ""
        Write-Host "--- GENERANDO P05 (Gael) ---" -ForegroundColor Cyan
        python scripts/generate_image_gemini.py `
            --shot P05 `
            --variants 2 `
            --model $model `
            --image-size $imageSize
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ P05 completado" -ForegroundColor Green
        } else {
            Write-Host "❌ Error en P05" -ForegroundColor Red
        }
        
        Write-Host ""
        Write-Host "===============================================" -ForegroundColor Cyan
        Write-Host "GENERACIÓN COMPLETADA" -ForegroundColor Yellow
        Write-Host "===============================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Resultados en:" -ForegroundColor Cyan
        Write-Host "  📁 outputs/P04/" -ForegroundColor White
        Write-Host "  📁 outputs/P05/" -ForegroundColor White
        exit
    }
    "4" {
        $shot = Read-Host "Shot (P04 o P05)"
        $variantInput = Read-Host "Número de variantes (1-4, default 2)"
        if ($variantInput) {
            $variants = [int]$variantInput
        }
        $sizeInput = Read-Host "Tamaño de imagen (512, 1K, 2K, 4K, default 1K)"
        if ($sizeInput) {
            $imageSize = $sizeInput
        }
        Write-Host "Generando $variants variantes de $shot en $imageSize..." -ForegroundColor Green
    }
    default {
        Write-Host "Opción no válida" -ForegroundColor Red
        exit
    }
}

if ($shot -eq "" -or ($shot -ne "P04" -and $shot -ne "P05")) {
    Write-Host "❌ Shot no válido" -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "Parámetros:" -ForegroundColor Cyan
Write-Host "  Shot: $shot" -ForegroundColor White
Write-Host "  Variantes: $variants" -ForegroundColor White
Write-Host "  Tamaño: $imageSize" -ForegroundColor White
Write-Host "  Modelo: $model" -ForegroundColor White
Write-Host ""
Write-Host "Iniciando generación..." -ForegroundColor Yellow
Write-Host ""

# Ejecutar generación
python scripts/generate_image_gemini.py `
    --shot $shot `
    --variants $variants `
    --model $model `
    --image-size $imageSize

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "✅ GENERACIÓN EXITOSA" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Resultados guardados en:" -ForegroundColor Cyan
    Write-Host "  📁 outputs/$shot/" -ForegroundColor White
    Write-Host ""
    Write-Host "Archivos generados:" -ForegroundColor Cyan
    Get-ChildItem "outputs/$shot" -File | ForEach-Object {
        Write-Host "  📄 $($_.Name)" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "Próximo paso: Revisar continuidad visual con P01-P03" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Red
    Write-Host "❌ ERROR EN LA GENERACIÓN" -ForegroundColor Red
    Write-Host "===============================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifica:" -ForegroundColor Yellow
    Write-Host "  1. Variable GEMINI_API_KEY está configurada correctamente" -ForegroundColor Cyan
    Write-Host "  2. Tienes conexión a internet" -ForegroundColor Cyan
    Write-Host "  3. Tu API key tiene créditos disponibles" -ForegroundColor Cyan
    Write-Host "  4. Archivos canon y prompts existen en el directorio" -ForegroundColor Cyan
}

Write-Host ""
