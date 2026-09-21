[Setup]
AppName=Korex NextJS (Actualizacion)
AppVersion=1.0
AppPublisher=Korex Corporation
DefaultDirName=F:\Korex\Cotizaciones
DefaultGroupName=Korex
OutputDir=F:\Proyectos\AgenciasNew\Instalador
OutputBaseFilename=Korex_Update_Setup
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
Source: "F:\Proyectos\AgenciasNew\deploy\Update_Korex.ps1"; DestDir: "{app}"; Flags: ignoreversion
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

function DetectInstalledDirectory(): String;
var
  ResultCode: Integer;
  TmpFile: String;
  DetectedPath: String;
  Lines: TArrayOfString;
  Cmd: String;
begin
  DetectedPath := '';
  TmpFile := ExpandConstant('{tmp}\detected_path.txt');
  
  Cmd := '-ExecutionPolicy Bypass -Command "' +
         '$dir = ''''; ' +
         'try { Import-Module WebAdministration -ErrorAction SilentlyContinue; $site = Get-Website | Where-Object { $_.Name -like ''*Korex*'' } | Select-Object -First 1; if ($site) { $dir = $site.physicalPath } } catch {}; ' +
         'if (-not $dir) { try { $svc = Get-WmiObject win32_service -Filter ""name=''Korex_NextJS''"" -ErrorAction SilentlyContinue; if ($svc) { $p = $svc.PathName -replace ''"'',''''; $dir = [System.IO.Path]::GetDirectoryName($p.Split('' '')[0]) } } catch {} }; ' +
         'if ($dir) { [System.IO.File]::WriteAllText(''' + TmpFile + ''', $dir) }' +
         '"';

  Exec('powershell.exe', Cmd, '', SW_HIDE, ewWaitUntilTerminated, ResultCode);

  if FileExists(TmpFile) then
  begin
    if LoadStringsFromFile(TmpFile, Lines) then
    begin
      if GetArrayLength(Lines) > 0 then
        DetectedPath := Trim(Lines[0]);
    end;
    DeleteFile(TmpFile);
  end;

  Result := DetectedPath;
end;

procedure InitializeWizard;
var
  AutoPath: String;
begin
  AutoPath := DetectInstalledDirectory();
  if (AutoPath <> '') and DirExists(AutoPath) then
  begin
    WizardForm.DirEdit.Text := AutoPath;
  end;

  DbPage := CreateInputQueryPage(wpSelectDir,
    'Configuración de Base de Datos', 'Especificación de conexión para PostgreSQL',
    'Por favor verifique y corrija los datos de conexión para el portal Korex.');
  
  DbPage.Add('Servidor (Host):', False);
  DbPage.Add('Puerto:', False);
  DbPage.Add('Nombre de Base de Datos:', False);
  DbPage.Add('Usuario:', False);
  DbPage.Add('Contraseña (Password):', True);
  
  // Valores iniciales por defecto si no hay .env
  DbPage.Values[0] := 'localhost';
  DbPage.Values[1] := '5432';
  DbPage.Values[2] := 'korex_db';
  DbPage.Values[3] := 'postgres';
  DbPage.Values[4] := '';
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  ResultCode: Integer;
  AppDir: String;
  Host, Port, DbName, User, Pass: String;
  UrlLine, UrlPart: String;
  Lines: TArrayOfString;
  I: Integer;
  MatchIdx: Integer;
  Cmd: String;
begin
  Result := True;
  
  // Al salir de la selección del directorio, leer el .env existente y pre-llenar los campos
  if CurPageID = wpSelectDir then
  begin
    AppDir := WizardDirValue;
    if FileExists(AppDir + '\.env') then
    begin
      Host := 'localhost';
      Port := '5432';
      DbName := 'korex_db';
      User := 'postgres';
      Pass := '';
      
      if LoadStringsFromFile(AppDir + '\.env', Lines) then
      begin
        for I := 0 to GetArrayLength(Lines) - 1 do
        begin
          if Pos('DATABASE_URL=', Lines[I]) > 0 then
          begin
            UrlLine := Lines[I];
            StringChangeEx(UrlLine, 'DATABASE_URL=', '', True);
            StringChangeEx(UrlLine, '"', '', True);
            StringChangeEx(UrlLine, '''', '', True);
            
            MatchIdx := Pos('postgresql://', UrlLine);
            if MatchIdx > 0 then
            begin
              UrlPart := Copy(UrlLine, MatchIdx + 13, Length(UrlLine) - MatchIdx - 12);
              MatchIdx := Pos('@', UrlPart);
              if MatchIdx > 0 then
              begin
                User := Copy(UrlPart, 1, MatchIdx - 1);
                UrlPart := Copy(UrlPart, MatchIdx + 1, Length(UrlPart) - MatchIdx);
                
                MatchIdx := Pos(':', User);
                if MatchIdx > 0 then
                begin
                  Pass := Copy(User, MatchIdx + 1, Length(User) - MatchIdx);
                  User := Copy(User, 1, MatchIdx - 1);
                end;
                
                MatchIdx := Pos(':', UrlPart);
                if MatchIdx > 0 then
                begin
                  Host := Copy(UrlPart, 1, MatchIdx - 1);
                  UrlPart := Copy(UrlPart, MatchIdx + 1, Length(UrlPart) - MatchIdx);
                  
                  MatchIdx := Pos('/', UrlPart);
                  if MatchIdx > 0 then
                  begin
                    Port := Copy(UrlPart, 1, MatchIdx - 1);
                    UrlPart := Copy(UrlPart, MatchIdx + 1, Length(UrlPart) - MatchIdx);
                    
                    MatchIdx := Pos('?', UrlPart);
                    if MatchIdx > 0 then
                      DbName := Copy(UrlPart, 1, MatchIdx - 1)
                    else
                      DbName := UrlPart;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
      
      DbPage.Values[0] := Host;
      DbPage.Values[1] := Port;
      DbPage.Values[2] := DbName;
      DbPage.Values[3] := User;
      DbPage.Values[4] := Pass;
    end;
  end;

  // Validar conexión en la página DbPage
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
    
    // Crear el archivo maestro .env productivo inyectando los datos de este actualizador.
    DbUrl := 'DATABASE_URL="postgresql://' + URLEncode(User) + ':' + URLEncode(Pass) + '@' + Host + ':' + Port + '/' + DbName + '?schema=public"';
    SaveStringToFile(ExpandConstant('{app}\.env'), DbUrl + #13#10, False);
    SaveStringToFile(ExpandConstant('{app}\.env'), 'NEXTAUTH_SECRET="KorexProductionSecretKey2024_Security"' + #13#10, True);
    SaveStringToFile(ExpandConstant('{app}\.env'), 'NEXTAUTH_URL="http://localhost:3000"' + #13#10, True);
    SaveStringToFile(ExpandConstant('{app}\.env'), 'PORT="3001"' + #13#10, True);
  end;
end;

[Run]
Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\Update_Korex.ps1"" -PgHost ""{code:GetPgHost}"" -PgPort ""{code:GetPgPort}"" -PgDb ""{code:GetPgDb}"" -PgUser ""{code:GetPgUser}"" -PgPass ""{code:GetPgPass}"""; Flags: waituntilterminated runhidden; StatusMsg: "Aplicando actualización de archivos y base de datos... (Por favor espere)"
Filename: "http://localhost:3000/"; Flags: shellexec runasoriginaluser postinstall; Description: "Abrir la plataforma Korex actualizada en mi Navegador"
