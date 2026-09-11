# Guardian Relay Deployment on Hetzner

## Components

- **guardian-relay VM**: Authentication, hub sessions, client sessions, signaling, push fan-out
- **Object Storage**: Offsite ciphertext for backups

## VM Setup

### Prerequisites

- Hetzner Cloud account
- SSH key configured
- Domain with DNS access

### 1. Create VM

```bash
# Create CX31 VM (2 vCPU, 8GB RAM) - adjust as needed
hcloud server create \
  --name guardian-relay-prod \
  --type cx31 \
  --image debian-12 \
  --ssh-key my-key \
  --location fsn1
```

### 2. Firewall Rules

```bash
# Create firewall
hcloud firewall create --name guardian-relay

# Allow HTTPS (clients + hub WebSocket/mTLS)
hcloud firewall add-rule guardian-relay \
  --direction in \
  --protocol tcp \
  --port 443 \
  --source-ips 0.0.0.0/0 \
  --source-ips ::/0

# Allow SSH from known IPs only
hcloud firewall add-rule guardian-relay \
  --direction in \
  --protocol tcp \
  --port 22 \
  --source-ips YOUR_IP/32

# Apply firewall
hcloud firewall apply-to-resource guardian-relay \
  --type server \
  --server guardian-relay-prod
```

### 3. Deploy Relay Binary

```bash
# Build relay
cd deploy/hetzner/relay
go build -o guardian-relay

# Deploy to VM
scp guardian-relay root@RELAY_IP:/usr/local/bin/
scp guardian-relay.service root@RELAY_IP:/etc/systemd/system/

# Enable and start
ssh root@RELAY_IP "systemctl daemon-reload && systemctl enable --now guardian-relay"
```

### 4. TLS Certificates

```bash
# Install certbot for Let's Encrypt
ssh root@RELAY_IP "apt-get update && apt-get install -y certbot"

# Generate certificate
ssh root@RELAY_IP "certbot certonly --standalone -d relay.yourdomain.com"
```

### 5. Hub mTLS CA

```bash
# Generate CA for hub client certificates
openssl genrsa -out hub-ca.key 4096
openssl req -new -x509 -days 3650 -key hub-ca.key -out hub-ca.crt \
  -subj "/CN=Guardian Hub CA"

# Deploy CA to relay
scp hub-ca.crt root@RELAY_IP:/etc/guardian-relay/
```

## Object Storage Setup

### Create Bucket

```bash
# Via Hetzner Cloud Console or API
# Create bucket: guardian-backups-prod
# Enable versioning
# Set lifecycle policies for retention
```

### Access Keys

```bash
# Create scoped access key with write-only to bucket
# Distribute key to hubs via setup wizard
```

## Monitoring

- Relay uptime
- Hub connection count
- Error rates
- Push notification delivery

## Scaling

- Vertical: Upgrade to larger VM types (CX41, CX51)
- Horizontal: Load balance multiple relay VMs with shared session store (Redis)

## Security Notes

- TLS certificates from Let's Encrypt
- Hub mTLS CA operated by us (not Hetzner)
- Client tokens short-lived with revocation support
- SSH via keys only, no password auth
- Optional: VPN for admin access

## Costs (Estimate)

- CX31 VM: ~€10/month
- Object Storage: ~€5-30+/month (usage-based)
- Traffic: First 20TB free
