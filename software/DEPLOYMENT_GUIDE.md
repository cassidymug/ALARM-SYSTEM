# Guardian Deployment Guide - Complete Hardware Specifications

## Deployment Levels Overview

| Level | Cameras | Use Case | Complexity | Cost Range |
|-------|---------|----------|------------|------------|
| **Level 1** | 4-8 | Small household, apartment | Simple | $500-1,500 |
| **Level 2** | 8-16 | Large house, duplex | Easy | $1,500-4,000 |
| **Level 3** | 16-32 | Small business, office | Moderate | $4,000-12,000 |
| **Level 4** | 32-64 | Medium business, retail | Advanced | $12,000-30,000 |
| **Level 5** | 64-128 | School, large facility | Professional | $30,000-75,000 |
| **Level 6** | 128-220+ | University, corporation | Enterprise | $75,000-250,000+ |

---

# Level 1: Small Household (4-8 Cameras)

## Use Case Scenarios

### Scenario A: Apartment/Condo
- **4 cameras**: Front door, back door, parking spot, hallway
- **Resolution**: 1080p (sufficient for most residential)
- **Features**: Motion detection, mobile alerts, 7-day cloud backup
- **Coverage**: Single dwelling unit

### Scenario B: Small House
- **8 cameras**: Front door, back door, garage, driveway, side yards (2×), backyard, front yard
- **Resolution**: 1080p standard, 4K for main entrance
- **Features**: Person detection, package detection, continuous recording
- **Coverage**: Small lot (0.25 acre / 1000 m²)

## Complete Hardware Specification

### Core System

**Guardian Hub:**
- **Model**: Intel N100 Mini PC or similar
- **Specs**:
  - CPU: Intel N100 (4-core, 3.4 GHz burst)
  - RAM: 16GB DDR4
  - Storage: 256GB NVMe (hot tier) + 4TB HDD (warm tier)
  - Network: Gigabit Ethernet
  - USB: 4× USB 3.0 ports
  - Size: 5" × 5" × 2" (compact)
- **Example**: Beelink EQ12 ($300) or custom build ($400)
- **Power**: 15-25W typical, 35W max

### Network Equipment

**PoE Switch:**
- **Model**: 8-port PoE+ switch
- **Specs**:
  - PoE budget: 120W total (15W per port)
  - Ports: 8× PoE+ (802.3at) + 2× gigabit uplink
  - VLAN support (camera isolation)
  - Fanless (silent operation)
- **Example**: TP-Link TL-SG1008P ($80) or Ubiquiti USW-Lite-8-PoE ($110)

**Router (if not existing):**
- **Gigabit ports**: 4+
- **WiFi**: Optional (cameras are wired)
- **VPN support**: For remote access
- **Example**: Ubiquiti EdgeRouter X ($60) or use existing router

### Cameras

**Standard Configuration:**
- **Quantity**: 8× cameras
- **Resolution**: 1080p @ 30fps (main), 720p @ 15fps (substream)
- **Codec**: H.265 (efficient compression)
- **Features**:
  - IR night vision (80-100ft range)
  - IP66/IP67 weatherproof
  - PoE powered
  - ONVIF compliant
  - 2-way audio (optional, for doorbell cam)
- **Example**: Reolink RLC-810A ($60 each) or Hikvision DS-2CD2143G2-I ($70 each)
- **Total camera cost**: $480-560 (8 cameras)

**Placement:**
1. Front door: 4K wide-angle (person ID)
2. Back door: 1080p wide-angle
3. Garage/driveway: 1080p with license plate capture
4. Side yards: 1080p motion detection
5. Backyard: 1080p perimeter monitoring

### Cabling

**CAT6a Ethernet:**
- **Quantity**: 8× cables, various lengths
- **Average length**: 100ft per camera (30m)
- **Total**: 800ft (245m) bulk cable
- **Cost**: $80-120 (bulk) or $15 each pre-made
- **Connectors**: RJ45 ends + crimp tool ($30)

**Cable Management:**
- Cable clips/staples: $20
- Conduit (outdoor runs): $50
- J-boxes (junction boxes): $40 (8× outdoor boxes)

### Alarm System (Optional Integration)

