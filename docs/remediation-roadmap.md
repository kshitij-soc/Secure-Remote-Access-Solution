# Remediation Roadmap

The assessment recorded **16 findings** (4 High, 8 Medium, 4 Low). Three were remediated in the lab. This page summarises what remains, why it matters and how to close it. Full register: [`09_Practical_Task1_Remote_Access_Assessment_Report.pdf`](09_Practical_Task1_Remote_Access_Assessment_Report.pdf).

## Priority 1: open High findings

| ID | Finding | Security impact | Plan | Effort |
|----|---------|-----------------|------|--------|
| A-11 | `win-rdp` password policy: minimum length 0, no history | Weak or reused passwords on an RDP host make brute force and credential reuse realistic | Set min length 12 and history 24 ([quick fixes](../hardening/quick-fixes.md)); keep the 5-attempt lockout | Low |
| A-12 | `win-laptop` SCA score 25% (122 passed, 349 failed); 2 critical, 26 high vulnerabilities | An unpatched remote endpoint is the likeliest entry point into the VPN | Patch critical and high CVEs first, then fix applicable SCA checks; re-scan with Wazuh | Medium |

## Priority 2: design gaps

| ID | Finding | Security impact | Plan | Effort |
|----|---------|-----------------|------|--------|
| A-09 | FORWARD policy still ACCEPT | A missing rule fails open instead of closed | [`forward-default-drop.sh`](../hardening/forward-default-drop.sh) with rollback timer; retest all allowed paths | Low |
| A-13 | Compliance check not tied to VPN login | A non-compliant device can still connect | [`endpoint-gated-vpn-connect.ps1`](../hardening/endpoint-gated-vpn-connect.ps1), then server-side posture attestation | Medium |
| A-05 | IPsec has no certificate revocation check | A stolen gateway certificate stays valid | [CRL plan](../hardening/ipsec-crl-revocation.md); test with a revoked certificate | Medium |
| A-10 | RDP tested with `/cert:ignore` | Exposes sessions to server impersonation | [Trusted certificate steps](../hardening/rdp-trusted-certificate.md) | Medium |

## Priority 3: hygiene

| ID | Finding | Action |
|----|---------|--------|
| A-04 | No `auth-nocache` on client | Add the directive |
| A-06 | Group-to-address firewall mapping maintained by hand | Automate rule generation from LDAP groups |
| A-07 | TOTP file of deleted user remains | Add to leaver checklist |
| A-14, A-15 | Hostname resolution warning; SYSTEM missing from share ACL | See [quick fixes](../hardening/quick-fixes.md) |

Accepted for the lab: A-08 (single gateway; use a pair in production) and A-16 (harmless outbound SMB rule).

## Validation status
Everything under `hardening/` is **proposed and untested**. Each item needs a before/after test and evidence before its finding can be closed.
