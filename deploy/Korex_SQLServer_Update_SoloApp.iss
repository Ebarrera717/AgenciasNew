[Setup]
AppId={{64F92526-34A6-4783-B330-3AD921EEB575}}
AppName=Korex AgenciasNew (Actualizador Web SQL Server - Sin BD)
AppVersion=1.0.0
AppPublisher=Korex Corporation
DefaultDirName=F:\Korex_Sistema_SQLServer
DefaultGroupName=Korex
OutputDir=..\Instalador
OutputBaseFilename=Korex_SQLServer_Update_SoloApp_Setup
Compression=none
SolidCompression=no
PrivilegesRequired=admin
AllowNoIcons=yes
DisableProgramGroupPage=yes
DisableDirPage=no
UsePreviousAppDir=yes
ArchitecturesInstallIn64BitMode=x64compatible
ArchitecturesAllowed=x64compatible
VersionInfoVersion=1.0.0.0
VersionInfoCompany=Korex Corporation
VersionInfoDescription=Korex Web Update (SQL Server - Sin BD)
VersionInfoCopyright=Copyright (C) 2026 Korex Corporation
VersionInfoProductName=Korex AgenciasNew
VersionInfoProductVersion=1.0.0.0

[Files]
Source: "..\RELEASE_KOREX\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.env, *.env.*, .env, *.bak*"
Source: "..\deploy\Update_Korex_SQLServer.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\deploy\Korex_Diagnostics_Engine.ps1"; DestDir: "{app}\deploy"; Flags: ignoreversion

[Code]
function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: Integer;
  AppDir: String;
begin
  AppDir := ExpandConstant('{app}');

  // Detención limpia del servicio web existente
  Exec('net.exe', 'stop Korex_SQLServer_Service', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Sleep(1500);

  // Limpieza segura y nativa de caché previo a la actualización
  if (AppDir <> '') and (AppDir <> 'C:\') and (AppDir <> 'C:\Windows') then
  begin
    if DirExists(AppDir + '\.next') then
      DelTree(AppDir + '\.next', True, True, True);
    if DirExists(AppDir + '\public') then
      DelTree(AppDir + '\public', True, True, True);
  end;

  Result := '';
end;

[Run]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy RemoteSigned -File ""{app}\Update_Korex_SQLServer.ps1"" -SkipDb"; Flags: waituntilterminated; StatusMsg: "Actualizando sitio web y reiniciando servicios..."
Filename: "http://localhost:3000/"; Flags: shellexec runasoriginaluser postinstall; Description: "Abrir la plataforma AgenciasNew en mi Navegador"