**Zone Expander:**
- **DIY Guardian GXP expander** (32 zones) - $55 (see hardware/ folder)
- **OR** existing DSC/Honeywell panel via Konnected ($150)

**Sensors:**
- 8× door/window contacts: $80 ($10 each)
- 2× motion sensors (PIR): $40 ($20 each)
- 1× glass break sensor: $30
- 1× siren: $40

### Physical Installation Requirements

**Mounting Hardware:**
- Camera mounts: Included with cameras
- Wall anchors/screws: $20
- Ladder: 8-10ft (homeowner provides)
- Drill + bits: Homeowner provides

**Power:**
- UPS battery backup: CyberPower 1000VA ($120)
  - Runtime: 2-3 hours for hub + switch
  - Protects against power outages

**Climate:**
- **Indoor installation** (closet, basement, utility room)
- Ambient temperature: 50-90°F (10-32°C)
- Ventilation: Passive (hub is fanless or quiet)
- **No special cooling required**

### Physical Security

**Equipment Security:**
- **Location**: Locked closet or utility room
- **Lock**: Standard keyed door lock (homeowner existing)
- **Cabinet**: Optional small wall-mount cabinet ($50-100)
  - Example: 12" × 12" × 6" vented steel box
  - Wall-mounted, lockable

**Camera Security:**
- **Tamper detection**: Cameras detect when moved/covered
- **Vandal-resistant domes**: Optional upgrade ($20/camera extra)
- **Height**: Mount 8-10ft high (out of reach)

### Installation Complexity

**DIY-Friendly:** ✅ Yes
- **Skill level**: Basic (drill holes, run cables, crimp RJ45)
- **Time**: 1-2 days (weekend project)
- **Tools needed**: Drill, ladder, crimper, wire stripper
- **Professional install**: $500-800 labor (optional)

## Complete Bill of Materials (Level 1)

| Component | Quantity | Unit Cost | Total |
|-----------|----------|-----------|-------|
| **Core System** | | | |
| Guardian Hub (mini PC) | 1 | $350 | $350 |
| NVMe SSD (256GB) | 1 | $30 | $30 |
| HDD (4TB) | 1 | $80 | $80 |
| **Network** | | | |
| PoE switch (8-port) | 1 | $90 | $90 |
| **Cameras** | | | |
| 1080p PoE cameras | 8 | $60 | $480 |
| **Cabling** | | | |
| CAT6a cable (1000ft) | 1 | $100 | $100 |
| Connectors/tools | 1 | $30 | $30 |
| Cable management | 1 | $50 | $50 |
| **Power** | | | |
| UPS (1000VA) | 1 | $120 | $120 |
| **Optional** | | | |
| Small wall cabinet | 1 | $75 | $75 |
| Alarm sensors | 1 set | $150 | $150 |
| **Installation** | | | |
| DIY (weekend) | - | $0 | $0 |
| Professional | - | $650 | - |
| **Total (DIY)** | | | **$1,555** |
| **Total (Pro Install)** | | | **$2,205** |

### Operating Costs (Annual)

| Item | Cost/Year |
|------|-----------|
| Electricity (25W × 24h × $0.12/kWh) | $26 |
| Cloud backup (optional, 100GB) | $60 |
| **Total Annual** | **$86** |

**5-year TCO**: $1,555 + ($86 × 5) = **$1,985** (DIY)

---

# Level 2: Large House (8-16 Cameras)

## Use Case Scenarios

### Scenario A: Large Single-Family Home
- **12 cameras**: Full perimeter coverage, pool area, side gates
- **Resolution**: Mix of 1080p and 4K
- **Coverage**: Medium lot (0.5 acre / 2000 m²)
- **Features**: License plate recognition (driveway), person tracking

### Scenario B: Duplex / Multi-Family
- **16 cameras**: Two units + shared areas
- **Resolution**: 1080p standard
- **Coverage**: Two separate dwellings + parking
- **Features**: Separate access per tenant

## Complete Hardware Specification

### Core System

**Guardian Hub:**
- **Model**: Custom-built mini workstation or Intel NUC
- **Specs**:
  - CPU: Intel i5-12400 or Ryzen 5 5600 (6-core)
  - RAM: 32GB DDR4
  - Storage: 512GB NVMe + 12TB HDD
  - Network: Dual gigabit Ethernet
  - GPU: Intel UHD graphics (sufficient for 16 cams)
