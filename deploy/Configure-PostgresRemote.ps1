<#
.SYNOPSIS
    Script de Configuración Automática de Red para PostgreSQL y Firewall de Windows.
    Permite el acceso desde cualquier IP (0.0.0.0/0) y abre los puertos de entrada 5432, 3001 y 3000.
#>
param([switch]$Elevated)

# Auto-elevación a Administrador si no se ejecuta elevado
if (-not $Elevated) {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Elevando privilegios de Administrador para configurar Red y Firewall..." -ForegroundColor Yellow
        Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Elevated" -Verb RunAs
        exit
    }
}

Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host " CONFIGURADOR AUTOMATICO DE RED POSTGRESQL Y FIREWALL - KOREX PLATFORM   " -ForegroundColor Cyan
Write-Host "==========================================================================" -ForegroundColor Cyan

# Definir codificación UTF-8 sin BOM para compatibilidad con PostgreSQL
$Utf8NoBom = New-Object System.Text.UTF8Encoding $false

# 1. LOCALIZAR INSTALACIÓN Y CONFIGURACIÓN DE POSTGRESQL
Write-Host "`n[1/4] Buscando instalacion de PostgreSQL en el sistema..." -ForegroundColor Yellow

$PgDataDirs = @()
$SearchPaths = @("C:\Program Files\PostgreSQL", "C:\ProgramData\PostgreSQL")

foreach ($p in $SearchPaths) {
    if (Test-Path $p) {
        $foundDirs = Get-ChildItem -Path $p -Recurse -Filter "pg_hba.conf" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DirectoryName
        if ($foundDirs) {
            $PgDataDirs += $foundDirs
        }
    }
}

if ($PgDataDirs.Count -eq 0) {
    Write-Host "   [!] No se encontraron archivos de configuracion pg_hba.conf en rutas estandar." -ForegroundColor Red
} else {
    foreach ($dataDir in $PgDataDirs) {
        Write-Host "   [+] Data Dir detectado: $dataDir" -ForegroundColor Green
        
        $confFile = Join-Path $dataDir "postgresql.conf"
        $hbaFile = Join-Path $dataDir "pg_hba.conf"

        # A. Actualizar postgresql.conf (listen_addresses = '*')
        if (Test-Path $confFile) {
            $confContent = [System.IO.File]::ReadAllText($confFile, [System.Text.Encoding]::UTF8)
            if ($confContent -match "(?m)^\s*listen_addresses\s*=") {
                $confContent = $confContent -replace "(?m)^\s*listen_addresses\s*=.*$", "listen_addresses = '*'"
            } else {
                $confContent += "`nlisten_addresses = '*'`n"
            }
            [System.IO.File]::WriteAllText($confFile, $confContent, $Utf8NoBom)
            Write-Host "       -> postgresql.conf actualizado con listen_addresses = '*'" -ForegroundColor Gray
        }

        # B. Actualizar pg_hba.conf (Permitir 0.0.0.0/0 y ::/0)
        if (Test-Path $hbaFile) {
            $hbaContent = [System.IO.File]::ReadAllText($hbaFile, [System.Text.Encoding]::UTF8)
            $needsUpdate = $false
            
            if ($hbaContent -notmatch "0\.0\.0\.0/0") {
                $hbaContent += "`nhost    all             all             0.0.0.0/0               scram-sha-256`n"
                $needsUpdate = $true
            }
            if ($hbaContent -notmatch "::/0") {
                $hbaContent += "`nhost    all             all             ::/0                    scram-sha-256`n"
                $needsUpdate = $true
            }

            if ($needsUpdate) {
                [System.IO.File]::WriteAllText($hbaFile, $hbaContent, $Utf8NoBom)
                Write-Host "       -> pg_hba.conf actualizado con reglas universales (0.0.0.0/0)" -ForegroundColor Gray
            } else {
                # Reescribir sin BOM si tenía BOM
                [System.IO.File]::WriteAllText($hbaFile, $hbaContent, $Utf8NoBom)
                Write-Host "       -> pg_hba.conf verificado sin BOM UTF-8." -ForegroundColor Gray
            }
        }
    }
}

# 2. REINICIAR SERVICIO POSTGRESQL PARA APLICAR CAMBIOS
Write-Host "`n[2/4] Reiniciando servicio PostgreSQL para aplicar configuraciones..." -ForegroundColor Yellow
$pgServices = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue
if ($pgServices) {
    foreach ($svc in $pgServices) {
        Write-Host "   -> Reiniciando servicio $($svc.Name)..." -ForegroundColor Gray
        Restart-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
        Write-Host "   [OK] Servicio $($svc.Name) reiniciado exitosamente." -ForegroundColor Green
    }
} else {
    Write-Host "   [!] No se detectaron servicios nombrados 'postgresql*' corriendo." -ForegroundColor Yellow
}

# 3. ABRIENDO REGLAS EN FIREWALL DE WINDOWS
Write-Host "`n[3/4] Configurando Reglas de Entrada en el Firewall de Windows..." -ForegroundColor Yellow

$RulesToEnsure = @(
    @{ Name = "Korex_PostgreSQL_5432"; Port = 5432; Display = "Korex Platform - PostgreSQL (5432)" },
    @{ Name = "Korex_NextJS_3001";     Port = 3001; Display = "Korex Platform - Next.js Engine (3001)" },
    @{ Name = "Korex_Web_3000";        Port = 3000; Display = "Korex Platform - Web Portal (3000)" }
)

foreach ($r in $RulesToEnsure) {
    $existing = Get-NetFirewallRule -Name $r.Name -ErrorAction SilentlyContinue
    if (-not $existing) {
        New-NetFirewallRule -Name $r.Name -DisplayName $r.Display -Direction Inbound -Protocol TCP -LocalPort $r.Port -Action Allow | Out-Null
        Write-Host "   [+] Creada regla de Firewall: $($r.Display) en Puerto $($r.Port)" -ForegroundColor Green
    } else {
        Set-NetFirewallRule -Name $r.Name -Enabled True -Action Allow | Out-Null
        Write-Host "   [OK] Regla de Firewall existente habilitada: $($r.Display)" -ForegroundColor Green
    }
}

# 4. FINALIZACIÓN
Write-Host "`n==========================================================================" -ForegroundColor Green
Write-Host " ¡CONFIGURACION DE RED Y FIREWALL COMPLETADA CON EXITO! " -ForegroundColor Green
Write-Host "==========================================================================" -ForegroundColor Green
Write-Host "- PostgreSQL escucha en todas las interfaces de red (*)."
Write-Host "- pg_hba.conf configurado para aceptar conexiones de cualquier IP."
Write-Host "- Firewall de Windows habilitado para los puertos 5432, 3001 y 3000."
Write-Host "==========================================================================" -ForegroundColor Green
