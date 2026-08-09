# ============================================================================
# SETUP COMPLETO - LFV TEASER PIPELINE PARA XPRIZE
# Ejecutar en PowerShell (Admin recomendado)
# ============================================================================

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "LFV TEASER PIPELINE - SETUP XPRIZE" -ForegroundColor Yellow
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# PASO 1: VERIFICAR PYTHON
Write-Host "[1/5] Verificando Python 3.11+..." -ForegroundColor Green
$pythonCheck = python --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Python encontrado: $pythonCheck" -ForegroundColor Green
} else {
    Write-Host "❌ Python NO está instalado" -ForegroundColor Red
    Write-Host "   Descarga e instala Python 3.11+ desde:" -ForegroundColor Yellow
    Write-Host "   https://www.python.org/downloads/" -ForegroundColor Cyan
    Write-Host "   ⚠️  Asegúrate de marcar 'Add Python to PATH' durante la instalación" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   Después cierra PowerShell y abre una nueva ventana." -ForegroundColor Yellow
    exit
}

Write-Host ""

# PASO 2: IR AL DIRECTORIO DEL PROYECTO
Write-Host "[2/5] Cambiando al directorio del proyecto..." -ForegroundColor Green
$projectPath = "C:\Users\DELL\Downloads\lfv-teaser-pipeline-scaffold"
if (-not (Test-Path $projectPath)) {
    Write-Host "❌ No se encontró: $projectPath" -ForegroundColor Red
    exit
}
Set-Location $projectPath
Write-Host "✅ En: $projectPath" -ForegroundColor Green
Write-Host ""

# PASO 3: INSTALAR DEPENDENCIAS
Write-Host "[3/5] Instalando dependencias (google-genai, pillow)..." -ForegroundColor Green
pip install -r requirements.txt
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al instalar dependencias" -ForegroundColor Red
    exit
}
Write-Host "✅ Dependencias instaladas" -ForegroundColor Green
Write-Host ""

# PASO 4: CONFIGURAR VARIABLE DE ENTORNO
Write-Host "[4/5] Configurando variable de entorno GEMINI_API_KEY..." -ForegroundColor Green
Write-Host "   Ingresa tu API key de Gemini (desde https://aistudio.google.com/)" -ForegroundColor Yellow
Write-Host "   La clave se guardará como variable de entorno del usuario" -ForegroundColor Cyan
$apiKey = Read-Host "   GEMINI_API_KEY (o presiona Enter para omitir ahora)"

if ($apiKey) {
    try {
        [Environment]::SetEnvironmentVariable("GEMINI_API_KEY", $apiKey, "User")
        $env:GEMINI_API_KEY = $apiKey
        Write-Host "✅ Variable de entorno configurada (sesión actual + permanente)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  No se pudo guardar permanentemente, pero está disponible para esta sesión" -ForegroundColor Yellow
        $env:GEMINI_API_KEY = $apiKey
    }
} else {
    Write-Host "⏭️  Omitido (configura manualmente después si es necesario)" -ForegroundColor Yellow
}
Write-Host ""

# PASO 5: VALIDAR SETUP
Write-Host "[5/5] Validando setup..." -ForegroundColor Green
Write-Host ""

# Validar Python
$pythonCheck = python --version 2>&1
Write-Host "   ✅ Python: $pythonCheck" -ForegroundColor Green

# Validar google-genai
try {
    python -c "import google.genai; print('google-genai OK')" 2>$null
    Write-Host "   ✅ google-genai instalado" -ForegroundColor Green
} catch {
    Write-Host "   ❌ google-genai NO encontrado" -ForegroundColor Red
}

# Validar pillow
try {
    python -c "import PIL; print('Pillow OK')" 2>$null
    Write-Host "   ✅ Pillow instalado" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Pillow NO encontrado" -ForegroundColor Red
}

# Validar estructura de proyecto
$requiredDirs = @(
    "canon",
    "prompts",
    "refs",
    "scripts",
    ".github\workflows"
)
$allGood = $true
foreach ($dir in $requiredDirs) {
    if (Test-Path $dir) {
        Write-Host "   ✅ Directorio: $dir" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Falta: $dir" -ForegroundColor Yellow
        $allGood = $false
    }
}

# Validar archivo de script
if (Test-Path "scripts\generate_image_gemini.py") {
    Write-Host "   ✅ Script principal: scripts\generate_image_gemini.py" -ForegroundColor Green
} else {
    Write-Host "   ❌ Falta: scripts\generate_image_gemini.py" -ForegroundColor Red
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "SETUP COMPLETADO" -ForegroundColor Yellow
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

if ($apiKey) {
    Write-Host "🚀 LISTO PARA GENERAR CANDIDATOS" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos pasos:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Generar candidatos P04 (Yaya):" -ForegroundColor Yellow
    Write-Host "   python scripts/generate_image_gemini.py --shot P04 --variants 2 --image-size 1K" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Generar candidatos P05 (Gael):" -ForegroundColor Yellow
    Write-Host "   python scripts/generate_image_gemini.py --shot P05 --variants 2 --image-size 1K" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Los archivos se guardarán en:" -ForegroundColor Yellow
    Write-Host "   outputs/P04/ y outputs/P05/" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "⏳ SETUP PARCIAL COMPLETADO" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Aún necesitas:" -ForegroundColor Yellow
    Write-Host "1. Obtener API key desde https://aistudio.google.com/" -ForegroundColor Cyan
    Write-Host "2. Configura la variable de entorno:" -ForegroundColor Cyan
    Write-Host "   `$env:GEMINI_API_KEY = 'TU_API_KEY_AQUI'" -ForegroundColor White
    Write-Host ""
}

Write-Host "Para más información, ver README.md" -ForegroundColor Gray
Write-Host ""
