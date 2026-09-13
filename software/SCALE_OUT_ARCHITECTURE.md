# Guardian Scale-Out Architecture - 220+ 8K Cameras

## The Challenge

**220 cameras @ 8K H.265 recording simultaneously:**

| Metric | Per Camera | 220 Cameras | Challenge |
|--------|-----------|-------------|-----------|
| **Bitrate** | 60 Mbps | 13.2 Gbps | Single NIC can't handle |
| **RAM buffer** | 256 MB | 56 GB | Exceeds single node |
| **Disk write** | 240 MB/s | 52.8 GB/s | Impossible on single machine |
| **Storage/day** | 65 GB | 14.3 TB | Need massive storage |
| **30-day storage** | 1.95 TB | 429 TB | Requires SAN/NAS |

**Single-node Guardian:** ❌ Can't handle this scale  
**Solution:** ✅ **Distributed multi-node cluster**

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Guardian Cluster (220 cameras)                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │   Node 1     │  │   Node 2     │  │   Node N     │             │
│  │  32 cameras  │  │  32 cameras  │  │  28 cameras  │             │
│  │  (1.92 Gbps) │  │  (1.92 Gbps) │  │  (1.68 Gbps) │             │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘             │
│         │                  │                  │                      │
│         └──────────────────┴──────────────────┘                      │
│                            │                                         │
│                  ┌─────────▼──────────┐                             │
│                  │   10G/25G Switch   │                             │
│                  └─────────┬──────────┘                             │
│                            │                                         │
│         ┌──────────────────┼──────────────────┐                     │
│         │                  │                  │                      │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐             │
│  │  NAS/SAN     │  │  NAS/SAN     │  │  NAS/SAN     │             │
│  │  Array 1     │  │  Array 2     │  │  Array 3     │             │
│  │  (150 TB)    │  │  (150 TB)    │  │  (150 TB)    │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
│                                                                      │
│  ┌─────────────────────────────────────────────────────┐            │
│  │         Metadata/Control Database                   │            │
│  │  (PostgreSQL cluster - camera registry, segments)    │            │
│  └─────────────────────────────────────────────────────┘            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Multi-Node Recording Strategy

### Option 1: 7× Recorder Nodes (Recommended)

**Node specs (each):**
- **CPU**: AMD Ryzen 9 7950X (16-core) or Intel i9-13900K
- **GPU**: NVIDIA RTX 4080 or RTX 4090 (for NVENC)
- **RAM**: 64 GB DDR5
- **Network**: Dual 10GbE (one for cameras, one for storage)
- **Cost per node**: ~$3000
- **Total hardware**: ~$21,000 for 7 nodes

**Capacity per node:**
- 32 cameras @ 8K H.265 NVENC
- 1.92 Gbps inbound bandwidth
- 7.68 GB/s disk write (to 10GbE NAS)
- ~20% CPU, 80% GPU utilization

**220 cameras:** 7 nodes × 32 cameras = 224 capacity

### Option 2: 11× Compact Nodes (Budget)

**Node specs (each):**
- **CPU**: Intel i5-13400 (10-core)
- **GPU**: NVIDIA RTX 4060 Ti
- **RAM**: 32 GB DDR5
- **Network**: Single 10GbE
- **Cost per node**: ~$1500
- **Total hardware**: ~$16,500 for 11 nodes

**Capacity per node:**
- 20 cameras @ 8K H.265 NVENC
- 1.2 Gbps inbound bandwidth
- 4.8 GB/s disk write
- ~30% CPU, 90% GPU utilization

**220 cameras:** 11 nodes × 20 cameras = 220 exact

## Shared Storage Architecture

### NAS/SAN Requirements

**Total storage:** 429 TB (30-day retention) + 20% overhead = **515 TB**

### Option 1: TrueNAS Enterprise (Recommended)

