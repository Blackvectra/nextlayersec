# 🧾 Incident Reports 

This folder standardizes how you **capture, triage, investigate, and learn** from incidents in your home‑SOC lab.

* Canonical location for incident reports, evidence pointers, timelines, comms logs
* Mapped to your **Validation Checklist** (NL‑###), frameworks, and MITRE ATT\&CK
* Lightweight but complete — suitable for real post‑mortems

---

## 📂 Folder layout

```
/guides/incident-reports/
├─ README.md                  # this guide
├─ INCIDENT-INDEX.md          # running index (table)
└─ reports/
   ├─ inc-2025-08-22-dns-blocking-regressed.md
   └─ inc-YYYY-MM-DD-<slug>.md

lab/validation/evidence/      # screenshots, logs referenced from reports
```

**Filename convention:** `inc-YYYY-MM-DD-<short-slug>.md`

---

## 🧰 Triage Severity

| Sev | Name     | Example impact                              | MTTR Target |
| --: | -------- | ------------------------------------------- | ----------: |
|  S1 | Critical | Inter‑VLAN isolation broken, SIEM offline   |        < 4h |
|  S2 | High     | DNS filtering bypass, key telemetry missing |       < 24h |
|  S3 | Medium   | Policy drift, noisy alerting                |        < 3d |
|  S4 | Low      | Cosmetic/doc issue                          |        < 7d |

---

## 🔁 Lifecycle

1. **Open** (new) → SEV set → IC assigned
2. **Investigate** (gather facts, reproduce, scope)
3. **Contain/Restore** (short‑term mitigation)
4. **Eradicate/Remediate** (root cause fixed)
5. **Verify** (run NL‑### checks)
6. **Learn** (add to lessons, backlog actions)
7. **Close** (document evidence, dates)

---

## 🧩 Incident Report Template (copy/paste)

```md
---
id: INC-{{YYYYMMDD}}-{{slug}}
status: Open | Investigating | Mitigated | Resolved | Closed
severity: S1 | S2 | S3 | S4
opened: 2025-08-22T12:34:00Z
closed: null
reporter: Matthew Levorson
incident_commander: <name>
affected_vlans: [10, 20, 30, 40]
affected_systems: [opnsense, cloudflare-gateway, wazuh, endpoints]
related_tests: [NL-003, NL-006, NL-013]
related_frameworks: [nist-csf: PR.AC-5, iso-27001:
```

