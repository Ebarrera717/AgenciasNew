[Setup]
AppId={{64F92526-34A6-4783-B330-3AD921EEB575}}
AppName=Korex AgenciasNew (Actualizador SQL Server)
AppVersion=1.0.0
AppPublisher=Korex Corporation
DefaultDirName=F:\Korex_Sistema_SQLServer
DefaultGroupName=Korex
OutputDir=..\Instalador
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
VersionInfoVersion=1.0.0.0
VersionInfoCompany=Korex Corporation
VersionInfoDescription=Korex Platform Update (SQL Server)
VersionInfoCopyright=Copyright (C) 2026 Korex Corporation
VersionInfoProductName=Korex AgenciasNew
VersionInfoProductVersion=1.0.0.0

[Files]
Source: "..\RELEASE_KOREX\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.env, *.env.*, .env, *.bak*"
Source: "..\deploy\Update_Korex_SQLServer.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\deploy\Korex_Diagnostics_Engine.ps1"; DestDir: "{app}\deploy"; Flags: ignoreversion

[Code]
var
  DbServerPage: TInputQueryWizardPage;
  DbAuthPage: TInputQueryWizardPage;
  GlobalSqlHost, GlobalSqlPort, GlobalSqlDb, GlobalSqlUser, GlobalSqlPass: String;

function GetSqlHost(Param: String): String; begin Result := GlobalSqlHost; end;
function GetSqlPort(Param: String): String; begin Result := GlobalSqlPort; end;
function GetSqlDb(Param: String): String; begin Result := GlobalSqlDb; end;
function GetSqlUser(Param: String): String; begin Result := GlobalSqlUser; end;
function GetSqlPass(Param: String): String; begin Result := GlobalSqlPass; end;

procedure InitializeWizard;
begin
  DbServerPage := CreateInputQueryPage(wpSelectDir,
    'Servidor y Base de Datos SQL Server',
    'Ingrese los datos de su Microsoft SQL Server y el nombre de la Base de Datos.',
    'NOTA: Si la base de datos indicada NO existe en el servidor, se CREARÁ automáticamente antes de ejecutar los scripts de actualización.');

  DbServerPage.Add('Servidor / Instancia SQL Server (ej. 127.0.0.1, SRVSQL o SRVSQL\INSTANCIA):', False);
  DbServerPage.Add('Puerto SQL Server (por defecto 1433):', False);
  DbServerPage.Add('Nombre de la Base de Datos (ej. Korex_colaereo):', False);

  DbServerPage.Values[0] := '127.0.0.1';
  DbServerPage.Values[1] := '1433';
  DbServerPage.Values[2] := 'Korex_colaereo';

  DbAuthPage := CreateInputQueryPage(DbServerPage.ID,
    'Credenciales de Microsoft SQL Server',
    'Ingrese el usuario y la contraseña de su servidor SQL Server.',
    'Asegúrese de utilizar un usuario con permisos de creación/actualización en SQL Server.');

  DbAuthPage.Add('Usuario de SQL Server (ej. sa o zeusagencias):', False);
  DbAuthPage.Add('Contraseña de SQL Server:', True);

  DbAuthPage.Values[0] := 'sa';
  DbAuthPage.Values[1] := '';
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  ResultCode: Integer;
  Host, Port, DbName, User, Pass: String;
  ServerSpec, SafeDbName, SafeUser, SafePass: String;
  Cmd: String;
begin
  Result := True;

  if CurPageID = DbServerPage.ID then
  begin
    Host := Trim(DbServerPage.Values[0]);
    DbName := Trim(DbServerPage.Values[2]);

    if (Host = '') or (DbName = '') then
    begin
      MsgBox('Por favor complete el Servidor / Host y el Nombre de la Base de Datos.', mbError, MB_OK);
      Result := False;
      Exit;
    end;
  end
  else if CurPageID = DbAuthPage.ID then
  begin
    Host := Trim(DbServerPage.Values[0]);
    Port := Trim(DbServerPage.Values[1]);
    DbName := Trim(DbServerPage.Values[2]);
    User := Trim(DbAuthPage.Values[0]);
    Pass := Trim(DbAuthPage.Values[1]);

    if Port = '' then Port := '1433';

    if (User = '') or (Pass = '') then
    begin
      MsgBox('Por favor ingrese el Usuario y la Contraseña de SQL Server.', mbError, MB_OK);
      Result := False;
      Exit;
    end;

    if (Port <> '') and (Port <> '1433') and (Pos(',', Host) = 0) and (Pos('\', Host) = 0) then
      ServerSpec := Host + ',' + Port
    else
      ServerSpec := Host;

    SafeDbName := DbName;
    StringChangeEx(SafeDbName, '''', '''''', True);
    SafeUser := User;
    StringChangeEx(SafeUser, '''', '''''', True);
    SafePass := Pass;
    StringChangeEx(SafePass, '''', '''''', True);

    Cmd := '-ExecutionPolicy Bypass -Command "' +
           '$sc = ''Server=' + ServerSpec + ';Database=master;User Id=' + SafeUser + ';Password=' + SafePass + ';Encrypt=False;TrustServerCertificate=True;Connection Timeout=8;''; ' +
           '$conn = New-Object System.Data.SqlClient.SqlConnection($sc); ' +
           'try { ' +
           '  $conn.Open(); ' +
           '  $cmd = $conn.CreateCommand(); ' +
           '  $cmd.CommandText = ''SELECT DB_ID(N'''''' + ''' + SafeDbName + ''' + '''''')''; ' +
           '  $dbId = $cmd.ExecuteScalar(); ' +
           '  $conn.Close(); ' +
           '  if ($null -eq $dbId -or $dbId -is [System.DBNull]) { exit 2 } else { exit 0 } ' +
           '} catch { ' +
           '  exit 1; ' +
           '}"';

    if Exec('powershell.exe', Cmd, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      if ResultCode = 1 then
      begin
        MsgBox('No fue posible conectar al servidor SQL Server [' + ServerSpec + '] con el usuario [' + User + '].' + #13#10#13#10 +
               'Verifique el servidor, puerto y credenciales de acceso.', mbError, MB_OK);
        Result := False;
        Exit;
      end
      else if ResultCode = 2 then
      begin
        if MsgBox('Conexión validada con el servidor SQL Server [' + ServerSpec + '].' + #13#10#13#10 +
                  'La base de datos [' + DbName + '] NO existe actualmente en el servidor.' + #13#10 +
                  'El instalador CREARÁ automáticamente la base de datos [' + DbName + '] y luego ejecutará los scripts de actualización.' + #13#10#13#10 +
                  '¿Desea crear la base de datos [' + DbName + '] y continuar?', mbConfirmation, MB_YESNO) = IDNO then
        begin
          Result := False;
          Exit;
        end;
      end;

      GlobalSqlHost := Host;
      GlobalSqlPort := Port;
      GlobalSqlDb := DbName;
      GlobalSqlUser := User;
      GlobalSqlPass := Pass;
    end;
  end;
end;

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
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\Update_Korex_SQLServer.ps1"" -SqlHost ""{code:GetSqlHost}"" -SqlPort ""{code:GetSqlPort}"" -SqlDb ""{code:GetSqlDb}"" -SqlUser ""{code:GetSqlUser}"" -SqlPass ""{code:GetSqlPass}"""; Flags: waituntilterminated; StatusMsg: "Verificando/creando base de datos, aplicando actualización y validaciones en SQL Server..."
Filename: "http://localhost:3000/"; Flags: shellexec runasoriginaluser postinstall; Description: "Abrir la plataforma AgenciasNew en mi Navegador"
