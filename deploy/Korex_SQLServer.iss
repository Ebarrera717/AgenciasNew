[Setup]
AppName=Korex AgenciasNew (SQL Server)
AppVersion=1.0
AppPublisher=Korex Corporation
DefaultDirName=F:\Korex_Sistema_SQLServer
DefaultGroupName=Korex
OutputDir=F:\Proyectos\AgenciasNew\Instalador
OutputBaseFilename=Korex_SQLServer_Setup
Compression=none
SolidCompression=no
PrivilegesRequired=admin
AllowNoIcons=yes
DisableProgramGroupPage=yes
DisableDirPage=no
UsePreviousAppDir=no
ArchitecturesInstallIn64BitMode=x64compatible
ArchitecturesAllowed=x64compatible

[Files]
Source: "F:\Proyectos\AgenciasNew\RELEASE_KOREX\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "F:\Proyectos\AgenciasNew\deploy\Setup_Korex_SQLServer_Silent.ps1"; DestDir: "{app}"; Flags: ignoreversion

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
         'sc.exe delete Korex_SQLServer_Service | Out-Null; ' +
         'Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object { $_.Path -like ''*' + AppDir + '*'' } | Stop-Process -Force -ErrorAction SilentlyContinue; ' +
         'Start-Sleep -Seconds 2; ' +
         'if (Test-Path ''' + AppDir + '\.next'') { Remove-Item ''' + AppDir + '\.next'' -Recurse -Force -ErrorAction SilentlyContinue }; ' +
         'if (Test-Path ''' + AppDir + '\public'') { Remove-Item ''' + AppDir + '\public'' -Recurse -Force -ErrorAction SilentlyContinue };' +
         '"';
  Exec('powershell.exe', Cmd, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Result := '';
end;

procedure InitializeWizard;
begin
  // Página 1: Conexión y Ubicación del Servidor SQL Server
  DbServerPage := CreateInputQueryPage(wpSelectDir,
    'Servidor y Base de Datos SQL Server', 
    'Ingrese los datos de ubicación de su Microsoft SQL Server existente.',
    'REGLA: El instalador verificará la conexión a la base restaurada de SQL Server (NO ejecutará CREATE DATABASE).');

  DbServerPage.Add('Servidor / Host (ej. 127.0.0.1, SRVPNV o SRVPNV\INSTANCIA):', False);
  DbServerPage.Add('Puerto SQL Server (opcional, por defecto 1433):', False);
  DbServerPage.Add('Nombre de la Base de Datos (ej. Korex_Zeus):', False);

  DbServerPage.Values[0] := '127.0.0.1';
  DbServerPage.Values[1] := '1433';
  DbServerPage.Values[2] := 'Korex_colaereo';

  // Página 2: Credenciales de Autenticación SQL Server
  DbAuthPage := CreateInputQueryPage(DbServerPage.ID,
    'Autenticación y Credenciales SQL Server', 
    'Ingrese el usuario y la contraseña de su Microsoft SQL Server.',
    'Asegúrese de ingresar un usuario con permisos de lectura y escritura en la base de datos.');

  DbAuthPage.Add('Usuario de SQL Server (ej. sa o zeusagencias):', False);
  DbAuthPage.Add('Contraseña de SQL Server:', True);

  DbAuthPage.Values[0] := 'sa';
  DbAuthPage.Values[1] := 'zzeusagencias';
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  ResultCode: Integer;
  Host, Port, DbName, User, Pass: String;
  ServerSpec: String;
  Cmd: String;
begin
  Result := True;

  if CurPageID = DbServerPage.ID then
  begin
    Host := Trim(DbServerPage.Values[0]);
    DbName := Trim(DbServerPage.Values[2]);

    if (Host = '') or (DbName = '') then
    begin
      MsgBox('Por favor complete los campos obligatorios (Servidor / Host y Base de Datos).', mbError, MB_OK);
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

    // Probar conexión auténtica a SQL Server con SqlConnection
    Cmd := '-ExecutionPolicy Bypass -Command "' +
           '$sc = ''Server=' + ServerSpec + ';Database=' + DbName + ';User Id=' + User + ';Password=' + Pass + ';Encrypt=False;TrustServerCertificate=True;Connection Timeout=8;''; ' +
           '$conn = New-Object System.Data.SqlClient.SqlConnection($sc); ' +
           'try { ' +
           '  $conn.Open(); ' +
           '  $conn.Close(); ' +
           '  exit 0; ' +
           '} catch { ' +
           '  exit 1; ' +
           '}"';

    if Exec('powershell.exe', Cmd, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      if ResultCode <> 0 then
      begin
        MsgBox('No se pudo validar la conexión a SQL Server en [' + ServerSpec + '] con la base [' + DbName + '].' + #13#10#13#10 +
               'Verifique:' + #13#10 +
               '1. Que la base de datos [' + DbName + '] esté creada o restaurada del backup.' + #13#10 +
               '2. Que el usuario [' + User + '] y la contraseña ingresados sean correctos.' + #13#10 +
               '3. Que el servicio de SQL Server esté activo en el servidor.', mbError, MB_OK);
        Result := False;
      end
      else
      begin
        GlobalSqlHost := Host;
        GlobalSqlPort := Port;
        GlobalSqlDb := DbName;
        GlobalSqlUser := User;
        GlobalSqlPass := Pass;
      end;
    end;
  end;
end;

function URLEncode(const S: String): String;
var
  I: Integer;
  C: Char;
  Code: Integer;
begin
  Result := '';
  for I := 1 to Length(S) do
  begin
    C := S[I];
    if ((C >= 'A') and (C <= 'Z')) or
       ((C >= 'a') and (C <= 'z')) or
       ((C >= '0') and (C <= '9')) or
       (C = '-') or (C = '_') or (C = '.') or (C = '~') then
      Result := Result + C
    else
    begin
      Code := Ord(C);
      Result := Result + '%' + Format('%.2x', [Code]);
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  DbUrl: String;
  Host, Port, DbName, User, Pass: String;
begin
  if CurStep = ssPostInstall then
  begin
    Host := Trim(DbServerPage.Values[0]);
    Port := Trim(DbServerPage.Values[1]);
    DbName := Trim(DbServerPage.Values[2]);
    User := Trim(DbAuthPage.Values[0]);
    Pass := Trim(DbAuthPage.Values[1]);
    if Port = '' then Port := '1433';
    
    DbUrl := 'DATABASE_URL_SQLSERVER="sqlserver://' + Host + ':' + Port + ';database=' + DbName + ';user=' + URLEncode(User) + ';password=' + URLEncode(Pass) + ';encrypt=false;trustServerCertificate=true"';
    SaveStringToFile(ExpandConstant('{app}\.env'), 'DATABASE_URL="sqlserver://' + Host + ':' + Port + ';database=' + DbName + ';user=' + URLEncode(User) + ';password=' + URLEncode(Pass) + ';encrypt=false;trustServerCertificate=true"' + #13#10, False);
    SaveStringToFile(ExpandConstant('{app}\.env'), DbUrl + #13#10, True);
    SaveStringToFile(ExpandConstant('{app}\.env'), 'NEXTAUTH_SECRET="KorexProductionSecretKey2024_Security"' + #13#10, True);
    SaveStringToFile(ExpandConstant('{app}\.env'), 'LICENSE_SECRET="Korex_Master_License_Secret_Key_2026_Secure"' + #13#10, True);
    SaveStringToFile(ExpandConstant('{app}\.env'), 'PORT="3001"' + #13#10, True);
  end;
end;

[Run]
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -File ""{app}\Setup_Korex_SQLServer_Silent.ps1"" -SqlHost ""{code:GetSqlHost}"" -SqlPort ""{code:GetSqlPort}"" -SqlDb ""{code:GetSqlDb}"" -SqlUser ""{code:GetSqlUser}"" -SqlPass ""{code:GetSqlPass}"""; Flags: waituntilterminated; StatusMsg: "Configurando Servicios y Enrutamiento..."
Filename: "http://localhost:3000/"; Flags: shellexec runasoriginaluser postinstall; Description: "Abrir la plataforma AgenciasNew en mi Navegador"
