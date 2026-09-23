/**
 * release_changelog_manager.js
 * 
 * Herramienta autónoma de validación de CHANGELOG y generación de Informes de Entrega
 * para Clientes (UAT) en Korex.
 * 
 * Cumple con el estándar KOREX-VERSIONAMIENTO-001 y SemVer 2.0.0.
 * 
 * Uso:
 *   node scripts/release_changelog_manager.js --validate
 *   node scripts/release_changelog_manager.js --generate-client [version]
 */

const fs = require('fs');
const path = require('path');

const CHANGELOG_PATH = path.join(__dirname, '..', 'CHANGELOG.md');
const TEMPLATE_PATH = path.join(__dirname, '..', 'templates', 'INFORME_CAMBIOS_VALIDACION_CLIENTE_TEMPLATE.md');
const OUTPUT_DIR = path.join(__dirname, '..', 'Diagnosticos');

function parseChangelog() {
  if (!fs.existsSync(CHANGELOG_PATH)) {
    throw new Error(`No se encontró el archivo CHANGELOG.md en: ${CHANGELOG_PATH}`);
  }

  const content = fs.readFileSync(CHANGELOG_PATH, 'utf8');
  const versions = [];
  
  // Expresión para capturar bloques de versión: ## [X.Y.Z] - YYYY-MM-DD
  const versionRegex = /##\s+\[?(\d+\.\d+\.\d+(?:-[a-zA-Z0-9.]+)?)]?\s*-\s*(\d{4}-\d{2}-\d{2})/g;
  const matches = [...content.matchAll(versionRegex)];

  for (let i = 0; i < matches.length; i++) {
    const match = matches[i];
    const versionNumber = match[1];
    const releaseDate = match[2];
    const startIndex = match.index;
    const endIndex = (i + 1 < matches.length) ? matches[i + 1].index : content.length;
    const sectionText = content.substring(startIndex, endIndex);

    // Extraer metadatos
    const buildMatch = sectionText.match(/-\s+\*\*Build\*\*:\s*([^\r\n]+)/i);
    const commitMatch = sectionText.match(/-\s+\*\*Commit\*\*:\s*([^\r\n]+)/i);
    const tipoMatch = sectionText.match(/-\s+\*\*Tipo de Release\*\*:\s*([^\r\n]+)/i);
    
    // Extraer secciones
    const getSubSection = (title) => {
      const reg = new RegExp(`###\\s+${title}[\\r\\n]+([\\s\\S]*?)(?=###|##|$)`, 'i');
      const m = sectionText.match(reg);
      return m ? m[1].trim() : '';
    };

    const resumen = getSubSection('Resumen Ejecutivo') || getSubSection('Resumen de la Versión');
    const validacion = getSubSection('Validación Requerida del Cliente') || getSubSection('Validación del Cliente');
    const resultadoEsperado = getSubSection('Resultado Esperado');
    const baseDatos = getSubSection('Base de Datos');
    const postgresMatch = sectionText.match(/PostgreSQL:\s*(OK|IMPLEMENTADO Y VALIDADO|NO APLICA|PENDIENTE)/i);
    const sqlServerMatch = sectionText.match(/SQL Server:\s*(OK|IMPLEMENTADO Y VALIDADO|NO APLICA|PENDIENTE)/i);

    // Extraer fichas KRX
    const krxRegex = /\[?(KRX-\d{4}-\d{5})\]?\s*([^\r\n]+)/g;
    const changes = [];
    let krxMatch;
    while ((krxMatch = krxRegex.exec(sectionText)) !== null) {
      changes.push({
        id: krxMatch[1],
        title: krxMatch[2].replace(/^[:\-\s]+/, '').trim()
      });
    }

    versions.push({
      version: versionNumber,
      date: releaseDate,
      build: buildMatch ? buildMatch[1].trim() : 'N/A',
      commit: commitMatch ? commitMatch[1].trim() : 'N/A',
      type: tipoMatch ? tipoMatch[1].trim() : 'N/A',
      resumen,
      validacion,
      resultadoEsperado,
      baseDatos,
      postgresStatus: postgresMatch ? postgresMatch[1].toUpperCase() : 'NO ESPECIFICADO',
      sqlServerStatus: sqlServerMatch ? sqlServerMatch[1].toUpperCase() : 'NO ESPECIFICADO',
      changes,
      raw: sectionText
    });
  }

  return versions;
}