**3× TrueNAS nodes** (RAID-Z2, high availability):
- **Disks**: 48× 18TB enterprise drives per node (Seagate Exos, WD Ultrastar)
- **Usable capacity**: ~180 TB per node (RAID-Z2) = 540 TB total
- **Network**: 4× 25GbE per node (bonded = 100 Gbps)
- **Write performance**: 20 GB/s sustained per node
- **Cost per node**: ~$30,000 (disks + chassis + controllers)
- **Total storage cost**: ~$90,000

### Option 2: Ceph Cluster (Open Source, Scalable)

**10× storage nodes** (3× replication for redundancy):
- **Disks**: 12× 18TB SATA drives per node
- **Raw capacity**: 2160 TB total / 3 replicas = 720 TB usable
- **Network**: Dual 25GbE per node
- **Write performance**: 50+ GB/s aggregate
- **Cost per node**: ~$12,000
- **Total storage cost**: ~$120,000

**Ceph advantages:**
- Scales to petabytes
- Self-healing
- No single point of failure
- Add nodes on demand

### Option 3: Cloud Object Storage (Hybrid)

**Local NVMe cache + S3 backend:**
- **Local cache**: 50 TB NVMe per recorder node (recent 24 hours)
- **Cloud**: AWS S3 Glacier Deep Archive (older than 24h)
- **Upload bandwidth**: 10 Gbps
- **Cost**: $1/TB/month storage + $0.02/GB retrieval
- **30-day cost**: 429 TB × $1 = **$429/month** (~$5,148/year)

**Pros:** No upfront storage cost, unlimited scale  
**Cons:** Retrieval cost, requires internet, privacy concerns

## Network Design

### High-Speed Backbone

```
┌─────────────────────────────────────────────────────────────────┐
│                     Network Topology                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────┐  ┌────────┐  ┌────────┐                            │
│  │ Node 1 │  │ Node 2 │  │ Node 7 │                            │
│  │ 10GbE  │  │ 10GbE  │  │ 10GbE  │                            │
│  └───┬────┘  └───┬────┘  └───┬────┘                            │
│      │           │           │                                  │
│      └───────────┴───────────┘                                  │
│                  │                                              │
│         ┌────────▼──────────┐                                   │
│         │  Core Switch      │                                   │
│         │  (100G backbone)  │                                   │
│         │  10/25GbE ports   │                                   │
│         └────────┬──────────┘                                   │
│                  │                                              │
│      ┌───────────┼───────────┐                                  │
│      │           │           │                                  │
│  ┌───▼────┐  ┌───▼────┐  ┌───▼────┐                            │
│  │  NAS 1 │  │  NAS 2 │  │  NAS 3 │                            │
│  │  25GbE │  │  25GbE │  │  25GbE │                            │
│  └────────┘  └────────┘  └────────┘                            │
│                                                                  │
│  Camera Network (separate VLAN):                                │
│  ┌──────────────────────────────────────┐                       │
│  │  32 cameras → PoE Switch → Node 1    │                       │
│  │  32 cameras → PoE Switch → Node 2    │                       │
│  │  ...                                  │                       │
│  └──────────────────────────────────────┘                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Core switch requirements:**
- 100 Gbps backplane
- 16× 10GbE ports (for recorder nodes)
- 8× 25GbE ports (for NAS/SAN)
- VLAN support (camera network isolation)
- Jumbo frames (9000 MTU)

**Recommended:** Mikrotik CRS504-4XQ-IN (~$1500) or Ubiquiti UniFi Dream Machine Pro Max (~$500)

## Load Balancing & Camera Assignment

### Static Assignment (Simple)

**Assign cameras to nodes manually:**
```json
{
  "node-1": ["cam001", "cam002", ..., "cam032"],
  "node-2": ["cam033", "cam034", ..., "cam064"],
  "node-7": ["cam193", "cam194", ..., "cam220"]
}
```

**Pros:** Simple, predictable  
**Cons:** Manual rebalancing if node fails

### Dynamic Assignment (Recommended)

**Use etcd or Consul for distributed config:**

```
1. Camera connects to network
2. All nodes see camera (ONVIF discovery)
3. etcd/Consul assigns camera to least-loaded node
4. Node starts recording
5. If node fails, camera reassigned to another node
```

**Failover time:** < 30 seconds

### Camera Discovery (ONVIF)

```bash
# Auto-discover all cameras on network
guardian-recorder discover --network 192.168.10.0/24

