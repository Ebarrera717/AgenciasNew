[Setup]
AppName=Korex NextJS
AppVersion=1.0
AppPublisher=Korex Corporation
DefaultDirName=F:\Korex_Sistema
DefaultGroupName=Korex
OutputDir=F:\Proyectos\AgenciasNew\Instalador
OutputBaseFilename=Korex_Setup
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
Source: "F:\Proyectos\AgenciasNew\deploy\Setup_Korex_Silent.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "F:\Proyectos\AgenciasNew\deploy\Korex_Diagnostics_Engine.ps1"; DestDir: "{app}\deploy"; Flags: ignoreversion

[Code]
var
  DbPage: TInputQueryWizardPage;
  GlobalPgHost, GlobalPgPort, GlobalPgDb, GlobalPgUser, GlobalPgPass: String;

function GetPgHost(Param: String): String; begin Result := GlobalPgHost; end;
function GetPgPort(Param: String): String; begin Result := GlobalPgPort; end;
function GetPgDb(Param: String): String; begin Result := GlobalPgDb; end;
function GetPgUser(Param: String): String; begin Result := GlobalPgUser; end;
function GetPgPass(Param: String): String; begin Result := GlobalPgPass; end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: Integer;
  AppDir: String;
  Cmd: String;
begin
  AppDir := ExpandConstant('{app}');
  // Detener el servicio, matar procesos remanentes de node en el directorio destino, y borrar cache vieja para evitar bloqueos de archivos
  Cmd := '-ExecutionPolicy Bypass -Command "' +
         'Stop-Service -Name Korex_NextJS -Force -ErrorAction SilentlyContinue; ' +
         'Get-Process -Name korex_nextjs -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue; ' +
         'sc.exe delete Korex_NextJS | Out-Null; ' +
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
  // Página Personalizada de Postgres (Añadida durante el proceso visual)
  DbPage := CreateInputQueryPage(wpSelectDir,
    'Configurar Base de Datos', 'Ingrese las credenciales de su PostgresSQL Local.',
    'El instalador verificará la conexión a PostgreSQL y creará la base de datos si no existe.');

  DbPage.Add('Servidor Host:', False);
  DbPage.Add('Puerto:', False);
  DbPage.Add('Base de Datos:', False);
  DbPage.Add('Usuario:', False);
  DbPage.Add('Contraseña:', True);

  DbPage.Values[0] := 'localhost';
  DbPage.Values[1] := '5432';
  DbPage.Values[2] := 'korex_db';
  DbPage.Values[3] := 'postgres';
  DbPage.Values[4] := 'zzeusagencias';
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  ResultCode: Integer;
  Host, Port: String;
  Cmd: String;
begin
  Result := True;
  if CurPageID = DbPage.ID then
  begin
    Host := DbPage.Values[0];
    Port := DbPage.Values[1];
    
    if (Trim(Host) = '') or (Trim(Port) = '') or (Trim(DbPage.Values[2]) = '') or (Trim(DbPage.Values[3]) = '') then
    begin
      MsgBox('Por favor complete todos los campos de conexión.', mbError, MB_OK);
      Result := False;
      Exit;
    end;

    // Verificar la conexión TCP a PostgreSQL usando PowerShell de fondo
    Cmd := '-ExecutionPolicy Bypass -Command "' +
           '$tc = New-Object System.Net.Sockets.TcpClient; ' +
           'try { ' +
           '  $tc.Connect(''' + Host + ''', ' + Port + '); ' +
           '  $tc.Close(); ' +
           '  exit 0; ' +
           '} catch { ' +
           '  exit 1; ' +
           '}"';
    
    if Exec('powershell.exe', Cmd, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      if ResultCode <> 0 then
      begin
        MsgBox('No se pudo conectar al servidor PostgreSQL en ' + Host + ':' + Port + '.' + #13#10#13#10 +
               'Verifique que el host y puerto sean correctos, y que el motor PostgreSQL esté activo.', mbError, MB_OK);
        Result := False;
      end
      else
      begin
        GlobalPgHost := Host;
        GlobalPgPort := Port;
        GlobalPgDb := DbPage.Values[2];
        GlobalPgUser := DbPage.Values[3];
        GlobalPgPass := DbPage.Values[4];
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
    Host := DbPage.Values[0];
    Port := DbPage.Values[1];
    DbName := DbPage.Values[2];
    User := DbPage.Values[3];
    Pass := DbPage.Values[4];
    
    // Crear el archivo maestro .env productivo inyectando los datos de este instalador.
    DbUrl := 'DATABASE_URL="postgresql://' + URLEncode(User) + ':' + URLEncode(Pass) + '@' + Host + ':' + Port + '/' + DbName + '?schema=public"';
    SaveStringToFile(ExpandConstant('{app}\.env'), DbUrl + #13#10, False);
    SaveStringToFile(ExpandConstant('{app}\.env'), 'NEXTAUTH_SECRET="KorexProductionSecretKey2024_Security"' + #13#10, True);
    SaveStringToFile(ExpandConstant('{app}\.env'), 'LICENSE_SECRET="Korex_Master_License_Secret_Key_2026_Secure"' + #13#10, True);
    SaveStringToFile(ExpandConstant('{app}\.env'), 'NEXTAUTH_URL="http://localhost:3000"' + #13#10, True);
    SaveStringToFile(ExpandConstant('{app}\.env'), 'PORT="3001"' + #13#10, True);
  end;
end;

[Run]
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Setup_Korex_Silent.ps1"" -PgHost ""{code:GetPgHost}"" -PgPort ""{code:GetPgPort}"" -PgDb ""{code:GetPgDb}"" -PgUser ""{code:GetPgUser}"" -PgPass ""{code:GetPgPass}"""; Flags: waituntilterminated runhidden; StatusMsg: "Configurando Node.js, Windows Services y Enrutamiento IIS... (Por favor espere)"
Filename: "http://localhost:3000/"; Flags: shellexec runasoriginaluser postinstall; Description: "Abrir la plataforma Korex en mi Navegador"