- **Example**: Custom build ($700) or Intel NUC 12 Pro ($650)
- **Power**: 45-65W typical

### Network Equipment

**PoE Switch:**
- **Model**: 16-port PoE+ switch
- **Specs**:
  - PoE budget: 240W (15W per port)
  - Managed (VLAN, QoS support)
  - Fanless or quiet fan
- **Example**: TP-Link T1600G-18TS ($180) or Ubiquiti USW-16-PoE ($300)

**Patch Panel (Recommended):**
- **16-port CAT6 patch panel** - $40
- Keeps cabling organized

### Cameras

**Configuration:**
- **2× 4K cameras** (front + back entrances): $150 each = $300
- **14× 1080p cameras** (perimeter): $60 each = $840
- **Total camera cost**: $1,140

### Cabling

- **CAT6a bulk cable**: 2000ft ($200)
- **Conduit**: 200ft outdoor-rated ($80)
- **J-boxes**: 16× weatherproof boxes ($80)

### Physical Installation

**Equipment Cabinet:**
- **12U wall-mount rack** ($150)
  - Dimensions: 24" H × 19" W × 18" D
  - Lockable front door with ventilation
  - Cable management panel
- **Shelf**: For hub and UPS ($30)

**Power:**
- **UPS**: 1500VA (longer runtime) - $200
  - Runtime: 3-4 hours
  - Line-interactive (better protection)

**Cooling:**
- **Passive cooling**: Rack has ventilation holes
- **Optional**: Small 120mm fan ($15) if ambient >80°F

### Physical Security

**Cabinet Security:**
- **Keyed lock** on rack door (included)
- **Location**: Basement, utility room, or garage
- **Optional**: Bolt rack to wall studs ($20 hardware)

**Camera Security:**
- **Vandal domes** for exposed cameras: +$20 each (8 cameras = $160)
- **Wire protection**: Run cables through conduit

## Bill of Materials (Level 2)

| Component | Quantity | Unit Cost | Total |
|-----------|----------|-----------|-------|
| Guardian Hub (i5 build) | 1 | $700 | $700 |
| NVMe (512GB) + HDD (12TB) | 1 | $320 | $320 |
| 16-port PoE switch | 1 | $220 | $220 |
| 4K cameras | 2 | $150 | $300 |
| 1080p cameras | 14 | $60 | $840 |
| CAT6a cable + install | 1 | $360 | $360 |
| 12U wall rack + shelf | 1 | $180 | $180 |
| UPS (1500VA) | 1 | $200 | $200 |
| Vandal domes (optional) | 8 | $20 | $160 |
| **Total (DIY)** | | | **$3,280** |
| **Professional install** | | $1,200 | $1,200 |
| **Total (Pro)** | | | **$4,480** |

**Operating cost**: $50/year (electricity)  
**5-year TCO**: $3,530 (DIY)

---

# Level 3: Small Business (16-32 Cameras)

## Use Case Scenarios

### Scenario A: Small Retail Store
- **20 cameras**: Storefront, aisles, registers, stockroom, parking
- **Resolution**: 4K for registers (POS), 1080p elsewhere
- **Features**: People counting, POS integration, motion zones
- **Coverage**: 5,000 sq ft store + parking lot

### Scenario B: Office Building
- **32 cameras**: Entrances, hallways, parking, perimeter
- **Resolution**: 1080p standard, 4K main entrance
- **Features**: Access control integration, visitor logs
- **Coverage**: Small office building (10,000 sq ft)

## Complete Hardware Specification

### Core System

**Guardian Recorder Node:**
- **Quantity**: 1 (single node handles 32 cameras)
- **Specs**:
  - CPU: AMD Ryzen 7 7700 (8-core, 5.3 GHz boost)
  - RAM: 64GB DDR5
  - GPU: NVIDIA RTX 4060 Ti (optional, for AI detection)
  - Storage: 1TB NVMe + 2× 12TB HDD (RAID1)
  - Network: 10GbE NIC (future-proof) or dual gigabit
  - Case: 4U rackmount server chassis
- **Cost**: $2,500 (custom build)
- **Power**: 150-250W under load

### Network Equipment