# Outputs:
# Found 220 cameras:
#   cam001: 192.168.10.101 (Hikvision DS-2CD8A26G0, 8K)
#   cam002: 192.168.10.102 (Dahua DH-IPC-HF8835, 8K)
#   ...
```

## Guardian Cluster Mode Implementation

### Cluster Coordinator Service

```zig
// New service: guardian-cluster-coordinator

pub const ClusterCoordinator = struct {
    nodes: []RecorderNode,
    cameras: []Camera,
    storage: StorageBackend,
    
    pub const RecorderNode = struct {
        id: []const u8,
        hostname: []const u8,
        capacity: u32, // max cameras
        assigned: u32, // currently assigned
        health: NodeHealth,
    };
    
    pub const NodeHealth = enum {
        healthy,
        degraded,
        offline,
    };
    
    /// Assign camera to least-loaded healthy node
    pub fn assignCamera(self: *ClusterCoordinator, camera: Camera) ![]const u8 {
        var best_node: ?*RecorderNode = null;
        var min_load: u32 = std.math.maxInt(u32);
        
        for (self.nodes) |*node| {
            if (node.health != .healthy) continue;
            
            const load = node.assigned;
            if (load < min_load and node.assigned < node.capacity) {
                min_load = load;
                best_node = node;
            }
        }
        
        if (best_node) |node| {
            node.assigned += 1;
            return node.id;
        }
        
        return error.NoAvailableNodes;
    }
    
    /// Rebalance cameras if node fails
    pub fn handleNodeFailure(self: *ClusterCoordinator, failed_node_id: []const u8) !void {
        // Find cameras assigned to failed node
        var reassign_list = std.ArrayList(Camera).init(self.allocator);
        defer reassign_list.deinit();
        
        for (self.cameras) |camera| {
            if (std.mem.eql(u8, camera.assigned_node, failed_node_id)) {
                try reassign_list.append(camera);
            }
        }
        
        // Reassign to healthy nodes
        for (reassign_list.items) |camera| {
            const new_node = try self.assignCamera(camera);
            log.warn("cluster", "Reassigned {s} from {s} to {s}", .{
                camera.id, failed_node_id, new_node,
            });
        }
    }
};
```

### Distributed Metadata Database

**Store segment metadata in PostgreSQL cluster:**

```sql
CREATE TABLE recording_segments (
    id SERIAL PRIMARY KEY,
    camera_id VARCHAR(64) NOT NULL,
    recorder_node VARCHAR(64) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    duration_ms INTEGER NOT NULL,
    file_path TEXT NOT NULL,
    storage_node VARCHAR(64) NOT NULL,
    file_size_bytes BIGINT NOT NULL,
    codec VARCHAR(16) NOT NULL,
    resolution VARCHAR(16) NOT NULL,
    INDEX idx_camera_time (camera_id, start_time),
    INDEX idx_storage_node (storage_node)
);

-- Query: Get all segments for camera between times
SELECT file_path, storage_node
FROM recording_segments
WHERE camera_id = 'cam042'
  AND start_time >= '2026-09-01 00:00:00'
  AND start_time < '2026-09-02 00:00:00'
ORDER BY start_time;
```

## Performance Optimizations

### 1. Network Tuning (Linux)

```bash
# Increase network buffer sizes
sysctl -w net.core.rmem_max=134217728
sysctl -w net.core.wmem_max=134217728
sysctl -w net.ipv4.tcp_rmem='4096 87380 67108864'
sysctl -w net.ipv4.tcp_wmem='4096 65536 67108864'

# Enable jumbo frames
ip link set eth0 mtu 9000

