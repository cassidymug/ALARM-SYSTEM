# Guardian GH-1000 - CPU Selection for 4K/8K Video

## Problem: Celeron N5105 Limitations

### Current Spec: Intel Celeron N5105
- **Cores:** 4 (Quad-core)
- **Clock:** 2.0 GHz base, 2.9 GHz boost
- **TDP:** 10W (low power)
- **GPU:** Intel UHD Graphics (24 EUs, 800 MHz)
- **Quick Sync Video:** Gen 11 (Jasper Lake)

### Hardware Video Decode Support

| Codec | Resolution | Hardware Accelerated? | Performance |
|-------|------------|----------------------|-------------|
| **H.264 (AVC)** | Up to 4K @ 60fps | ✅ Yes | Excellent |
| **H.265 (HEVC)** | Up to 4K @ 60fps | ✅ Yes | Excellent |
| **VP9** | Up to 4K @ 60fps | ✅ Yes | Good |
| **AV1** | Up to 4K @ 60fps | ❌ No | Poor (software decode) |
| **H.265 (HEVC)** | **8K @ 30fps** | ❌ **No** | **Poor (software decode)** |
| **H.265 (HEVC)** | **8K @ 60fps** | ❌ **No** | **Impossible** |

**Key Issue:** N5105's Quick Sync can only hardware-decode up to **4K resolution**. For 8K, it falls back to software decoding, which is **too slow**.

---

## 8K Video Playback Requirements

### Video Stream Characteristics

**8K Resolution:**
- 7680 × 4320 pixels = **33.2 megapixels per frame**
- At 30fps: **996 million pixels/second**
- At 60fps: **1.99 billion pixels/second**

**Bandwidth:**
- H.265 (good quality): **50-100 Mbps** per camera
- H.265 (high quality): **100-150 Mbps** per camera
- Raw/uncompressed: **12,000+ Mbps** (not practical)

**Decode Performance Needed:**
- Single 8K @ 30fps: ~**50-60 GFLOPS** (GPU compute)
- 4× 8K @ 30fps: ~**200-240 GFLOPS**
- 12× 8K @ 30fps: ~**600-720 GFLOPS**
- 24× 8K @ 30fps: ~**1,200-1,440 GFLOPS** (multiple GPUs needed)

### N5105 GPU Performance

**Intel UHD Graphics (Gen 11, 24 EUs):**
- Compute: ~**192 GFLOPS** (FP32, theoretical max)
- Realistic sustained: ~**100-120 GFLOPS**

**Result:** N5105 can barely handle **1× 8K stream** in software decode. For 4+ 8K cameras, it's **completely inadequate**.

---

## Recommended CPU Upgrades

### Option 1: Intel Core i3-N305 (Minimum for 8K)

**Specifications:**
- **Cores:** 8 (Octa-core, Alder Lake-N)
- **Clock:** 1.8 GHz base, 3.8 GHz boost
- **TDP:** 15W (still low power)
- **GPU:** Intel UHD Graphics (32 EUs, 1.25 GHz)
- **Quick Sync:** Gen 12.2 (Alder Lake)
- **Price:** ~$200 (vs $150 for N5105)

**Hardware Video Decode Support:**
| Codec | Resolution | Hardware Accelerated? |
|-------|------------|----------------------|
| **H.264 (AVC)** | Up to 8K @ 30fps | ✅ Yes |
| **H.265 (HEVC)** | Up to 8K @ 30fps | ✅ Yes |
| **VP9** | Up to 8K @ 30fps | ✅ Yes |
| **AV1** | Up to 8K @ 30fps | ✅ Yes |

**Performance:**
- **1-4× 8K @ 30fps:** Excellent (hardware decode)
- **5-8× 8K @ 30fps:** Good (hardware decode, may hit memory bandwidth limits)
- **9-12× 8K @ 30fps:** Marginal (consider external GPU)

**Recommendation:** ✅ **Best upgrade for 4-8 cameras at 8K**

**Available Boards:**
- **ASRock N100M-HDV** (Mini-ITX, 4× SATA, M.2, $140) - Similar to N5105 boards
- **ASUS PN53** (Mini-PC board, M.2, Wi-Fi, $250)

