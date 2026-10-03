const fs = require('fs');
const path = require('path');
const { generateManifest } = require('./generate_release_manifest');

function testReleaseManifest() {
  console.log('================================================================');
  console.log('  TEST: RELEASE MANIFEST INVENTORY & COVERAGE (REGLAS 1, 2, 3)');
  console.log('================================================================');

  generateManifest();

  const manifestPath = path.resolve(__dirname, '../SQL/manifest-sqlserver.json');
  if (!fs.existsSync(manifestPath)) {
    console.error('❌ FAIL: No se encontró manifest-sqlserver.json');
    process.exit(5);
  }

  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
  console.log(`Manifest cargado con ${manifest.totalObjects} objetos registrados.`);

  // Verify critical procedures exist in manifest
  const mandatorySps = [
    'dbo.spInvoicesObtener',
    'dbo.spExportInvoices',
    'dbo.spCotizacionCrear',
    'dbo.spCotizacionActualizar',
    'dbo.spCotizacionListar',
    'dbo.spCotizacionHistorial',
    'dbo.spFacturacionesCrear'
  ];

  const manifestMap = new Set(manifest.objects.map(o => o.objectName));
  const missing = mandatorySps.filter(s => !manifestMap.has(s));

  if (missing.length > 0) {
    console.error(`❌ FAIL [Exit Code 5]: El manifest no incluye los objetos obligatorios: ${missing.join(', ')}`);
    process.exit(5);
  }

  console.log('✅ TEST RELEASE MANIFEST PASSED: 100% de los objetos requeridos están en el manifest.');
}

if (require.main === module) {
  testReleaseManifest();
}

module.exports = { testReleaseManifest };