# Increase connection tracking
sysctl -w net.netfilter.nf_conntrack_max=1048576

# TCP tuning for high throughput
sysctl -w net.ipv4.tcp_congestion_control=bbr
sysctl -w net.core.default_qdisc=fq
```

### 2. Disk I/O Tuning

```bash
# Use deadline I/O scheduler for streaming writes
echo deadline > /sys/block/sda/queue/scheduler

# Increase read-ahead
blockdev --setra 8192 /dev/sda

# Disable atime updates (faster writes)
mount -o remount,noatime,nodiratime /srv/guardian
```

### 3. FFmpeg Optimizations

```bash
# Use multiple threads
-threads 0

# Disable unnecessary processing
-nostats -loglevel error

# Direct I/O to NAS (bypass page cache)
-fflags +direct

# Increase I/O buffer
-bufsize 15M

# Optimize for streaming
-movflags +faststart+frag_keyframe+empty_moov
```

### 4. GPU Encoding Parallelization

**RTX 4090 can encode 8× 8K streams concurrently:**

```
Node with RTX 4090:
- 8 cameras → GPU encoder #1 (session 0-7)
- 8 cameras → GPU encoder #2 (session 8-15)
- 8 cameras → GPU encoder #3 (session 16-23)
- 8 cameras → GPU encoder #4 (session 24-31)

= 32 cameras per node
```

**Use NVENC session separation:**
```bash
-hwaccel_device 0:0  # GPU 0, encoder session 0
-hwaccel_device 0:1  # GPU 0, encoder session 1
```

## Cost Breakdown

### Total System Cost (220× 8K cameras, 30-day retention)

| Component | Option | Quantity | Cost Each | Total |
|-----------|--------|----------|-----------|-------|
| **Recorder Nodes** | Ryzen 9 + RTX 4080 | 7 | $3,000 | $21,000 |
| **Storage** | TrueNAS (180TB each) | 3 | $30,000 | $90,000 |
| **Network Switch** | 100G core + 10GbE | 1 | $1,500 | $1,500 |
| **PoE Switches** | 48-port PoE+ | 5 | $1,200 | $6,000 |
| **Cameras** | 8K ONVIF (provided) | 220 | $0 | $0 |
| **Cables/Rack** | CAT6a, fiber, 42U rack | 1 | $3,000 | $3,000 |
| **UPS** | 10kVA rack UPS | 2 | $5,000 | $10,000 |
| **Installation** | Labor, setup, config | - | - | $10,000 |
| **Total** | | | | **$141,500** |

**Operating cost:**
- Power: 7 nodes × 500W + storage 2kW = 5.5 kW × $0.12/kWh × 24h × 365d = **$5,788/year**
- Maintenance: Drive replacements, support = **$5,000/year**
- **Total OpEx:** ~$11,000/year

### Cost Comparison (220 cameras)

| Solution | CapEx | OpEx/year | Notes |
|----------|-------|-----------|-------|
| **Guardian Cluster** | $142k | $11k | Open source, owned |
| **Hikvision 220-ch** | $200k+ | $20k | Proprietary, subscription |
| **Milestone XProtect** | $180k | $40k | Licensing hell |
| **Verkada** | N/A | $220k | 100% cloud ($$$$) |

**Guardian saves $58k upfront + $9k-$209k/year**

## Scalability

### Adding More Cameras

**250 cameras** (30 more):
- Add 1 more recorder node ($3k)
- Expand storage by 15% (add 8× 18TB drives = $4k)
- **Total cost to scale:** $7k

**500 cameras** (2.5× scale):
- Add 10 more recorder nodes ($30k)
- Add 3 more storage nodes ($90k)
- Upgrade core switch to 200G ($3k)
- **Total cost to scale:** $123k

### Geographic Distribution

**Multi-site deployment** (e.g., 3 buildings with 70 cameras each):

```
Building A (70 cams)          Building B (70 cams)          Building C (70 cams)
┌──────────────────┐          ┌──────────────────┐          ┌──────────────────┐
│ 3 recorder nodes │          │ 3 recorder nodes │          │ 3 recorder nodes │
│ 1 local NAS      │◄────────►│ 1 local NAS      │◄────────►│ 1 local NAS      │
│ (30 TB cache)    │ 10GbE    │ (30 TB cache)    │ 10GbE    │ (30 TB cache)    │
└──────────────────┘  fiber   └──────────────────┘  fiber   └──────────────────┘
         │                              │                              │
         └──────────────────────────────┴──────────────────────────────┘
                                        │
                                        ▼
                              ┌──────────────────┐
                              │  Central NAS     │
                              │  (500 TB)        │
                              │  (long-term)     │
                              └──────────────────┘