**PoE Switches:**
- **2× 24-port PoE+ switches** ($450 each) = $900
  - Total ports: 48 (32 cameras + spare capacity)
  - PoE budget: 380W each
  - Managed, VLANs, QoS

**Core Switch (optional, for 10GbE backend):**
- **8-port 10GbE switch** - $600
  - Connects recorder to NAS (if using shared storage)

**Router/Firewall:**
- **Ubiquiti Dream Machine Pro** ($380) or pfSense box ($500)
  - VPN for remote access
  - VLAN routing (camera isolation)
  - Intrusion detection

### Cameras

**Configuration:**
- **4× 4K cameras** (entrance, POS, critical areas): $150 each = $600
- **28× 1080p cameras** (general coverage): $60 each = $1,680
- **Total**: $2,280

### Storage Expansion (Optional)

**NAS for long-term storage:**
- **Synology DS920+** (4-bay NAS) - $550
- **4× 8TB WD Red drives** - $560
- **Usable**: 24TB (RAID5) - 2-year retention
- **Total**: $1,110

### Infrastructure

**Server Rack:**
- **24U rack cabinet** ($800)
  - Dimensions: 42" H × 24" W × 36" D
  - Lockable front and rear doors
  - Removable side panels
  - Vented front door
  - PDU rail

**Rack Equipment:**
- **Rackmount shelf** (for hub, if not rackmount): $50
- **Patch panel**: 48-port CAT6a ($80)
- **Cable management**: Horizontal + vertical ($100)
- **PDU** (power distribution): 12-outlet, surge protected ($150)

**Power:**
- **UPS**: Rackmount 3000VA ($600)
  - Runtime: 30 minutes at full load
  - Runtime: 2-3 hours at typical load
  - Smart management (SNMP)

**Cooling:**
- **Rack fans**: 2× 120mm fans (top exhaust) - $40
  - Optional: AC vent to rack location
  - Keep room at 65-75°F (18-24°C)

### Physical Security

**Room Security:**
- **Dedicated IT closet/room**:
  - Lockable door: Commercial-grade deadbolt ($150)
  - Access log: Keypad entry ($200) or keyed
  - Signage: "Server Room - Authorized Access Only"

**Rack Security:**
- **Keyed front and rear doors** (included with rack)
- **Rack lock upgrade**: Combination lock option ($50)

**Environmental Monitoring:**
- **Temperature sensor**: APC NetBotz ($200)
  - Email alerts if room >85°F
  - Monitor humidity

### Professional Installation

**Complexity**: Requires professional (not DIY)
- **Electrical**: Dedicated 20A circuit for rack ($300)
- **Network cabling**: Certified CAT6a runs ($2,500)
  - 32 cameras, average 150ft runs
  - Conduit, testing, certification
- **Camera mounting**: Professional installer ($1,200)
- **System configuration**: Guardian tech ($800)

**Total professional install**: $4,800

## Bill of Materials (Level 3)

| Component | Quantity | Unit Cost | Total |
|-----------|----------|-----------|-------|
| **Compute** | | | |
| Recorder node (Ryzen 7) | 1 | $2,500 | $2,500 |
| **Network** | | | |
| 24-port PoE switches | 2 | $450 | $900 |
| Router/firewall | 1 | $380 | $380 |
| **Cameras** | | | |
| 4K cameras | 4 | $150 | $600 |
| 1080p cameras | 28 | $60 | $1,680 |
| **Infrastructure** | | | |
| 24U server rack | 1 | $800 | $800 |
| Patch panel + management | 1 | $230 | $230 |
| UPS (3000VA) | 1 | $600 | $600 |
| PDU | 1 | $150 | $150 |
| Cooling fans | 2 | $20 | $40 |
| **Security** | | | |
| Room lock + keypad | 1 | $350 | $350 |
| Temp monitoring | 1 | $200 | $200 |
| **Installation** | | | |
| Professional install | 1 | $4,800 | $4,800 |
| **Total** | | | **$13,230** |

**Operating costs**: $150/year (power + monitoring)  
**5-year TCO**: $13,980

---

# Level 4: Medium Business (32-64 Cameras)

## Use Case Scenarios

