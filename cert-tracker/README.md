# Certification-tracker
Tracks certifications and progress on current and future Certs
---

<p align="center">
  <img src="https://img.shields.io/badge/🎓-Certifications-red?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/🛣️-Roadmap-blue?style=for-the-badge"/>
</p>

---

## ✅ Completed

| Certification          | Issuing Body        | Year | Badge                                            |
|------------------------|---------------------|------|--------------------------------------------------|
| CompTIA A+             | CompTIA             | 2024 | ![A+](https://img.shields.io/badge/A%2B-Passed-green) |
| CompTIA Security+      | CompTIA             | 2025 | ![Sec+](https://img.shields.io/badge/Security%2B-Passed-green) |
| Certified in Cybersecurity (CC) | ISC2     | 2025 | ![CC](https://img.shields.io/badge/CC-Passed-green) |

---

## 🧠 In Progress

| Certification | Progress                                                            | Next Milestone |
|---------------|---------------------------------------------------------------------|----------------|
| CySA+         | <progress value="10" max="100"></progress> 10%                      | Finalize flashcard deck + lab VM deployment |
| SSCP          | <progress value="0" max="100"></progress> 0%                      | Build practice lab VM |
| Network+      | <progress value="50" max="100"></progress> 50%                      | Lock study plan + schedule exam window |
| Linux+        | <progress value="10" max="100"></progress> 10%                      | Spin up Linux lab VM + CLI essentials |
| PenTest+      | <progress value="0"  max="100"></progress> 0%                       | Build Kali/Windows lab + review objectives |

<details>
<summary>📚 CySA+ Study Plan & Resources</summary>

- SANS “Purple Team” whitepaper: [PDF link](https://example.com)  
- CySA+ flashcards: [Anki deck](https://ankiweb.net)  
- TryHackMe: “Threat Hunting” and “SOC Level 1” paths  
- Weekly Lab Focus:
  - Nmap enumeration + Burp Suite scanning combo  
  - Vulnerability chaining with known CVEs in simulated attack  
- Notes folder: `cert-tracker/notes/cysa/`

</details>

<details>
<summary>📚 SSCP Study Plan & Resources</summary>

- Official (ISC)² SSCP CBK  
- Quizlet flashcards: [Link](https://quizlet.com)  
- Virtual lab: Windows domain exploitation  
- Notes: `cert-tracker/notes/sscp/`

</details>
<details>
<summary>📚 Network+ Study Plan & Resources</summary>

- Official CompTIA **Network+ exam objectives** (latest)  
- Video course: Professor Messer (free) / your preferred platform  
- Labs: Packet Tracer, GNS3/EVE-NG, or physical gear
- Weekly Lab Focus:
  - Subnetting drills (VLSM), CIDR summarization
  - VLANs, trunking, inter-VLAN routing on OPNsense/switch
  - DHCP (scopes, reservations), DNS (forwarding, split-DNS)
  - NAT vs PAT on OPNsense; port-forwarding smoke tests
  - Wireshark captures: TCP 3-way handshake, TLS SNI, DHCP, DNS
  - Wireless basics: SSID security, WPA2/3, guest isolation
- Notes: `cert-tracker/notes/network-plus/`

</details>

<details>
<summary>📚 Linux+ Study Plan & Resources</summary>

- Official CompTIA **Linux+ exam objectives** (latest)  
- Study tracks: Linux Journey / LPIC-1 overlap / your preferred course  
- Weekly Lab Focus (Ubuntu/Debian + RHEL-like VM):
  - Users/groups, sudoers, file perms (`chmod/chown/setuid/setgid/sticky`)
  - Systemd service mgmt (`systemctl`), journald, logrotate
  - Networking: `ip`, `ss`, `iptables/nft`, hostname/DNS
  - Storage: partitions, LVM, fstab, swap
  - Packages: `apt`/`dnf`, repos, signing keys
  - Security: SSH hardening, Fail2ban, `ufw`/`firewalld`, basic SELinux/AppArmor concepts
  - Scripting: bash fundamentals, cron/systemd timers
- Notes: `cert-tracker/notes/linux-plus/`

</details>

<details>
<summary>📚 PenTest+ Study Plan & Resources</summary>

> Use **authorized targets only** (your lab VLAN30, intentionally vulnerable VMs like OWASP Juice Shop / Metasploitable / DVWA). Keep it legal and ethical.

- Official CompTIA **PenTest+ exam objectives** (latest)  
- Prep tracks: Intro to methodology, legal & scope, reporting
- Weekly Lab Focus:
  - Scoping & rules of engagement (write a sample ROE)
  - Recon & enumeration (host/service/web) — *document, don’t automate blindly*
  - Vulnerability analysis → prioritize findings; safe proof-of-concepts
  - Web testing on **OWASP Juice Shop/DVWA** (auth, input validation, session mgmt)
  - AD basics in a mini-domain: user discovery, misconfig identification (no real org data)
  - Reporting: write one short executive summary + technical findings with mitigations
- Tooling you’ll practice (lab-safe): nmap, curl, Feroxbuster, Burp Suite (Community), Wireshark  
  *(Avoid real-world exploitation content here; keep to lab VMs.)*
- Notes: `cert-tracker/notes/pentest-plus/`

</details>


---

## 🎯 Future Goals

- eJPT  
- GIAC GCFA  
- Offensive Security OSCP
```

---