```

**Local recording** (30-day cache) + **central backup** (90-day archive)

## Monitoring & Management

### Cluster Dashboard

```
┌─────────────────────────────────────────────────────────────┐
│          Guardian Cluster Status (220 cameras)              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Nodes: 7/7 online    Cameras: 220/220 recording           │
│  Storage: 142 TB / 540 TB (26% used)                       │
│  Network: 13.2 Gbps inbound, 13.2 Gbps outbound           │
│                                                             │
│  Node Status:                                               │
│  ┌─────────────────────────────────────────────────┐       │
│  │ node-1: ████████████████ 32/32 cams (healthy)  │       │
│  │ node-2: ████████████████ 32/32 cams (healthy)  │       │
│  │ node-3: ████████████████ 32/32 cams (healthy)  │       │
│  │ node-4: ████████████████ 32/32 cams (healthy)  │       │
│  │ node-5: ████████████████ 32/32 cams (healthy)  │       │
│  │ node-6: ████████████████ 32/32 cams (healthy)  │       │
│  │ node-7: ██████████████░░ 28/32 cams (healthy)  │       │
│  └─────────────────────────────────────────────────┘       │
│                                                             │
│  Storage Nodes:                                             │
│  ┌─────────────────────────────────────────────────┐       │
│  │ nas-1: ████░░░░░░░░░░░░ 48 TB / 180 TB (27%)   │       │
│  │ nas-2: ████░░░░░░░░░░░░ 47 TB / 180 TB (26%)   │       │
│  │ nas-3: ████░░░░░░░░░░░░ 47 TB / 180 TB (26%)   │       │
│  └─────────────────────────────────────────────────┘       │
│                                                             │
│  Recent Events:                                             │
│  ✓ 2026-09-13 14:42:11 - cam087 segment recorded (5 min)  │
│  ✓ 2026-09-13 14:42:09 - cam156 segment recorded (5 min)  │
│  ⚠ 2026-09-13 14:38:22 - cam042 reconnect (3rd attempt)   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Metrics (Prometheus + Grafana)

**Export metrics from each node:**
```
guardian_cameras_assigned{node="node-1"} 32
guardian_cameras_recording{node="node-1"} 32
guardian_disk_write_mbps{node="node-1"} 7680
guardian_gpu_utilization{node="node-1",gpu="0"} 0.82
guardian_network_rx_gbps{node="node-1"} 1.92
guardian_storage_used_tb{storage="nas-1"} 48
guardian_segment_count{camera="cam001"} 8640
```

## Summary

**To handle 220× 8K cameras:**

1. **Multi-node cluster**: 7 recorder nodes (32 cams each)
2. **Shared storage**: 3× TrueNAS (540 TB total)
3. **High-speed network**: 10/25GbE backbone
4. **GPU acceleration**: NVENC on each node
5. **Distributed control**: etcd/Consul for coordination
6. **Cost**: $142k CapEx + $11k/year OpEx

**vs. single node (impossible):**
- Single 10GbE NIC maxes at ~80 cameras
- Single GPU maxes at 32 cameras
- Single disk array can't write 52 GB/s

**Guardian scales horizontally** - add nodes as needed. 500 cameras? Add more nodes. 1000 cameras? Add more nodes.

**Want me to implement the cluster coordinator service?**
