[Setup]
AppId={{A8F1D520-91E4-4C8E-8A24-7C5910BF1201}}
AppName=Korex AgenciasNew - Base de Datos (SQL Server)
AppVersion=1.0.0
AppPublisher=Korex Corporation
DefaultDirName=C:\Korex_SQLServer_BD
DefaultGroupName=Korex Base de Datos
OutputDir=..\Instalador
OutputBaseFilename=Korex_SQLServer_DB_Update_Setup
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
VersionInfoDescription=Korex Database Installer & Updater (SQL Server)
VersionInfoCopyright=Copyright (C) 2026 Korex Corporation
VersionInfoProductName=Korex AgenciasNew - Base de Datos SQL Server
VersionInfoProductVersion=1.0.0.0

[Files]
Source: "..\RELEASE_KOREX_SQLSERVER_BD\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.env, *.env.*, .env, *.bak*"

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
  // Página 1: Servidor y Nombre de la Base de Datos SQL Server
  DbServerPage := CreateInputQueryPage(wpSelectDir,
    'Servidor y Base de Datos SQL Server',
    'Ingrese los datos del servidor Microsoft SQL Server y el nombre de la Base de Datos.',
    'NOTA: Si la base de datos indicada NO existe en el servidor, el instalador la CREARÁ automáticamente antes de correr los scripts. Si YA existe, aplicará únicamente los scripts de actualización.');

  DbServerPage.Add('Servidor / Instancia SQL Server (ej. 127.0.0.1, SRVSQL o SRVSQL\INSTANCIA):', False);
  DbServerPage.Add('Puerto SQL Server (por defecto 1433):', False);
  DbServerPage.Add('Nombre de la Base de Datos (ej. Korex_colaereo):', False);

  DbServerPage.Values[0] := '127.0.0.1';
  DbServerPage.Values[1] := '1433';
  DbServerPage.Values[2] := 'Korex_colaereo';

  // Página 2: Credenciales de Autenticación SQL Server
  DbAuthPage := CreateInputQueryPage(DbServerPage.ID,
    'Credenciales de Microsoft SQL Server',
    'Ingrese el usuario y la contraseña de su servidor SQL Server.',
    'Si la base de datos aún no existe, asegúrese de utilizar un usuario con permisos para crear bases de datos (dbcreator / sysadmin).');

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
      MsgBox('Por favor ingrese el Servidor / Host y el Nombre de la Base de Datos.', mbError, MB_OK);
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

    // Conectar a 'master' para validar credenciales y verificar si la BD existe (Exit 0 = Existe, Exit 2 = No existe, Exit 1 = Error de conexión)
    Cmd := '-NoProfile -ExecutionPolicy RemoteSigned -Command "' +
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
               'Verifique:' + #13#10 +
               '1. Que la dirección del servidor y el puerto (' + Port + ') sean correctos.' + #13#10 +
               '2. Que el usuario y la contraseña sean válidos.' + #13#10 +
               '3. Que el servicio de SQL Server acepte conexiones TCP/IP.', mbError, MB_OK);
        Result := False;
        Exit;
      end
      else if ResultCode = 2 then
      begin
        if MsgBox('Conexión validada con el servidor SQL Server [' + ServerSpec + '].' + #13#10#13#10 +
                  'La base de datos [' + DbName + '] NO existe actualmente en el servidor.' + #13#10 +
                  'El instalador CREARÁ automáticamente la base de datos [' + DbName + '] y ejecutará todos los scripts de instalación y actualización.' + #13#10#13#10 +
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

[Run]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy RemoteSigned -File ""{app}\Update_Korex_SQLServer_BD.ps1"" -SqlHost ""{code:GetSqlHost}"" -SqlPort ""{code:GetSqlPort}"" -SqlDb ""{code:GetSqlDb}"" -SqlUser ""{code:GetSqlUser}"" -SqlPass ""{code:GetSqlPass}"""; Flags: waituntilterminated; StatusMsg: "Verificando/creando base de datos y aplicando actualización en SQL Server..."
