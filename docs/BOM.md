# Guardian — Hardware Bill of Materials (BOM)

**Scale:** Midpoint **12 cameras**, many sensor zones  
**Hub class:** Mini PC / NUC (not Raspberry Pi)  
**Prices:** Rough USD ballparks only — verify before purchase  
**Owner:** Cassidy Mugadza  

---

## 1. Hub (appliance)

| Item | Qty | Spec / notes | Est. USD (ea.) | Est. USD (line) |
|------|-----|--------------|----------------|-----------------|
| Mini PC / NUC | 1 | x86_64, 6+ cores preferred, 32 GB RAM, 2.5GbE or GigE, TPM nice-to-have | 450–800 | 450–800 |
| NVMe (OS + state) | 1 | 1 TB NVMe | 60–100 | 60–100 |
| Media storage | 1 | 4–8 TB NVMe or SATA SSD/HDD in enclosure/dock as fits chassis | 150–350 | 150–350 |
| Hub totals (ballpark) | | | | **~660–1,250** |

Notes: Size CPU for 12× Full HD+audio remux/record + detect + concurrent remote viewers. Prefer wired Ethernet only for cameras path.

---

## 2. Network / PoE

| Item | Qty | Spec / notes | Est. USD (ea.) | Est. USD (line) |
|------|-----|--------------|----------------|-----------------|
| PoE+ switch | 1 | 16-port PoE+ (or 24-port), Gigabit, budget for 12 cams + spare | 180–350 | 180–350 |
| Router / firewall | 0–1 | Use existing ISP router; optional dedicated firewall later | 0–200 | 0–200 |
| Ethernet patch / runs | lot | Cat6 to camera locations (DIY or installer) | — | 50–200 |
| Optional: spare injector | 1–2 | For non-PoE oddballs / test bench | 20–40 | 20–80 |
| Network totals (ballpark) | | | | **~250–830** |

---

## 3. Cameras (12 midpoint)

### Bulk cameras (Full HD + audio)

| Item | Qty | Spec / notes | Est. USD (ea.) | Est. USD (line) |
|------|-----|--------------|----------------|-----------------|
| Indoor/outdoor IP cams | 10 | 1080p (or better sensor), **audio mic**, RTSP/ONVIF, PoE preferred | 40–90 | 400–900 |

### Gate / door two-way audio stations

| Item | Qty | Spec / notes | Est. USD (ea.) | Est. USD (line) |
|------|-----|--------------|----------------|-----------------|
| Gate intercom station | 1 | Camera + **two-way audio** (mic+speaker), PoE or PoE+ | 120–250 | 120–250 |
| Door intercom station | 1 | Camera + **two-way audio**, PoE preferred | 100–220 | 100–220 |

| Cameras subtotal | 12 endpoints | Full HD + audio; 2 with full-duplex intercom | | **~620–1,370** |

Notes: Avoid stations that only work via vendor cloud. Prefer local RTSP + controllable talk path for `guardian-intercom`.

---

## 4. Sensors & alarm I/O

| Item | Qty | Spec / notes | Est. USD (ea.) | Est. USD (line) |
|------|-----|--------------|----------------|-----------------|
| Door/window contacts | 8–16 | Wired or wireless per chosen bus | 5–15 | 40–240 |
| PIR / motion | 4–8 | Interior coverage | 15–40 | 60–320 |
| Zone expander / I/O board | 1–2 | Multi-zone input to hub (USB/Ethernet/GPIO bridge) | 40–120 | 40–240 |
| Siren / strobe | 1 | 12V or networked siren | 25–80 | 25–80 |
| Panic / smoke (optional) | 0–2 | 24h-style zones if used | 20–60 | 0–120 |
| Cabling / resistors / power | lot | EOL resistors if wired alarm style | — | 20–60 |
| Sensors totals (ballpark) | | Many zones; expand later | | **~185–1,060** |

Exact bus (wired expander vs IP modules) is still an open hardware pick; BOM leaves room for either.

---

## 5. UPS & power

| Item | Qty | Spec / notes | Est. USD (ea.) | Est. USD (line) |
|------|-----|--------------|----------------|-----------------|
| UPS | 1 | Covers hub + PoE switch (+ ONT/router if desired); 1000–1500 VA class typical | 150–300 | 150–300 |
| Surge protection | 1 | Strip / PDU as needed | 20–50 | 20–50 |
| Camera midspan / spare PSU | as needed | If any non-PoE devices | 15–40 | 0–80 |
| UPS totals (ballpark) | | | | **~170–430** |

---

## 6. Hetzner (cloud) line items

| Item | Qty | Spec / notes | Est. USD / mo (ballpark) |
|------|-----|--------------|---------------------------|
| guardian-relay VM | 1 | CX/CPX-class or equivalent; public IPv4; sized for hubs×viewers | 10–40 |
| Object Storage (preferred) | 1 bucket | Ciphertext backups; pay for storage + egress | 5–30+ (usage) |
| *or* Storage Box | 1 | Alternative to Object Storage | 5–25+ |
| Snapshots / backups of VM | optional | Relay VM recovery | 1–5 |
| Hetzner totals (ballpark) | | Excludes heavy full-mirror bandwidth | **~15–75+/mo** |

Notes: Offsite scope (events-only vs rolling window vs full mirror) dominates storage and upload cost. Client-side encryption; Hetzner holds ciphertext only.

---

## 7. Suggested buy order

1. **Hub + OS disk + media disk** — prove appliance image and recorder on bench.
2. **PoE switch + 2–3 test cameras** (include one audio cam) — validate Full HD+audio ingest.
3. **UPS** — once hub/switch draw is known.
4. **Remaining bulk cameras** — after mount plan and PoE budget confirmed.
5. **Gate + door two-way stations** — after intercom prototype path is proven with one station.
6. **Sensors + expander + siren** — parallel with alarm service bring-up.
7. **Hetzner relay VM + Object Storage** — when `guardian-gateway` / backup ready for integration.
8. **Spares** — 1 cam, contact kit, patch leads.

---

## 8. Rough grand total (hardware, one-time)

| Bucket | Ballpark USD |
|--------|----------------|
| Hub | 660–1,250 |
| Network/PoE | 250–830 |
| Cameras (12) | 620–1,370 |
| Sensors | 185–1,060 |
| UPS/power | 170–430 |
| **DIY site hardware** | **~1,900–4,900** |
| Hetzner (monthly) | ~15–75+ |

Ranges are wide on purpose (brand, wired vs wireless sensors, HDD vs NVMe, installer cabling). Recheck live pricing before ordering.

---

*BOM sized for 8–16 camera systems at a **12-cam midpoint**. Not a purchase authorization — engineering planning only.*