### Scenario A: Retail Chain Location
- **48 cameras**: Large store, parking lot, loading dock
- **Resolution**: 4K at registers + high-traffic, 1080p elsewhere
- **Features**: POS integration, people counting, heat mapping
- **Coverage**: 20,000 sq ft + parking

### Scenario B: Manufacturing Facility
- **64 cameras**: Production floor, warehouse, shipping, perimeter
- **Resolution**: 4K for quality control stations, 1080p general
- **Features**: Time-lapse, motion zones, safety monitoring
- **Coverage**: 50,000 sq ft facility

## Complete Hardware Specification

### Core System

**Guardian Recorder Nodes:**
- **Quantity**: 2 nodes (32 cameras each)
- **Specs per node**:
  - CPU: AMD Ryzen 9 7950X (16-core)
  - RAM: 64GB DDR5
  - GPU: NVIDIA RTX 4070 (AI detection + encoding)
  - Storage: 2TB NVMe + 4× 12TB HDD (RAID6)
  - Network: 10GbE NIC
  - Case: 4U rackmount
- **Cost per node**: $4,000
- **Total compute**: $8,000

### Network Equipment

**Core Switch:**
- **48-port 10GbE switch** ($2,500)
  - Backbone for recorder nodes + storage
  - Layer 3 routing
  - VLAN support

**PoE Switches:**
- **3× 24-port PoE+ switches** ($500 each) = $1,500
  - 72 ports total (64 cameras + spares)

**Firewall:**
- **pfSense or Fortinet FortiGate** ($1,200)
  - Enterprise-grade security
  - VPN, IDS/IPS
  - 10Gbps throughput

### Cameras

**Configuration:**
- **12× 4K cameras**: $150 each = $1,800
- **52× 1080p cameras**: $60 each = $3,120
- **Total**: $4,920

### Shared Storage

**NAS Cluster:**
- **Synology or TrueNAS** (12-bay) - $2,500
- **12× 18TB enterprise drives** - $3,600
- **Usable**: 180TB (RAID-Z2)
- **Total**: $6,100

### Infrastructure

**Server Rack:**
- **42U enclosed rack** ($1,500)
  - Dimensions: 78" H × 24" W × 42" D
  - Lockable front/rear
  - Tempered glass front door option
  - Cable management arms

**Rack Equipment:**
- **2× UPS (3000VA each, rackmount)**: $1,200
  - Redundant power
  - Runtime: 45 minutes full load
- **PDU**: 2× intelligent PDUs ($400)
- **Environmental**: Rack monitor + smoke detector ($400)
- **Cable management**: $200

**Cooling:**
- **Rack cooling unit**: 10,000 BTU in-rack AC ($1,800)
  - Mounts in rack, vents heat externally
  - Thermostat-controlled
  - Backup: Room HVAC keeps room at 72°F

### Physical Security

**Server Room:**
- **Dedicated room**: 100-200 sq ft
- **Access control**: Keycard system ($800)
  - Tracks who enters/exits
  - Badge readers inside/outside
- **Lock**: Grade 1 commercial deadbolt ($200)
- **Camera**: Aimed at server room door ($60)
- **Fire suppression**: Sprinkler (existing building) + FM-200 canister ($1,500)

**Rack Security:**
- **Keyed locks** on front/rear doors
- **Cable locks**: Secure equipment to rack rails ($100)
- **Inventory tags**: Asset management labels

### Professional Services

**Installation:**
- **Electrical**: 2× 30A circuits ($800)
- **HVAC**: AC unit install ($1,200)
- **Network**: Fiber backbone + CAT6a ($6,000)
- **Integration**: System config + testing ($2,500)

**Total professional**: $10,500

## Bill of Materials (Level 4)

| Component | Quantity | Unit Cost | Total |
|-----------|----------|-----------|-------|
| Recorder nodes | 2 | $4,000 | $8,000 |
| NAS storage (180TB) | 1 | $6,100 | $6,100 |
| Core switch (48p 10G) | 1 | $2,500 | $2,500 |
| PoE switches (24p each) | 3 | $500 | $1,500 |
| Firewall | 1 | $1,200 | $1,200 |
| Cameras (4K + 1080p) | 64 | - | $4,920 |
| 42U rack | 1 | $1,500 | $1,500 |
| 2× UPS (3000VA) | 2 | $600 | $1,200 |
| Rack cooling unit | 1 | $1,800 | $1,800 |
| Environmental monitoring | 1 | $400 | $400 |
| Server room security | 1 | $3,560 | $3,560 |
| Professional install | 1 | $10,500 | $10,500 |
| **Total** | | | **$43,180** |