---

### Option 2: Intel Core i5-12400 (Mid-Range, Discrete System)

**Specifications:**
- **Cores:** 6P+0E (6 performance cores, 12 threads)
- **Clock:** 2.5 GHz base, 4.4 GHz boost
- **TDP:** 65W (requires active cooling)
- **GPU:** Intel UHD Graphics 730 (24 EUs, 1.45 GHz)
- **Quick Sync:** Gen 12 (Alder Lake)
- **Price:** ~$180 (bare CPU)

**Hardware Video Decode Support:**
- Same as i3-N305 (8K H.265, AV1)
- Better sustained performance (higher clock speeds)

**Performance:**
- **1-8× 8K @ 30fps:** Excellent (hardware decode)
- **9-16× 8K @ 30fps:** Good (hardware decode + CPU assists)
- **17-24× 8K @ 30fps:** Add discrete GPU

**Recommendation:** ✅ **Good for 8-16 cameras at 8K, standard motherboard**

**Motherboard Options:**
- **ASRock B660M-ITX/ac** (Mini-ITX, $140) - Compact, same as N5105 form factor
- **ASUS ROG Strix B660-I** (Mini-ITX, $200) - Premium, better VRM

**Total Cost:**
- CPU + Motherboard: ~$320-$380 (vs $150 for N5105 board)
- Higher power consumption: 65W vs 10W

---

### Option 3: AMD Ryzen 7 7840HS (High-End, Integrated Graphics)

**Specifications:**
- **Cores:** 8C/16T (Zen 4, Phoenix)
- **Clock:** 3.8 GHz base, 5.1 GHz boost
- **TDP:** 35-54W (configurable)
- **GPU:** AMD Radeon 780M (12 RDNA3 CUs, 2.7 GHz)
- **Video Decode:** VCN 4.0 (8K AV1, H.265, VP9)
- **Price:** ~$450-$500 (embedded modules)

**Hardware Video Decode Support:**
- **H.265 (HEVC):** Up to 8K @ 60fps ✅
- **AV1:** Up to 8K @ 60fps ✅
- **Multiple streams:** Up to 4× 8K @ 30fps simultaneously

**GPU Performance:**
- Radeon 780M: ~**8.6 TFLOPS** (FP32) - **6× faster** than N5105
- Can decode **8-12× 8K @ 30fps** streams with ease

**Recommendation:** ✅ **Best for 12-24 cameras at 8K, no discrete GPU needed**

**Available Modules:**
- **Minisforum UM790 Pro** (Mini-PC, $650) - Complete system, just add RAM/SSD
- **Framework Laptop Mainboard** (AMD 7840HS, $450) - Motherboard only, DIY-friendly

**Pros:**
- Excellent 8K decode performance
- Still relatively low power (35-54W)
- No discrete GPU needed

**Cons:**
- More expensive ($450 vs $150 for N5105)
- Harder to source as bare motherboards (mostly mini-PCs)

---

### Option 4: Discrete GPU Solution (For 24× 8K Cameras)

**If you need 24× 8K cameras @ 30fps simultaneously:**

**CPU:** Intel i5-12400 or AMD Ryzen 5 5600 (mid-range, $150-200)  
**GPU:** NVIDIA RTX 4060 or AMD RX 7600 ($300-400)

**Why Discrete GPU?**
- **NVDEC (NVIDIA Video Decoder):** Dedicated hardware for video decode
- **RTX 4060 Specs:**
  - 5× NVDEC engines (8K H.265/AV1 decode)
  - Can decode **up to 30× 4K streams** or **10-15× 8K streams** simultaneously
  - 8 GB VRAM (buffer for decoded frames)

**Performance:**
- **24× 8K @ 30fps:** Excellent (5-10% GPU utilization)
- **48× 8K @ 30fps:** Still good (20-30% GPU utilization)
- **100+ 4K @ 30fps:** Possible (for comparison)

**Total Cost:**
- CPU + Motherboard: $320-$380
- GPU: $300-$400
- **Total:** ~$700-$800 (vs $150 for N5105 board)

