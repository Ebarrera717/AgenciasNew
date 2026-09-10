var Service = require('node-windows').Service;
var path = require('path');
var fs = require('fs');
var execSync = require('child_process').execSync;

// Verifica la ubicación de server.js
var scriptPath = path.join(__dirname, 'server.js');
if (!fs.existsSync(scriptPath)) {
    scriptPath = path.join(__dirname, '..', '.next', 'standalone', 'server.js');
}

// Leer puerto dinámicamente desde el archivo .env si existe
var port = 3001;
try {
  var envPath = path.join(__dirname, '.env');
  if (fs.existsSync(envPath)) {
    var envContent = fs.readFileSync(envPath, 'utf8');
    var match = envContent.match(/PORT\s*=\s*["']?(\d+)["']?/i);
    if (match) {
      port = parseInt(match[1], 10);
    }
  }
} catch (e) {
  console.error("No se pudo leer el puerto desde .env, usando 3001 como default:", e.message);
}

// Crea el objeto del nuevo servicio
var svc = new Service({
  name: 'Korex_NextJS',
  description: 'Servicio backend de Next.js para el proyecto Korex ejecutándose en Standalone Mode.',
  script: scriptPath,
  workingDirectory: __dirname,
  env: [
    {
      name: "PORT",
      value: port
    },
    {
      name: "NODE_ENV",
      value: "production"
    }
  ]
});

// Escucha eventos del instalador
svc.on('install', function() {
  console.log('Servicio instalado en Windows Exitosamente!');
  try { svc.start(); } catch(e) {}
});

svc.on('alreadyinstalled', function() {
  console.log('node-windows reporta ya instalado. Verificando SCM...');
  var isRegistered = false;
  try {
    var checkOutput = execSync('sc query Korex_NextJS', { encoding: 'utf8', stdio: 'pipe' });
    if (checkOutput && checkOutput.indexOf('Korex_NextJS') !== -1) {
      isRegistered = true;
    }
  } catch (e) {}

  if (!isRegistered) {
    try {
      var checkOutput2 = execSync('sc query korex_nextjs.exe', { encoding: 'utf8', stdio: 'pipe' });
      if (checkOutput2 && checkOutput2.indexOf('korex_nextjs') !== -1) {
        isRegistered = true;
      }
    } catch (e) {}
  }

  if (!isRegistered) {
    console.log('Servicio NO registrado en SCM de Windows. Forzando registro mediante ejecutable daemon...');
    var daemonExe = path.join(__dirname, 'daemon', 'korex_nextjs.exe');
    if (fs.existsSync(daemonExe)) {
      try {
        execSync('"' + daemonExe + '" install', { stdio: 'inherit' });
        console.log('Servicio registrado forzosamente via daemon wrapper.');
      } catch (err) {
        console.error('Error registrando servicio via daemon exe:', err.message);
      }
    }
  }

  console.log('Iniciando servicio...');
  try { svc.start(); } catch(e) {}
});

svc.on('start', function() {
  console.log('El servicio está ejecutándose de forma persistente internamente en el puerto ' + port);
});

// Instalar el servicio
svc.install();
