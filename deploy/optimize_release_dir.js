const fs = require('fs');
const path = require('path');

const releaseDir = process.argv[2] || path.join(__dirname, '..', 'RELEASE_KOREX');

if (!fs.existsSync(releaseDir)) {
    process.exit(0);
}

let removedEnv = 0;
let removedJunkFiles = 0;
let removedJunkDirs = 0;

function cleanReleaseRoot(dir) {
    let entries;
    try {
        entries = fs.readdirSync(dir, { withFileTypes: true });
    } catch {
        return;
    }
    for (const entry of entries) {
        const fullPath = path.join(dir, entry.name);
        if (entry.isDirectory()) {
            if (entry.name === 'node_modules') continue;
            cleanReleaseRoot(fullPath);
        } else {
            const lower = entry.name.toLowerCase();
            if (lower === '.env' || lower.startsWith('.env.') || lower.endsWith('.env') || lower.includes('.bak')) {
                try {
                    fs.unlinkSync(fullPath);
                    removedEnv++;
                } catch {}
            }
        }
    }
}

function cleanNodeModules(dir) {
    let entries;
    try {
        entries = fs.readdirSync(dir, { withFileTypes: true });
    } catch {
        return;
    }
    for (const entry of entries) {
        const fullPath = path.join(dir, entry.name);
        const name = entry.name;
        const lower = name.toLowerCase();

        if (entry.isDirectory()) {
            if (
                lower === '.cache' ||
                lower === '@types' ||
                lower.startsWith('.next-') ||
                lower === '__tests__' ||
                lower === 'test' ||
                lower === 'tests' ||
                lower === 'docs'
            ) {
                try {
                    fs.rmSync(fullPath, { recursive: true, force: true });
                    removedJunkDirs++;
                } catch {}
                continue;
            }
            cleanNodeModules(fullPath);
        } else {
            if (
                lower.endsWith('.d.ts') ||
                lower.endsWith('.d.mts') ||
                lower.endsWith('.d.cts') ||
                lower.endsWith('.js.map') ||
                lower.endsWith('.mjs.map') ||
                lower.endsWith('.cjs.map') ||
                lower.endsWith('.d.ts.map') ||
                lower.endsWith('.md') ||
                lower === '.env' ||
                lower.startsWith('.env.')
            ) {
                try {
                    fs.unlinkSync(fullPath);
                    removedJunkFiles++;
                } catch {}
            }
        }
    }
}

cleanReleaseRoot(releaseDir);
const nmDir = path.join(releaseDir, 'node_modules');
if (fs.existsSync(nmDir)) {
    cleanNodeModules(nmDir);
}

console.log(`[OPTIMIZE] RELEASE_KOREX depurado: ${removedJunkFiles} archivos (.d.ts/.map/.md) y ${removedJunkDirs} carpetas de desarrollo removidos (${removedEnv} .env limpiados).`);
