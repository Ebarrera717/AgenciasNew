$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -ExecutionPolicy RemoteSigned -File F:\Proyectos\AgenciasNew\scripts\backup_korex.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At 11:00PM
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName "Backup_Korex_Test" -Action $action -Trigger $trigger -Settings $settings -Description "Respaldo diario automatico de la base de datos Korex_test de PostgreSQL" -Force
Write-Host "Tarea programada registrada exitosamente."
