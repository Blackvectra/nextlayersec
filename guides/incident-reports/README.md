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
related_frameworks: [nist-csf: PR.AC-5, iso-27001: A.8.16]
summary: >
  One‑line plain‑English summary of the impact and scope.
---

## 1) What happened?
Describe the symptoms (user perspective), when it started, and how it was discovered.

## 2) Timeline (UTC)
- 12:34: Reporter observed <symptom>
- 12:40: IC assigned, set Sev S2
- 12:50: Reproduced using NL‑003
- 13:05: Applied temporary mitigation <change>
- 14:10: Root cause fix <PR/commit/rule export>

## 3) Detection & Evidence
- Screenshots/logs under: `lab/validation/evidence/2025-08-22/`
- SIEM search / query:
```

# paste Wazuh / Graylog filter or saved search link

````
- Cloudflare Gateway query logs (IDs): <ids>
- OPNsense firewall logs (filters): <details>

## 4) Impact Assessment
- Affected VLANs/subnets: …
- Blocked/allowed behavior that deviated from policy: …
- User impact: …

## 5) Root Cause Analysis
### 5.1 Five Whys (concise)
1. Why? …
2. Why? …
3. Why? …
4. Why? …
5. Why? …

### 5.2 Technical Details
- Config diff / commit: <link>
- Rule/policy before/after:
```diff
- old
+ new
````

## 6) Remediation & Verification

* Immediate mitigation: …
* Permanent fix: …
* Verification: run NL‑### (paste results)
* Regression added to checklist matrix: ✅ / ❌

## 7) Lessons Learned

* What worked / what didn’t: …
* Gaps in monitoring/alerting: …
* Playbook/runbook updates required: …

## 8) Action Items

| ID | Owner | Description                          | Priority | Due        |
| -: | :---- | ------------------------------------ | :------- | :--------- |
| A1 | name  | e.g., enforce DNS redirect on VLAN20 | High     | 2025‑08‑25 |

## 9) Attachments & Links

* Evidence dir: `lab/validation/evidence/2025-08-22/`
* Config exports: `configurations/...`
* Diagram reference: `diagrams/exports/network-overview.png`

````

---

## 📇 INCIDENT-INDEX.md (create this file)
Maintain a simple table for tracking and quick search.

```md
# Incident Index

| ID | Date | Sev | Title | Status | Affected | Links |
|---|------|----:|-------|--------|---------|-------|
| INC-2025-08-22-dns-regress | 2025‑08‑22 | S2 | DNS blocking regressed on VLAN10 | Resolved | VLAN10 | [report](reports/inc-2025-08-22-dns-regress.md) |
````

---

## 🔗 Cross‑references

* **Validation**: `lab/validation/validation-checklist.md`
* **Network plan**: `docs/network-plan.md`
* **Frameworks mapping**: `guides/frameworks/`

---

## 🔒 Evidence handling

* Do not commit secrets or raw tenant tokens.
* Redact PII/keys in screenshots.
* Use `.gitignore` for volatile dumps; only include minimal, redacted artifacts.