**Operating costs**: $400/year (power + cooling)  
**5-year TCO**: $45,180

---

# Level 5: School / Large Facility (64-128 Cameras)

## Use Case Scenarios

### Scenario A: K-12 School
- **96 cameras**: Classrooms, hallways, entrances, playground, parking
- **Resolution**: 4K main entrances, 1080p classrooms/halls
- **Features**: Emergency lockdown integration, visitor management
- **Coverage**: 100,000 sq ft campus

### Scenario B: Large Agricultural Operation
- **128 cameras**: Barns, fields, equipment yards, processing, perimeter
- **Resolution**: Mix of 1080p and 4K
- **Features**: 24/7 monitoring, weather-resistant cameras
- **Coverage**: Multiple buildings + outdoor areas

## Complete Hardware Specification

### Core System

**Guardian Recorder Cluster:**
- **4× recorder nodes** (32 cameras each)
- **Specs per node**:
  - CPU: AMD Ryzen 9 7950X (16-core)
  - RAM: 64GB DDR5
  - GPU: NVIDIA RTX 4080 (NVENC for 32 cameras)
  - Storage: 4TB NVMe + local cache
  - Network: Dual 10GbE (redundant)
  - Case: 2U rackmount
- **Cost per node**: $5,000
- **Total compute**: $20,000

### Shared Storage

**TrueNAS Cluster:**
- **2× TrueNAS nodes** (HA failover)
- **24× 20TB enterprise drives per node**
- **Usable capacity**: 400TB (RAID-Z2)
- **Cost**: $25,000

### Network Equipment

**Core**: 100G backbone switch ($5,000)  
**Distribution**: 4× 48-port 10G switches ($10,000)  
**Access**: 6× 24-port PoE+ switches ($3,000)  
**Firewall**: Enterprise-grade ($2,500)

**Total network**: $20,500

### Cameras

- **16× 4K cameras**: $2,400
- **112× 1080p cameras**: $6,720
- **Total**: $9,120

### Infrastructure

**Main Server Room:**
- **42U rack** × 2 ($3,000)
- **PDUs**: 4× intelligent ($800)
- **UPS**: 2× 5000VA ($2,000)
- **Cooling**: 2× in-rack 14,000 BTU AC ($4,000)
- **Fire suppression**: FM-200 system ($5,000)
- **Environmental**: Comprehensive monitoring ($800)

**Total infrastructure**: $15,600

### Physical Security

**Server Room:**
- **Biometric access control** ($2,000)
  - Fingerprint + PIN
  - Audit log
- **Grade 1 locks** on racks
- **24/7 monitoring** (own cameras on room)
- **Intrusion alarm** ($500)

### Professional Services

**Design & Engineering**: $5,000  
**Installation**: $25,000  
**Training**: $3,000  
**Total**: $33,000

## Bill of Materials (Level 5)

| Component | Total Cost |
|-----------|------------|
| 4× Recorder nodes | $20,000 |
| TrueNAS cluster (400TB) | $25,000 |
| Network equipment | $20,500 |
| 128 cameras | $9,120 |
| Infrastructure (racks, UPS, cooling) | $15,600 |
| Physical security | $2,500 |
| Professional services | $33,000 |
| **Total** | **$125,720** |

**Operating costs**: $1,200/year  
**5-year TCO**: $131,720

---

# Level 6: Enterprise / University (220+ Cameras)

## Use Case Scenario

**Large university campus:**
- 220× 8K cameras
- Multiple buildings
- Parking structures
- Athletic facilities
- 24/7 security operations center

## Complete Hardware Specification

### Core System

**Recorder Cluster:**
- **7× recorder nodes** (32 cameras each)
- **Specs per node**: (as Level 5)
- **Total**: $35,000

### Storage

**Enterprise SAN:**
- **3× TrueNAS Enterprise nodes**
- **540TB usable**
- **Cost**: $90,000

### Network