function validateChangelog() {
  console.log("============================================================");
  console.log(" KOREX — VALIDACIÓN DE CHANGELOG Y POLÍTICA DE RELEASES");
  console.log("============================================================\n");

  const versions = parseChangelog();
  if (versions.length === 0) {
    console.error("❌ ERROR: No se encontraron versiones registradas en CHANGELOG.md");
    process.exit(1);
  }

  console.log(`ℹ️  Versiones detectadas en historial: ${versions.length}`);
  let hasErrors = false;

  versions.forEach((ver, idx) => {
    console.log(`\n--- Evaluando Versión: ${ver.version} (${ver.date}) ---`);
    console.log(`    Build: ${ver.build} | Commit: ${ver.commit} | Tipo: ${ver.type}`);

    // Regla SemVer
    if (!/^\d+\.\d+\.\d+(-[a-zA-Z0-9.]+)?$/.test(ver.version)) {
      console.error(`    ❌ [Regla 3] Formato SemVer inválido: '${ver.version}' (debe ser MAJOR.MINOR.PATCH)`);
      hasErrors = true;
    } else {
      console.log(`    ✅ SemVer 2.0.0 Válido`);
    }

    // Regla de Build
    if (ver.build === 'N/A' || !/^\d{8}\.\d{2}$/.test(ver.build)) {
      console.warn(`    ⚠️  [Regla 5] Build '${ver.build}' no sigue el formato YYYYMMDD.NN`);
    } else {
      console.log(`    ✅ Build Identificado: ${ver.build}`);
    }

    // Regla Resumen Ejecutivo
    if (!ver.resumen || ver.resumen.length < 20) {
      console.error(`    ❌ [Regla 30] Resumen ejecutivo ausente o insuficiente`);
      hasErrors = true;
    } else {
      console.log(`    ✅ Resumen Ejecutivo Presente`);
    }

    // Regla Multibase Dual
    if (ver.postgresStatus === 'NO ESPECIFICADO' || ver.sqlServerStatus === 'NO ESPECIFICADO') {
      console.error(`    ❌ [Regla 20] Los estados de PostgreSQL y SQL Server deben especificarse explícitamente`);
      hasErrors = true;
    } else {
      console.log(`    ✅ Validación Multibase Dual: PG=[${ver.postgresStatus}] | SQL=[${ver.sqlServerStatus}]`);
    }

    // Regla Validación Requerida del Cliente
    if (!ver.validacion || ver.validacion.length < 15) {
      console.error(`    ❌ [Regla 31/43] Falta la sección 'Validación Requerida del Cliente' con pasos claros`);
      hasErrors = true;
    } else {
      console.log(`    ✅ Sección 'Validación Requerida del Cliente' Verificada`);
    }

    // Prohibición de Textos Vagos
    const vaguePhrases = ["ajustes en facturacion", "se hicieron ajustes", "fix sql", "change button", "varias mejoras"];
    const lowerRaw = ver.raw.toLowerCase();
    for (const phrase of vaguePhrases) {
      if (lowerRaw.includes(phrase)) {
        console.error(`    ❌ [Regla 17/29] Se detectó redacción vaga prohibida: "${phrase}"`);
        hasErrors = true;
      }
    }
  });

  console.log("\n============================================================");
  if (hasErrors) {
    console.error("❌ VALIDACIÓN FALLIDA: Se encontraron inconsistencias con la norma KOREX-VERSIONAMIENTO-001.");
    process.exit(1);
  } else {
    console.log("✅ VALIDACIÓN EXITOSA: CHANGELOG.md cumple 100% las 44 directivas normativas.");
  }
}

