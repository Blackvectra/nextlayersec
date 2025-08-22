# Network & VLAN Plan

| VLAN | Name   | Subnet          | Gateway     | DHCP Range       | DNS (Primary)     | Notes |
|-----:|--------|-----------------|-------------|------------------|-------------------|-------|
| 10   | Family | 192.168.10.0/24 | 192.168.10.1| .100–.199        | Cloudflare GW     | Block lateral |
| 20   | IoT    | 192.168.20.0/24 | 192.168.20.1| .50–.199         | Cloudflare GW     | Deny RFC1918 |
| 30   | Lab    | 192.168.30.0/24 | 192.168.30.1| .50–.199         | Cloudflare GW     | Allow → SIEM |
| 40   | Guest  | 192.168.40.0/24 | 192.168.40.1| .100–.220        | Cloudflare GW     | Internet only |

**Inter-VLAN policy summary**
- Allow: Lab↔SIEM, Family→Internet, IoT→DNS/NTP only
- Deny: IoT→RFC1918, Guest→RFC1918, lateral between non-SIEM nets
