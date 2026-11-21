<h1 align="center">Secure Remote Access Solution</h1>
<p align="center">
  A hands-on lab that designs, builds, tests and assesses a secure remote access platform:<br>
  VPN, multi-factor authentication, zero trust segmentation, endpoint compliance and monitoring.
</p>
<p align="center">
  <img alt="OpenVPN" src="https://img.shields.io/badge/OpenVPN-TLS%201.3%20%7C%20AES--256--GCM-blue">
  <img alt="IPsec" src="https://img.shields.io/badge/IPsec-IKEv2%20%7C%20strongSwan-blue">
  <img alt="MFA" src="https://img.shields.io/badge/MFA-OpenLDAP%20%2B%20TOTP-success">
  <img alt="SIEM" src="https://img.shields.io/badge/SIEM-Wazuh-informational">
  <img alt="License" src="https://img.shields.io/badge/License-MIT-lightgrey">
</p>

## Overview

A global company needs employees to reach internal systems safely from home or while travelling. This project delivers a working design in a VMware lab, tests it from a remote client's point of view, then records what still needs fixing.

| Result | Value |
|---|---|
| Tests passed | **44** |
| Findings recorded | **16** (4 High, 8 Medium, 4 Low) |
| Remediated in the lab | 3 |
| Evidence screenshots | 96 |
| Design and plan documents | 10 |

## Architecture

```mermaid
flowchart LR
    C["Remote client (Kali)<br/>OpenVPN, certificate + password + TOTP"] -->|"TLS 1.3, AES-256-GCM<br/>10.8.0.0/24"| HQ
    subgraph HQ["gw-hq: VPN gateway, firewall, OpenLDAP, Wazuh agent"]
      direction TB
      F["iptables: per-user zone rules"]
    end
    HQ -->|"IPsec IKEv2, AES-256<br/>certificate auth"| BR["gw-branch<br/>10.10.2.0/24"]
    F --> APP["App zone<br/>10.10.3.10:8080 allowed"]
    F --> RDP["win-rdp<br/>10.10.5.10: RDP (NLA) + encrypted SMB"]
    F -. blocked .-> SENS["Sensitive zone<br/>10.10.4.10"]
    L["Windows laptop<br/>Defender + compliance check + Wazuh agent"] --> HQ
```

## What was built

| Area | Implementation |
|---|---|
| Encryption | OpenVPN (TLS 1.3, AES-256-GCM, tls-crypt) and site-to-site IPsec IKEv2 with AES-256 |
| Authentication | Client certificates, OpenLDAP identity, TOTP second factor through PAM |
| Revocation | CRL enforced on OpenVPN; revoked certificate rejected at the TLS handshake |
| Zero trust | Default-deny INPUT rules, per-user forwarding, isolated app and sensitive zones |
| Remote tools | RDP with NLA and lockout policy; SMB share with enforced encryption and least-privilege ACLs |
| Endpoint | Defender and ClamAV checks, PowerShell compliance script, Wazuh SCA |
| Monitoring | Wazuh agents and a custom level-12 rule for repeated SSH failures |
| People and policy | Security awareness training with quiz, remote access policy, compliance mapping |

## Lab environment

| Machine | Role |
|---|---|
| `gw-hq` | Hub gateway: OpenVPN, strongSwan, OpenLDAP, PAM + TOTP, iptables, Wazuh agent |
| `gw-branch` | Branch gateway at the other end of the IPsec tunnel |
| Kali Linux | Remote VPN client and test machine |
| `win-laptop` | Windows endpoint: Defender, compliance script, Wazuh agent |
| `win-rdp` | Windows Server for RDP and the encrypted SMB share |
| Wazuh server | Central monitoring and custom alert rules |

Built on VMware with isolated host-only networks.

## Skills demonstrated

VPN design (OpenVPN and IPsec) · PKI and certificate revocation · LDAP and MFA integration · Linux firewalling (iptables) · network segmentation and zero trust · Windows hardening (RDP, SMB, Defender) · SIEM and custom detection rules (Wazuh) · risk scoring (likelihood x impact) · security documentation and policy writing · security awareness training

## Selected evidence

| | |
|---|---|
| ![Encrypted tunnel](evidence/Task2-VPN/T2-10_kali-openvpn-log-tls13-aes256gcm-init-completed.jpeg)<br>**TLS 1.3 + AES-256-GCM tunnel established** | ![Revoked certificate](evidence/Task2-VPN/T2-13_gw-hq-journal-certificate-revoked-rejected.jpeg)<br>**Revoked certificate rejected by the gateway** |
| ![Zones](evidence/Task5-ZeroTrust/T5-10_kali-app-zone-open-sensitive-filtered.jpeg)<br>**App zone reachable, sensitive zone filtered** | ![Wazuh alert](evidence/Task7-Monitoring/T7-07_wazuh-custom-rule-100100-level12-fired.jpeg)<br>**Custom Wazuh rule 100100 firing** |

## Repository layout

```
docs/            10 design, plan and assessment documents (PDF; editable .docx in docs/source)
presentations/   Project summary and user security awareness training
evidence/        Lab screenshots grouped by task, with an index
hardening/       Proposed fixes for open findings (untested)
```

Start with [`docs/01_Remote_Access_Solution_Design_Document.pdf`](docs/01_Remote_Access_Solution_Design_Document.pdf), then the [assessment report](docs/09_Practical_Task1_Remote_Access_Assessment_Report.pdf) and the [remediation roadmap](docs/remediation-roadmap.md).

## Known limitations

- Endpoint compliance is shown as a standalone script; it is not yet wired to VPN login ([A-13](docs/remediation-roadmap.md)).
- IPsec certificate revocation is not enforced ([A-05](docs/remediation-roadmap.md)).
- The RDP test used `/cert:ignore` ([A-10](docs/remediation-roadmap.md)).
- 13 findings remain open or accepted; the plan is in the [roadmap](docs/remediation-roadmap.md).
- Files in `hardening/` are proposals and have not been validated in the lab.

## Disclaimer

This is an educational lab built in an isolated environment. Credentials, keys and certificates are not included. Do not apply these configurations to production systems without testing.

## Author

**Kshitij Rajesh Randhire**, cybersecurity analyst · [GitHub](https://github.com/kshitij-soc)

Released under the [MIT License](LICENSE).
