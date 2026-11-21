# Quick fixes for the low-effort findings

Proposed commands. They were not run in the lab, so test each one first.

| ID | Where | Command / change |
|----|-------|------------------|
| A-04 | `client.ovpn` | Add the line `auth-nocache` |
| A-07 | gw-hq (leaver step) | `sudo rm /home/<user>/.google_authenticator` (or the path set in the PAM config) after the LDAP account is removed |
| A-11 | win-rdp (elevated) | `net accounts /minpwlen:12 /uniquepw:24 /maxpwage:90` |
| A-14 | gw-hq | `echo "127.0.1.1 gw-hq" \| sudo tee -a /etc/hosts` |
| A-15 | win-rdp (elevated) | `icacls C:\Sh /grant "NT AUTHORITY\SYSTEM:(OI)(CI)F"` |