**10/25/100GbE backbone**:
- **Core**: 100G switches ($15,000)
- **Distribution**: 10G switches ($25,000)
- **Access**: PoE switches ($10,000)
- **Total**: $50,000

### Infrastructure

**Dedicated Data Center Room:**
- **Size**: 500 sq ft climate-controlled
- **4× 42U racks** ($6,000)
- **Redundant cooling**: 60,000 BTU CRAC units ($25,000)
- **Redundant power**: 3-phase, dual UPS 10kVA each ($15,000)
- **Raised floor**: Cable management ($10,000)
- **Fire suppression**: FM-200 + VESDA smoke detection ($15,000)

**Total infrastructure**: $71,000

### Physical Security

**Data Center Security:**
- **Mantrap entry** (two-door system): $8,000
- **Biometric + card access**: $3,000
- **Security cameras** on data center: $500
- **Intrusion detection**: $2,000
- **24/7 monitoring**: Existing security

**Total security**: $13,500

### Professional Services

**Design**: $15,000  
**Installation**: $50,000  
**Commissioning**: $10,000  
**Training**: $5,000  
**Total**: $80,000

## Bill of Materials (Level 6)

| Component | Total Cost |
|-----------|------------|
| 7× Recorder nodes | $35,000 |
| Enterprise SAN (540TB) | $90,000 |
| Network infrastructure | $50,000 |
| 220× cameras (8K) | $33,000 |
| Data center build-out | $71,000 |
| Physical security | $13,500 |
| Professional services | $80,000 |
| **Total** | **$372,500** |

**Operating costs**: $5,000/year  
**5-year TCO**: $397,500

---

# Physical Security Summary by Level

| Level | Equipment Security | Access Control | Monitoring |
|-------|-------------------|----------------|------------|
| **1 (Home)** | Locked closet | Keyed door lock | None |
| **2 (Large Home)** | Locked 12U rack | Keyed door | Optional |
| **3 (Small Biz)** | Locked 24U rack | Keypad entry | Temperature |
| **4 (Medium)** | Locked 42U rack | Keycard system | Temp + humidity + smoke |
| **5 (School)** | Biometric access | Fingerprint + PIN | 24/7 comprehensive |
| **6 (Enterprise)** | Mantrap + biometric | Dual-factor auth | Data center monitoring |

# Cooling Requirements by Level

| Level | Cooling Strategy | Equipment | Annual Cost |
|-------|------------------|-----------|-------------|
| **1** | Passive (fanless/quiet) | None | $0 |
| **2** | Ventilated rack | Optional fan | $5 |
| **3** | Rack fans + room AC | 2× 120mm fans | $50 |
| **4** | In-rack AC unit | 10,000 BTU | $300 |
| **5** | Dual in-rack AC | 2× 14,000 BTU | $600 |
| **6** | CRAC units | 60,000 BTU | $2,400 |

# Professional Installation Recommendations

| Level | DIY Possible? | Recommended | Installation Cost |
|-------|---------------|-------------|-------------------|
| **1** | ✅ Yes | DIY or handyman | $0-650 |
| **2** | ⚠️ Maybe | Low-voltage tech | $1,200 |
| **3** | ❌ No | Certified installer | $4,800 |
| **4** | ❌ No | Professional team | $10,500 |
| **5** | ❌ No | System integrator | $33,000 |
| **6** | ❌ No | Enterprise integrator | $80,000 |

---

# Summary: Total Cost of Ownership (5 Years)

| Level | Cameras | Initial Cost | Annual OpEx | 5-Year TCO |
|-------|---------|--------------|-------------|------------|
| **1** | 4-8 | $1,555 | $86 | $1,985 |
| **2** | 8-16 | $3,280 | $50 | $3,530 |
| **3** | 16-32 | $13,230 | $150 | $13,980 |
| **4** | 32-64 | $43,180 | $400 | $45,180 |
| **5** | 64-128 | $125,720 | $1,200 | $131,720 |
| **6** | 220+ | $372,500 | $5,000 | $397,500 |

**Key Insight:** System scales linearly - double cameras ≈ double cost, with economies of scale at higher levels.

All solutions include:
- ✅ Modern hardware (2026 specs)
- ✅ Modular expansion path
- ✅ Appropriate security for asset value
- ✅ Professional installation at scale
- ✅ Room for growth (25% spare capacity)
