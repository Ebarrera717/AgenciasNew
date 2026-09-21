# deploy/Korex_Security.psm1
# Módulo de seguridad criptográfica AES-256 para PowerShell en Korex

function Get-KorexDerivedKey {
    param([string]$Secret = $env:ENCRYPTION_KEY)
    if (-not $Secret) { $Secret = "Korex_Master_Security_Key_2026_Enterprise_AES" }
    $sha = [System.Security.Cryptography.SHA256]::Create()
    return $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Secret))
}

function Protect-KorexPassword {
    param([string]$PlainText, [string]$Secret)
    if (-not $PlainText -or $PlainText.Trim() -eq "" -or $PlainText.StartsWith("ENC(")) {
        return $PlainText
    }
    try {
        $key = Get-KorexDerivedKey -Secret $Secret
        $aes = [System.Security.Cryptography.Aes]::Create()
        $aes.Key = $key
        $aes.GenerateIV()
        $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

        $ivHex = [System.BitConverter]::ToString($aes.IV).Replace("-", "").ToLower()
        $enc = $aes.CreateEncryptor()
        $plainBytes = [System.Text.Encoding]::UTF8.GetBytes($PlainText)
        $cipherBytes = $enc.TransformFinalBlock($plainBytes, 0, $plainBytes.Length)
        $cipherHex = [System.BitConverter]::ToString($cipherBytes).Replace("-", "").ToLower()

        return "ENC($ivHex`:$cipherHex)"
    } catch {
        return $PlainText
    }
}

function Unprotect-KorexPassword {
    param([string]$EncryptedText, [string]$Secret)
    if (-not $EncryptedText -or -not $EncryptedText.StartsWith("ENC(") -or -not $EncryptedText.EndsWith(")")) {
        return $EncryptedText
    }
    try {
        $inner = $EncryptedText.Substring(4, $EncryptedText.Length - 5).Trim()
        $parts = $inner.Split(":")
        if ($parts.Count -ne 2) { return $EncryptedText }

        $key = Get-KorexDerivedKey -Secret $Secret
        $ivHex = $parts[0]
        $cipherHex = $parts[1]

        $iv = [byte[]]::new($ivHex.Length / 2)
        for ($i = 0; $i -lt $ivHex.Length; $i += 2) {
            $iv[$i / 2] = [Convert]::ToByte($ivHex.Substring($i, 2), 16)
        }

        $cipherBytes = [byte[]]::new($cipherHex.Length / 2)
        for ($i = 0; $i -lt $cipherHex.Length; $i += 2) {
            $cipherBytes[$i / 2] = [Convert]::ToByte($cipherHex.Substring($i, 2), 16)
        }

        $aes = [System.Security.Cryptography.Aes]::Create()
        $aes.Key = $key
        $aes.IV = $iv
        $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

        $dec = $aes.CreateDecryptor()
        $plainBytes = $dec.TransformFinalBlock($cipherBytes, 0, $cipherBytes.Length)
        return [System.Text.Encoding]::UTF8.GetString($plainBytes)
    } catch {
        return $EncryptedText
    }
}

Export-ModuleMember -Function Protect-KorexPassword, Unprotect-KorexPassword
