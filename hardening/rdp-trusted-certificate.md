# RDP with a validated server certificate (finding A-10)

**Status:** proposed, not validated in the lab. The lab test used `/cert:ignore`, which skips server verification.

1. Issue a server certificate for `win-rdp` from the existing CA with a Subject Alternative Name that matches the name or IP clients use (for example `10.10.5.10`).
2. Import it to the Windows machine certificate store (Local Machine > Personal) as a PFX.
3. Bind it to the RDP listener (elevated PowerShell):
   ```powershell
   $thumb = "<certificate thumbprint>"
   wmic /namespace:\\root\CIMV2\TerminalServices PATH Win32_TSGeneralSetting `
     WHERE TerminalName='RDP-Tcp' SET SSLCertificateSHA1Hash="$thumb"
   ```
4. Install the CA certificate into the client trust store (Windows: Trusted Root Certification Authorities).
5. Connect with verification on. For FreeRDP on Kali, pin the server fingerprint instead of ignoring it:
   ```bash
   xfreerdp3 /v:10.10.5.10 /u:<user> /cert:fingerprint:sha256:<fingerprint>
   ```
6. **Test:** the session opens with no certificate prompt or bypass option, and fails if the certificate is replaced.