**Recommendation:** ✅ **For enterprise/commercial with 20+ 8K cameras**

---

## Recording vs. Playback: Different Requirements

### Recording (Encode) - Less Demanding

**Guardian's primary job is recording:**
- Cameras send **pre-encoded H.265 streams** (via RTSP)
- Hub just **saves streams to disk** (no re-encode needed)
- CPU usage: **Low** (I/O bound, not compute bound)
- N5105 can easily handle **24× 8K cameras recording** (just writing to disk)

**Encoding only needed for:**
- Re-encoding for different bitrates (optional, for remote viewing)
- Motion detection zones (decode small regions only)
- AI inference (object detection)

**N5105 Encode Performance (4K only):**
- 4× 4K @ 30fps: Good
- 8× 4K @ 30fps: Marginal
- 8K encode: Not supported (no hardware encoder)

---

### Playback (Decode) - Very Demanding

**Playback is when you view recorded video:**
- User opens Guardian UI, wants to see **4× 8K camera feeds** simultaneously
- Hub must **decode 4× 8K streams** in real-time
- CPU/GPU usage: **High** (compute bound)
- N5105 **cannot** handle this (software decode too slow)

**Solution:** Use a more powerful CPU/GPU for the hub **OR** offload playback to client devices.

---

## Recommended CPU for Different Scales

### Small Home (4-8 Cameras, 4K)
**CPU:** Intel Celeron N5105 ✅
- **Recording:** 24× 4K @ 30fps ✅ (just saving streams)
- **Playback:** 4× 4K @ 30fps ✅ (hardware decode)
- **Cost:** $150 (Mini-ITX board)
- **Power:** 10W

**Verdict:** **N5105 is fine for 4K systems**

---

### Small Home (4-8 Cameras, 8K)
**CPU:** Intel Core i3-N305 ✅ (upgrade to Alder Lake-N)
- **Recording:** 24× 8K @ 30fps ✅ (just saving streams)
- **Playback:** 4-8× 8K @ 30fps ✅ (hardware decode)
- **Cost:** $200-$250
- **Power:** 15W

**Verdict:** **i3-N305 is minimum for 8K, good for 4-8 cameras**

---

### Medium Business (12-24 Cameras, 8K)
**Option A:** AMD Ryzen 7 7840HS (integrated graphics)
- **Recording:** 24× 8K @ 30fps ✅
- **Playback:** 12× 8K @ 30fps ✅
- **Cost:** $450-$650
- **Power:** 35-54W

**Option B:** Intel i5-12400 + NVIDIA RTX 4060 (discrete GPU)
- **Recording:** 24× 8K @ 30fps ✅
- **Playback:** 24× 8K @ 30fps ✅ (GPU decode)
- **Cost:** $700-$800
- **Power:** 65W + 120W = 185W

**Verdict:** **AMD 7840HS for 12-24 cameras, or discrete GPU for 24+ cameras**

---

### Enterprise (50+ Cameras, 8K)
**Multi-Node Architecture:**
- Each hub: Intel i5-12400 + RTX 4060 (or AMD equivalent)
- Each hub handles 24 cameras (recording + playback)
- 3× hubs for 72 cameras
- Shared NAS/SAN storage (10GbE interconnect)

**Cost per hub:** ~$1,500 (CPU, GPU, PoE switch, chassis)  
**Total for 3 hubs:** ~$4,500

**Verdict:** **Scale out, not up - multiple hubs with discrete GPUs**

---

## Updated BOM with CPU Options

### Configuration A: 4K System (Recommended for Most)
| Component | Part | Price |
|-----------|------|-------|
| CPU Board | ASRock N5105-ITX | $150 |
| RAM | 16GB DDR4 SO-DIMM | $60 |
| NVMe | 256GB WD Blue SN570 | $35 |
| **Cameras** | **24× 4K PoE** | **$4,800** |
| **Playback** | **4× 4K @ 30fps** | **✅ Smooth** |
| **Total** | | **$1,299** |

---

