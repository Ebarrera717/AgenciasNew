[Setup]
AppName=Korex AgenciasNew (Actualizador SQL Server)
AppVersion=1.0
AppPublisher=Korex Corporation
DefaultDirName=F:\Korex_Sistema_SQLServer
DefaultGroupName=Korex
OutputDir=F:\Proyectos\AgenciasNew\Instalador
OutputBaseFilename=Korex_SQLServer_Update_Setup
Compression=none
SolidCompression=no
PrivilegesRequired=admin
AllowNoIcons=yes
DisableProgramGroupPage=yes
DisableDirPage=no
UsePreviousAppDir=yes
ArchitecturesInstallIn64BitMode=x64compatible
ArchitecturesAllowed=x64compatible

[Files]
Source: "F:\Proyectos\AgenciasNew\RELEASE_KOREX\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.env, *.env.*, .env, *.bak*"
Source: "F:\Proyectos\AgenciasNew\deploy\Update_Korex_SQLServer.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "F:\Proyectos\AgenciasNew\deploy\Korex_Diagnostics_Engine.ps1"; DestDir: "{app}\deploy"; Flags: ignoreversion

[Code]
function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: Integer;
  AppDir: String;
  Cmd: String;
begin
  AppDir := ExpandConstant('{app}');
  Cmd := '-ExecutionPolicy Bypass -Command "' +
         'Stop-Service -Name Korex_SQLServer_Service -Force -ErrorAction SilentlyContinue; ' +
         'Get-Process -Name korex_sqlserver -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue; ' +
         'Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object { $_.Path -like ''*' + AppDir + '*'' } | Stop-Process -Force -ErrorAction SilentlyContinue; ' +
         'Start-Sleep -Seconds 2; ' +
         'if (Test-Path ''' + AppDir + '\.next'') { Remove-Item ''' + AppDir + '\.next'' -Recurse -Force -ErrorAction SilentlyContinue }; ' +
         'if (Test-Path ''' + AppDir + '\public'') { Remove-Item ''' + AppDir + '\public'' -Recurse -Force -ErrorAction SilentlyContinue };' +
         '"';
  Exec('powershell.exe', Cmd, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Result := '';
end;

[Run]
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\Update_Korex_SQLServer.ps1"""; Flags: waituntilterminated; StatusMsg: "Aplicando actualización, diagnósticos y validaciones en SQL Server..."
Filename: "http://localhost:3000/"; Flags: shellexec runasoriginaluser postinstall; Description: "Abrir la plataforma AgenciasNew en mi Navegador"
