# 🛡️ NextLayerSec Hardening & Digital Hygiene Guide

This guide defines the recurring security hygiene and hardening processes that keep my environment resilient.  
Frequency can be **weekly** or **twice per week** depending on workload.

---

## 🔐 1. Account & Access Hardening
**Goal:** Protect identity, reduce attack surface.  
- [ ] Review **Microsoft 365 Secure Score** (identity & device)  
- [ ] Check **sign-in logs** for failed attempts / anomalies  
- [ ] Rotate weak or reused credentials in password manager  
- [ ] Verify MFA factors (phone, Authenticator, FIDO keys)  
- [ ] Validate recovery emails + backup codes  

**Artifacts to update:**  
- `/docs/m365-secure-score.md`  
- `/docs/account-hygiene-log.md`  

---

## 💻 2. System & Device Hardening
**Goal:** Keep endpoints patched, monitored, and backed up.  
- [ ] Apply OS updates (Windows, macOS, iOS/iPadOS)  
- [ ] Update Python / Homebrew / NPM if flagged  
- [ ] Run Microsoft Defender / Endpoint scans  
- [ ] Verify 3-2-1 backup status (local SSD → cold storage → cloud/SharePoint)  
- [ ] Integrity check critical binaries (`explorer.exe`, DLLs)  

**Artifacts to update:**  
- `/docs/patch-log.md`  
- `/docs/system-integrity-checks.md`  

---

## 🌐 3. Network & Infrastructure Hardening
**Goal:** Protect network layers, enforce segmentation.  
- [ ] Review Cloudflare Gateway & WAF logs  
- [ ] Audit eero Pro 7 / router firmware  
- [ ] Confirm VLAN isolation works (Office / Guest / SmartHome)  
- [ ] Validate DNSSEC, SPF, DKIM, DMARC configs  

**Artifacts to update:**  
- `/docs/network-hygiene.md`  
- `/docs/domain-security.md`  

---

## 📂 4. GitHub & Project Hygiene
**Goal:** Keep repos tidy, track weekly progress.  
- [ ] Review **Weekly Ops Project Board**  
- [ ] Update `/docs/weekly-log.md` in each repo  
- [ ] Commit lab work, scripts, or notes  
- [ ] Close last week’s “Weekly Ops” issue, create new one  
- [ ] Sync automation feeds (ThreatFeedCollector, Vulnwatch)  

**Artifacts to update:**  
- `/docs/weekly-log.md`  
- `/docs/tooling-progress.md`  

---

## 🎓 5. Knowledge & Certification Hygiene
**Goal:** Stay on track with study & documentation.  
- [ ] Update **Certification Tracker** repo progress bars  
- [ ] Add new course notes → `school-notes` repo  
- [ ] Log resources/links in Slack Canvas (#frameworks, #blue-team)  

**Artifacts to update:**  
- `/docs/cert-roadmap.md`  
- `/docs/study-notes.md`  

---

## 💰 6. Financial & Privacy Hygiene (Monthly)
**Goal:** Protect personal data & finances.  
- [ ] Budget snapshot (Affirm + CC + subscriptions)  
- [ ] Audit subscription renewals / cancellations  
- [ ] Run HaveIBeenPwned / breach checks  
- [ ] Review privacy settings (Google, Apple, LinkedIn)  

**Artifacts to update:**  
- `/docs/financial-log.md`  
- `/docs/privacy-audit.md`  

---

## 📅 Frequency Options

### **Weekly (60–75 min, Sunday reset)**
Run all sections once per week.

### **Twice per week (Sun + Wed, ~40 min each)**
- **Session A (Sun):** Sections 1–3 (Accounts, Systems, Network)  
- **Session B (Wed):** Sections 4–5 (Projects, Knowledge)  

---

## 🔔 Reminder Integration
- Import `NLS-reminders.ics` into Apple Calendar → get alerts.  
- Optional: Create an Apple Reminders list called *“Digital Hygiene”* with these tasks repeating weekly.  
- Slack:  
