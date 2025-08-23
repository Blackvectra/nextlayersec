# NextLayerSec – Network & VLAN Plan (v1)

This file is the **source of truth** for the home‑lab network. It defines VLANs, addressing, DHCP scopes, DNS behavior, and baseline security policies so OPNsense, switch, Cloudflare Gateway, and SIEM all line up.

> Assumptions: OPNsense edge FW, managed switch with 802.1Q, Eero Pro 7 in bridge/AP mode, Wazuh SIEM.

---

## VLANs & Addressing

| VLAN | Name   | Subnet          | Gateway IP   | DHCP Range         | DNS Resolver                    | Notes                                                                |
| ---: | ------ | --------------- | ------------ | ------------------ | ------------------------------- | -------------------------------------------------------------------- |
|   10 | Family | 192.168.10.0/24 | 192.168.10.1 | 192.168.10.100-199 | Cloudflare Gateway via OPNsense | Default home devices. Block lateral to other VLANs.                  |
|   20 | IoT    | 192.168.20.0/24 | 192.168.20.1 | 192.168.20.50-199  | Cloudflare Gateway via OPNsense | **Deny RFC1918**, allow DNS/NTP only (+ vendor allowlist if needed). |
|   30 | Lab    | 192.168.30.0/24 | 192.168.30.1 | 192.168.30.50-199  | Cloudflare Gateway via OPNsense | For experiments. Allow to Internet; allow to SIEM only across VLANs. |
|   40 | Guest  | 192.168.40.0/24 | 192.168.40.1 | 192.168.40.100-220 | Cloudflare Gateway via OPNsense | Internet‑only; **no** access to RFC1918.                             |

Keep interface names consistent in OPNsense:

* `VLAN10_FAMILY`, `VLAN20_IOT`, `VLAN30_LAB`, `VLAN40_GUEST`

---

## Firewall Baseline (OPNsense)

**Interface → Rules (top to bottom):**

**VLAN20\_IOT**

1. `Allow DNS to FW` — Proto: TCP/UDP, Port: 53, Dest: This firewall (LAN IP)
2. `Allow NTP to Internet` — Proto: UDP, Port: 123, Dest: any
3. `Allow Vendor Allowlist` (optional) — Dest: specific FQDN/IPs
4. `Block RFC1918` — Dest: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 (quick = yes)
5. `Block Any` — Dest: any (default deny)

**VLAN40\_GUEST**

1. `Allow DNS to FW`
2. `Allow Internet` — Proto: any, Dest: not RFC1918 (alias `NOT_RFC1918`)
3. `Block RFC1918`

**VLAN10\_FAMILY**

1. `Allow Internet` — Dest: any
2. `Block to IoT/Lab/Guest` — Dest: `VLAN20_IOT net`, `VLAN30_LAB net`, `VLAN40_GUEST net`

**VLAN30\_LAB**

1. `Allow to SIEM` — Dest: `SIEM_HOST`, Ports: 1514/udp, 1515/tcp, 5601/tcp
2. `Allow Internet` — Dest: any
3. `Block to Family/IoT/Guest` — Dest: `VLAN10_FAMILY net`, `VLAN20_IOT net`, `VLAN40_GUEST net`

**Floating / NAT**

* **Outbound NAT**: Hybrid/Automatic.
* **DNS Enforcement (IoT/Guest)**: optional **Port Forward** (NAT redirect) UDP/TCP 53 → This firewall (per‑interface) to prevent DNS bypass.

**Logging**

* Enable rule logging for all **block** rules on VLAN interfaces.
* System → Settings → Logging / Targets: forward to SIEM (`udp/514` or your collector) and/or deploy a shipper.

---

## DNS Path (Cloudflare Gateway)

* OPNsense → System DNS points to **Cloudflare Gateway DoH** (or DoT) endpoints.
* Unbound/Resolver in **forwarding** mode; reply‑policy‑zone can optionally sinkhole RFC1918 lookups from IoT.
* Create CF Gateway **Location** for home public IP, enable **DNS logs**.
* Policies:

  * **Global**: Malware, DNS tunneling, Newly Registered Domains (NRD) → Block/Log.
  * **IoT**: Stricter — block adult content/social if desired.
  * **Guest**: Family‑safe policy.

---

## Switch Port Plan (example)

| Port | Role                | Mode   | Untagged | Tagged                  | Device                 |
| ---: | ------------------- | ------ | -------: | ----------------------- | ---------------------- |
|    1 | Uplink to OPNsense  | Trunk  |        — | 10,20,30,40             | OPNsense LAN (802.1Q)  |
|    2 | Access – Family     | Access |       10 | —                       | Family PC / NAS        |
|    3 | Access – Lab        | Access |       30 | —                       | Lab host / server      |
|    4 | Access – IoT Hub    | Access |       20 | —                       | Bridge for IoT devices |
|    5 | AP/Bridge (Eero) \* | Trunk  |       10 | 20,30,40 (if supported) | Eero Pro 7 (SSID→VLAN) |
|    6 | SIEM                | Access |       30 | —                       | Wazuh/Graylog          |

> \*If the AP cannot tag per‑SSID, keep AP untagged on VLAN10 and isolate Guest via the AP’s own guest feature; IoT VLAN devices should be wired or connected via a VLAN‑aware AP.

---

## SIEM Forwarding

* **OPNsense → SIEM**: Syslog to `SIEM_HOST:514/udp` (filter: firewall, unbound, dhcpd).
* **Endpoints**: Wazuh agents or Winlogbeat/OSQuery as desired.
* **Cloudflare Logs**: Logpush/API → ship to SIEM (document method in `docs/logging-pipeline.md`).

---

## Change Log

* v1: Initial plan with VLANs **10/20/30/40**, DHCP ranges and baseline rules.

---

## TODO

* Replace placeholders (`SIEM_HOST`) with actual IP/hostname.
* Attach screenshots of OPNsense interface assignments and rules as evidence.
