# ✅ NextLayerSec Validation Checklist

A step‑by‑step, repeatable checklist to verify segmentation, DNS filtering, endpoint protection, and SIEM visibility in your home lab. Capture evidence (screenshots/CLI output) and commit to the repo under `lab/validation/evidence/YYYYMMDD/`.

> **Assumptions (edit if different):** OPNsense edge FW, Eero Pro 7 in bridge/AP mode, VLANs 10/20/30/40 (Family/IoT/Lab/Guest), Cloudflare Gateway for DNS, **Wazuh SIEM** via `siem/wazuh` compose stack.

---

## How to use this checklist

* Run tests from **at least one host per VLAN** (Family, IoT, Lab, Guest).
* For each test, check ✅ when the **Expected Result** is met and save evidence.
* If a test fails, add a note in `docs/lessons-learned/` with **symptoms → root cause → fix → prevention**.

**Evidence directory example:**

```
lab/validation/evidence/2025-08-22/
  nl-001-family-dns-ok.png
  nl-003-iot-deny-rfc1918.txt
  nl-010-opnsense-syslog-in-wazuh.png
```

---

## Pre‑flight

* [ ] **PF-01** Confirm VLAN IP plan in `docs/network-plan.md` is current (subnets, gateways, DHCP ranges).
* [ ] **PF-02** Ensure Wazuh/Graylog stack is running (e.g., `docker ps` shows manager/indexer/dashboard).
* [ ] **PF-03** Confirm Cloudflare Gateway Location and DNS policies are active for your public IP.
* [ ] **PF-04** Ensure OPNsense is forwarding logs to SIEM (System → Settings → Logging / Targets).

---

## A. DNS & Internet Reachability (per VLAN)

> Run from a host inside the target VLAN.

**Commands (Linux/macOS):**

```bash
nslookup -type=txt whoami.cloudflare # shows resolver info
curl -I https://example.com
```

**Commands (Windows PowerShell):**

```powershell
Resolve-DnsName -Type TXT whoami.cloudflare
Invoke-WebRequest https://example.com -Method Head
```

| Test ID | VLAN | Description              | Expected Result                                        | Status |
| ------: | :--- | ------------------------ | ------------------------------------------------------ | :----: |
|  NL-001 | Any  | DNS works via CF Gateway | TXT answer from Cloudflare (resolver / location shown) |    ☐   |
|  NL-002 | Any  | Internet reachability    | `200 OK` from example.com                              |    ☐   |

**Evidence:** save terminal output/screenshot.

---

## B. DNS Filtering (policy validation)

> Use a **temporary policy rule** in Cloudflare Gateway to block a test domain you control (e.g., `blockme.yourdomain.tld`) or a harmless category you’ve enabled for blocking (e.g., `Newly Registered Domains`).

**Commands:**

```bash
nslookup blockme.yourdomain.tld
curl -I http://blockme.yourdomain.tld || true
```

| Test ID | VLAN   | Description                     | Expected Result                     | Status |
| ------: | :----- | ------------------------------- | ----------------------------------- | :----: |
|  NL-003 | Family | DNS block (policy applies)      | NXDOMAIN / REFUSED or CF block page |    ☐   |
|  NL-004 | IoT    | DNS block (stricter IoT policy) | NXDOMAIN / REFUSED                  |    ☐   |
|  NL-005 | Guest  | DNS block (guest policy)        | NXDOMAIN / REFUSED                  |    ☐   |

**Evidence:** screenshot of CF Gateway query logs + client output.

---

## C. Segmentation & Lateral Movement (inter‑VLAN)

> Replace host IPs with actual devices in each VLAN. All tests originate from **source VLAN** toward **destination VLAN**.

**Commands:**

```bash
# ICMP
ping -c 2 192.168.20.10  # Linux/macOS
Test-Connection -Count 2 192.168.20.10  # Windows

# Common lateral ports
nc -zv 192.168.10.10 445 3389 22 80  # Linux/macOS
Test-NetConnection 192.168.10.10 -Port 445  # Windows
```