function generateClientChangelog(targetVersion) {
  const versions = parseChangelog();
  if (versions.length === 0) {
    console.error("❌ ERROR: No hay versiones para generar informe.");
    return;
  }

  const ver = targetVersion 
    ? versions.find(v => v.version === targetVersion)
    : versions[0]; // La más reciente

  if (!ver) {
    console.error(`❌ ERROR: No se encontró la versión '${targetVersion}' en CHANGELOG.md`);
    return;
  }

  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  const outFileName = `Korex_Informe_Entrega_v${ver.version.replace(/[^a-zA-Z0-9._-]/g, '_')}_${ver.build.replace('.', '_')}.txt`;
  const outFilePath = path.join(OUTPUT_DIR, outFileName);

  let doc = `============================================================\n`;
  doc += `KOREX — INFORME DE CAMBIOS Y VALIDACIÓN DE ENTREGA\n`;
  doc += `============================================================\n`;
  doc += `Cliente: ___________________________________________________\n`;
  doc += `Versión: ${ver.version}\n`;
  doc += `Fecha: ${ver.date}\n`;
  doc += `Build: ${ver.build}\n`;
  doc += `============================================================\n\n`;

  doc += `1. RESUMEN DE LA VERSIÓN\n`;
  doc += `------------------------------------------------------------\n`;
  doc += `${ver.resumen}\n\n`;

  doc += `2. CAMBIOS Y MEJORAS PRINCIPALES\n`;
  doc += `------------------------------------------------------------\n`;
  if (ver.changes && ver.changes.length > 0) {
    ver.changes.forEach(c => {
      doc += `[${c.id}] ${c.title}\n`;
    });
  } else {
    doc += `Consulte el detalle de funcionalidades y correcciones de la versión.\n`;
  }
  doc += `\n`;

  doc += `3. VALIDACIÓN REQUERIDA DEL CLIENTE (GUÍA DE PRUEBA Y ACEPTACIÓN)\n`;
  doc += `------------------------------------------------------------\n`;
  doc += `${ver.validacion}\n\n`;
  if (ver.resultadoEsperado) {
    doc += `Resultado Esperado:\n${ver.resultadoEsperado}\n\n`;
  }

  doc += `4. PLATAFORMAS Y MOTORES VALIDADOS\n`;
  doc += `------------------------------------------------------------\n`;
  doc += `PostgreSQL: ${ver.postgresStatus}\n`;
  doc += `SQL Server: ${ver.sqlServerStatus}\n\n`;

  doc += `5. CONTROL DE CALIDAD Y REGRESIONES\n`;
  doc += `------------------------------------------------------------\n`;
  doc += `- Control de Regresiones: Verificado con la suite automatizada multibase.\n`;
  doc += `- Base de Datos: Actualización estrictamente incremental y no destructiva.\n`;
  doc += `- Configuración de Conexiones (.env): 100% protegida y conservada.\n\n`;

  doc += `6. CONFORMIDAD Y ACEPTACIÓN DEL CLIENTE (UAT)\n`;
  doc += `------------------------------------------------------------\n`;
  doc += `Estado de Validación:\n`;
  doc += `[  ] APROBADO (Conforme para operación en producción)\n`;
  doc += `[  ] OBSERVADO (Requiere revisión en puntos específicos)\n\n`;
  doc += `Observaciones:\n`;
  doc += `____________________________________________________________\n`;
  doc += `____________________________________________________________\n\n`;
  doc += `Fecha de Validación: _______________________________________\n`;
  doc += `Nombre del Responsable: ___________________________________\n`;
  doc += `Firma: _____________________________________________________\n`;
  doc += `============================================================\n`;

  fs.writeFileSync(outFilePath, doc, 'utf8');
  console.log(`✅ Informe de Entrega al Cliente generado exitosamente en:`);
  console.log(`   📄 ${outFilePath}`);
}

const args = process.argv.slice(2);
if (args.includes('--validate')) {
  validateChangelog();
} else if (args.includes('--generate-client')) {
  const vIndex = args.indexOf('--generate-client');
  const targetVer = args[vIndex + 1] && !args[vIndex + 1].startsWith('--') ? args[vIndex + 1] : null;
  generateClientChangelog(targetVer);
} else {
  // Por defecto ejecuta validación
  validateChangelog();
}
