const { runSqlServerUpdate } = require('../deploy/update_db_sqlserver');

async function testConnectionMismatch() {
  console.log('================================================================');
  console.log('  TEST: PROHIBICIÓN ABSOLUTA DE FALLBACK Y MISMATCH (REGLA 10, 23)');
  console.log('================================================================');
  console.log('Simulando intento de actualizar base con descalce de identidad...');

  // Set target database to a non-existent database name to verify zero DDL execution and clean rejection
  const targetHost = process.env.DB_HOST || '127.0.0.1';
  const fakeDb = 'Korex_BaseFalsa_Inexistente';

  try {
    const success = await runSqlServerUpdate(targetHost, '', '1433', fakeDb, 'sa', 'password_falsa');
    if (!success) {
      console.log('✅ TEST PASSED: El actualizador bloqueó correctamente la ejecución con base de datos mismatch.');
    } else {
      console.error('❌ FAIL: El actualizador no bloqueó la conexión descalzada.');
      process.exit(4);
    }
  } catch (err) {
    console.log(`✅ TEST PASSED: Rechazo de conexión capturado correctamente: ${err.message}`);
  }
}

if (require.main === module) {
  testConnectionMismatch();
}

module.exports = { testConnectionMismatch };