| Test ID | From VLAN | To VLAN | Port(s)        | Expected Result                     | Status |
| ------: | :-------- | :------ | -------------- | ----------------------------------- | :----: |
|  NL-006 | IoT       | Family  | Any (ICMP/TCP) | **Blocked** (deny RFC1918 from IoT) |    ☐   |
|  NL-007 | Guest     | Any     | Any            | **Blocked** (guest isolated)        |    ☐   |
|  NL-008 | Family    | Lab     | 22/3389/445    | **Blocked** (no lateral to Lab)     |    ☐   |
|  NL-009 | Lab       | SIEM    | 1514/1515/5601 | **Allowed** (telemetry & dashboard) |    ☐   |

**Evidence:** terminal output + OPNsense firewall logs showing allow/deny.

---

## D. Allowed Egress from IoT

> IoT should usually have **DNS + NTP** only, plus vendor endpoints if required.

| Test ID | VLAN | Destination        | Port/Proto | Expected Result | Status |
| ------: | :--- | ------------------ | ---------: | --------------- | :----: |
|  NL-010 | IoT  | Firewall DNS (LAN) |     53/UDP | **Allowed**     |    ☐   |
|  NL-011 | IoT  | NTP (pool.ntp.org) |    123/UDP | **Allowed**     |    ☐   |
|  NL-012 | IoT  | RFC1918 subnets    |        Any | **Blocked**     |    ☐   |

**Evidence:** packet capture on OPNsense or firewall logs.

---

## E. SIEM Ingestion & Dashboards (Wazuh)

**Generate events:**

* **Firewall log**: attempt a blocked inter‑VLAN connection to create a **deny** entry.
* **DNS log**: perform NL‑003 `nslookup`.
* **Endpoint log** (Windows): run a harmless event, e.g., service start/stop, then confirm arrival.

**Wazuh checks (inside dashboard or API):**

* [ ] **NL-013** OPNsense firewall log seen within **5 minutes** of event.
* [ ] **NL-014** Cloudflare DNS log entries visible (query/response, client IP/VLAN).
* [ ] **NL-015** Endpoint/Defender alert or event appears in SIEM.
* [ ] **NL-016** Dashboard shows traffic by VLAN/subnet.

**Evidence:** screenshots of Wazuh dashboard searches with timestamps.

---

## F. Alerting / Notifications (optional)

If you set up notifications (email/Slack/Webhook):

* [ ] **NL-017** Send SIEM test alert (e.g., rule match on `test_alert` string) → notification received.
* [ ] **NL-018** Cloudflare Gateway alert webhook triggers on DNS block → notification received.

**Evidence:** notification screenshots + SIEM rule snippet.

---

## G. Backups & Config Drift

* [ ] **NL-019** Run `scripts/backup-opnsense.sh` → timestamped XML saved under `configurations/firewall/`.
* [ ] **NL-020** Export Cloudflare Gateway policies (JSON) to `configurations/cloudflare-gateway/`.
* [ ] **NL-021** Export switch config/backup to `configurations/switch/`.
* [ ] **NL-022** Export Defender baselines to `configurations/defender/`.

**Evidence:** committed artifacts + short CHANGELOG entry.

---

## H. Regression Matrix (quick)

> Run after major changes. Mark ✅/❌ for each VLAN.

|                 Test | Family | IoT | Lab | Guest |
| -------------------: | :----: | :-: | :-: | :---: |
|        NL-001 DNS OK |    ☐   |  ☐  |  ☐  |   ☐   |
|     NL-003 DNS Block |    ☐   |  ☐  |  ☐  |   ☐   |
| NL-006 Lateral Block |    ☐   |  ☐  |  ☐  |   ☐   |
|   NL-009 SIEM Egress |    ☐   |  ☐  |  ☐  |   ☐   |

---

## Notes

* Replace placeholder domain `blockme.yourdomain.tld` with one you own/control for safe policy testing.
* If using **Graylog** instead of Wazuh, adapt NL‑013\~NL‑016 to your search syntax.
* Record failures in `docs/lessons-learned/` and link back to the failing test IDs.
