# Downloads Windows video native dependencies into windows/vendor/ for offline builds.
# Safe to re-run; skips files that already match the expected MD5.

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$VendorWindows = Join-Path (Join-Path $Root "windows") "vendor"

$CommonDir = Join-Path $VendorWindows "common"
$X64Dir = Join-Path $VendorWindows "x86_64"
$Arm64Dir = Join-Path $VendorWindows "aarch64"

foreach ($dir in @($CommonDir, $X64Dir, $Arm64Dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

function Get-FileMd5Hex([string]$Path) {
    $hash = Get-FileHash -Path $Path -Algorithm MD5
    return $hash.Hash.ToLowerInvariant()
}

function Ensure-File([string]$Url, [string]$Dest, [string]$ExpectedMd5) {
    if (Test-Path $Dest) {
        $actual = Get-FileMd5Hex $Dest
        if ($actual -eq $ExpectedMd5.ToLowerInvariant()) {
            Write-Host "OK (cached): $Dest"
            return
        }
        Write-Host "MD5 mismatch, re-downloading: $Dest"
        Remove-Item -Force $Dest
    }

    Write-Host "Downloading: $Url"
    Invoke-WebRequest -Uri $Url -OutFile $Dest -UseBasicParsing

    $actual = Get-FileMd5Hex $Dest
    if ($actual -ne $ExpectedMd5.ToLowerInvariant()) {
        Remove-Item -Force $Dest
        throw "Integrity check failed for $Dest (expected $ExpectedMd5, got $actual)"
    }

    Write-Host "Saved: $Dest"
}

$AngleUrl = "https://github.com/alexmercerind/flutter-windows-ANGLE-OpenGL-ES/releases/download/v1.0.1/ANGLE.7z"
$AngleMd5 = "e866f13e8d552348058afaafe869b1ed"

Ensure-File $AngleUrl (Join-Path $CommonDir "ANGLE.7z") $AngleMd5

$MpvBase = "https://github.com/media-kit/libmpv-win32-video-cmake/releases/download/20241021"

Ensure-File `
    "$MpvBase/mpv-dev-x86_64-20241021-git-0f78584.7z" `
    (Join-Path $X64Dir "mpv-dev-x86_64-20241021-git-0f78584.7z") `
    "6ecf18e85b093c3f7edb16f3ee6603f3"

Ensure-File `
    "$MpvBase/mpv-dev-aarch64-20241021-git-0f78584.7z" `
    (Join-Path $Arm64Dir "mpv-dev-aarch64-20241021-git-0f78584.7z") `
    "5b507a35db13eee6cb7eb21e8be7c83d"

Write-Host ""
Write-Host "Vendor layout ready under: $VendorWindows"
Write-Host "Commit vendor/*.7z (or use Git LFS) so consumers build without network access."
