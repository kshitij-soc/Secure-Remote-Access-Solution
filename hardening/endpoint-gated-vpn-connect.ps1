<#
.SYNOPSIS
  Starts the OpenVPN client only when the endpoint passes the compliance check.
.NOTES
  PROPOSED CONTROL - not validated in the lab (finding A-13).
  Client-side gate: it stops casual non-compliant connections but can be bypassed
  by a user with admin rights. Production should add server-side posture
  attestation (for example an EDR/NAC agent) on top of this.
#>
param(
  [string]$Profile  = "$env:USERPROFILE\OpenVPN\config\client.ovpn",
  [string]$Check    = "$env:USERPROFILE\Documents\vpn-compliance-check.ps1",
  [string]$OpenVpn  = "C:\Program Files\OpenVPN\bin\openvpn.exe"
)
$ErrorActionPreference = "Stop"
& powershell -NoProfile -ExecutionPolicy Bypass -File $Check
if ($LASTEXITCODE -ne 0) {
  Write-Host "[BLOCKED] Endpoint is NON-COMPLIANT (exit $LASTEXITCODE). VPN connection refused." -ForegroundColor Red
  exit 1
}
Write-Host "[ALLOWED] Endpoint is COMPLIANT. Starting VPN..." -ForegroundColor Green
& $OpenVpn --config $Profile