### Configuration B: 8K System (4-8 Cameras)
| Component | Part | Price |
|-----------|------|-------|
| CPU Board | Intel i3-N305 board | $200 |
| RAM | 16GB DDR4 SO-DIMM | $60 |
| NVMe | 512GB Samsung 980 Pro | $80 |
| **Cameras** | **8× 8K PoE** | **$3,200** |
| **Playback** | **4-8× 8K @ 30fps** | **✅ Smooth** |
| **Total** | | **$1,399** |

---

### Configuration C: 8K System (12-24 Cameras)
| Component | Part | Price |
|-----------|------|-------|
| CPU | Intel i5-12400 | $180 |
| Motherboard | ASRock B660M-ITX | $140 |
| GPU | NVIDIA RTX 4060 | $350 |
| RAM | 16GB DDR4 | $60 |
| NVMe | 1TB Samsung 980 Pro | $120 |
| **Cameras** | **24× 8K PoE** | **$9,600** |
| **Playback** | **24× 8K @ 30fps** | **✅ Smooth** |
| **Total** | | **$1,899** |

---

## Client-Side Playback (Alternative Solution)

**Problem:** Hub CPU/GPU is bottleneck for playback

**Solution:** Offload decode to client devices
- User's PC/phone does the decode (not the hub)
- Hub just **streams encoded video** to client (low CPU usage)
- Client device decodes locally (their GPU handles it)

**How it works:**
1. Hub serves H.265 stream over HTTPS
2. Guardian mobile app / web UI receives stream
3. Client device decodes with **its own GPU** (phone, laptop, desktop)
4. Hub CPU usage: **<5%** (just serving files)

**Pros:**
- Hub can be low-power (N5105 is fine)
- Scales to unlimited clients (each uses their own GPU)
- Lower hub cost

**Cons:**
- Requires decent client device (old phone may struggle with 8K)
- Network bandwidth: 100 Mbps per 8K stream (requires good Wi-Fi/LAN)

**Recommendation:** ✅ **Use this approach + mid-range hub CPU (i3-N305)**
- Hub doesn't need powerful GPU (client does the work)
- Hub serves 8K streams to client (low CPU)
- Client decodes on their phone/PC (their problem, not yours)

---

## Final Recommendation

### For 8K System (4-8 Cameras):
**Upgrade to Intel Core i3-N305 ($200) or equivalent:**
- Hardware 8K decode support ✅
- Can handle 4-8× 8K streams simultaneously ✅
- Still low power (15W) ✅
- Only $50 more than N5105 ✅

**Update BOM:**
- Replace "Intel Celeron N5105" with "Intel Core i3-N305"
- Replace "ASRock N5105-ITX" with "ASRock N100M-HDV" (similar board, N305 CPU)
- Increase hub price from $1,299 to $1,349 (+$50)

---

### For 8K System (12-24 Cameras):
**Use mid-range CPU + discrete GPU:**
- **CPU:** Intel i5-12400 ($180) or AMD Ryzen 5 5600 ($150)
- **GPU:** NVIDIA RTX 4060 ($350) or AMD RX 7600 ($300)
- **Total:** +$600 over budget, but necessary for 24× 8K playback

**Alternative:** Client-side decode
- Keep i3-N305 hub ($200)
- Offload playback to client devices (their GPU)
- Hub serves streams only (low CPU)
- **Saves $350-400** (no discrete GPU needed)

---

## Conclusion

**Answer to your question:**
- ❌ **Celeron N5105 is NOT adequate for 8K playback**
- ✅ **Celeron N5105 IS adequate for 8K recording** (just saving streams to disk)

**For 8K systems:**
- **Minimum:** Upgrade to Intel Core i3-N305 (+$50)
- **Recommended:** i3-N305 + client-side decode (no GPU needed)
- **Premium:** i5-12400 + RTX 4060 (24× 8K playback on hub itself)

**Action items:**
1. Update BOM to specify i3-N305 for "8K variant"
2. Keep N5105 for "4K variant" (it's fine for 4K)
3. Offer discrete GPU upgrade for 24× 8K cameras

Would you like me to update the specs accordingly?
