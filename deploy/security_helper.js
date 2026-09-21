/**
 * deploy/security_helper.js
 * Módulo CommonJS autónomo para Encriptación y Desencriptación AES-256 de contraseñas de BD
 * Compatible con Node.js y PowerShell
 */

const crypto = require('crypto');

const DEFAULT_SECRET = 'Korex_Master_Security_Key_2026_Enterprise_AES';

function getDerivedKey(customSecret) {
    const secret = customSecret || process.env.ENCRYPTION_KEY || process.env.LICENSE_SECRET || DEFAULT_SECRET;
    return crypto.createHash('sha256').update(secret).digest();
}

function encryptPassword(plainText, customSecret) {
    if (!plainText || typeof plainText !== 'string') return plainText;
    const trimmed = plainText.trim();
    if (trimmed === '' || trimmed.startsWith('ENC(')) return plainText;

    try {
        const key = getDerivedKey(customSecret);
        const iv = crypto.randomBytes(16);
        const cipher = crypto.createCipheriv('aes-256-cbc', key, iv);
        let encrypted = cipher.update(plainText, 'utf8', 'hex');
        encrypted += cipher.final('hex');
        return `ENC(${iv.toString('hex')}:${encrypted})`;
    } catch (err) {
        console.error('[SECURITY_HELPER] Error al encriptar:', err.message);
        return plainText;
    }
}

function decryptPassword(cipherText, customSecret) {
    if (!cipherText || typeof cipherText !== 'string') return cipherText;
    const trimmed = cipherText.trim();
    if (!trimmed.startsWith('ENC(') || !trimmed.endsWith(')')) return cipherText;

    try {
        const inner = trimmed.slice(4, -1).trim();
        const parts = inner.split(':');
        if (parts.length !== 2) return cipherText;

        const [ivHex, encHex] = parts;
        if (!ivHex || !encHex) return cipherText;

        const key = getDerivedKey(customSecret);
        const iv = Buffer.from(ivHex, 'hex');
        const decipher = crypto.createDecipheriv('aes-256-cbc', key, iv);
        let decrypted = decipher.update(encHex, 'hex', 'utf8');
        decrypted += decipher.final('utf8');
        return decrypted;
    } catch (err) {
        return cipherText;
    }
}

function isEncrypted(value) {
    if (!value || typeof value !== 'string') return false;
    const trimmed = value.trim();
    return trimmed.startsWith('ENC(') && trimmed.endsWith(')') && trimmed.includes(':');
}

function decryptUrlPasswords(connectionUrl, customSecret) {
    if (!connectionUrl || typeof connectionUrl !== 'string') return connectionUrl;
    return connectionUrl.replace(/ENC\([a-fA-F0-9]+:[a-fA-F0-9]+\)/g, (match) => {
        return decryptPassword(match, customSecret);
    });
}

module.exports = {
    encryptPassword,
    decryptPassword,
    isEncrypted,
    decryptUrlPasswords
};
