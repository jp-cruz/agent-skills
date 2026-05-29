# Network Setup & Security Guide

## Quick Decision Guide

| Scenario | Setup | Tool | Access | Protection |
|----------|-------|------|--------|------------|
| **Localhost only** | `THOTH_BIND=127.0.0.1` | None | This computer only | ✅ Maximum |
| **Local Area Network** | `THOTH_BIND=0.0.0.0` | Firewall | WiFi, Ethernet, same LAN | ✅ Firewall-protected |
| **Remote private** | `THOTH_BIND=127.0.0.1` | Tailscale VPN | Anywhere on private network | ✅ Encrypted VPN |
| **Internet public** | `THOTH_BIND=127.0.0.1` | Cloudflare Tunnel | Anywhere on internet | ✅ DDoS + Auth |

**Recommendation:** Start with localhost (127.0.0.1), add LAN access only if needed.

---

## Default: Localhost Only (Secure)

By default, Thoth listens on `127.0.0.1:8080` — accessible **only from this computer**.

```bash
# This is the default
THOTH_BIND=127.0.0.1
```

**Access:** `http://localhost:8080` (local machine only)

---

## Network Access: Exposing Thoth Over Network

If you want to access Thoth from other machines on your network or the internet, you need to:

1. Change the bind address
2. Add security hardening
3. Consider authentication

### Option 1: Local Area Network (LAN) Access

**Scenario:** Access Thoth from other devices on your Local Area Network
- WiFi devices (phone, tablet, laptop)
- Wired (Ethernet) devices
- Any device on the same local network

**Setup:**

```bash
# In .env:
THOTH_BIND=0.0.0.0
THOTH_PORT=8080
```

**Access:** `http://<your-machine-ip>:8080`

**How it works:**
- `0.0.0.0` tells Thoth to listen on all local network interfaces
- Your router/firewall blocks external internet access
- Only devices on your LAN can reach it

**Security considerations:**
- ⚠️ No authentication by default (anyone on LAN can access)
- ✅ Protected by firewall (not accessible from internet)
- ✅ Run behind reverse proxy (Nginx, Caddy) for authentication
- ✅ Consider adding firewall rules to restrict to trusted devices

### Option 2: Internet Access (Production)

**Scenario:** Access Thoth from anywhere on the internet

**⚠️ NEVER expose Thoth directly to the internet without:**

1. **Authentication** — Thoth has no built-in auth; use reverse proxy
2. **HTTPS** — Use TLS/SSL encryption
3. **Rate limiting** — Prevent abuse
4. **DDoS protection** — Consider Cloudflare, AWS Shield, etc.

### Option 3: Reverse Proxy (Recommended)

Use **Nginx**, **Caddy**, or **Cloudflare Tunnel** to:
- Add authentication (basic auth, OAuth)
- Enforce HTTPS
- Rate limit requests
- Hide your home IP
- Add DDoS protection

#### Example: Nginx Reverse Proxy (Local Network)

```nginx
# /etc/nginx/sites-available/thoth
server {
    listen 80;
    server_name thoth.local;  # or your machine hostname

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Rate limiting: 100 requests per minute
        limit_req zone=api burst=10;
    }
}

# Rate limiting zone
limit_req_zone $binary_remote_addr zone=api:10m rate=100r/m;
```

**Start with:**
```bash
# Set Thoth to localhost (behind proxy)
THOTH_BIND=127.0.0.1
THOTH_PORT=8080

# Install and run nginx
brew install nginx  # macOS
nginx
```

#### Example: Cloudflare Tunnel (Internet Access, No Port Forward) — RECOMMENDED

**Why Cloudflare Tunnel?**
- ✅ No port forwarding (your home IP stays hidden)
- ✅ Built-in DDoS protection
- ✅ Free tier available
- ✅ HTTPS automatic
- ✅ Can add Cloudflare Access for authentication
- ✅ Easiest setup for non-technical users

**Setup:**

1. Sign up at https://www.cloudflare.com (free)
2. Install Cloudflared: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/install-and-setup/
3. Create tunnel:
   ```bash
   cloudflared tunnel login
   cloudflared tunnel create thoth
   ```
4. Configure tunnel to point to Thoth:
   ```bash
   cloudflared tunnel route dns thoth your-domain.com
   # Or create a config file pointing to http://127.0.0.1:8080
   ```
5. Run tunnel:
   ```bash
   cloudflared tunnel run thoth
   ```
6. Access from anywhere: `https://thoth.your-domain.com`

**Add Password Protection (optional):**
Use Cloudflare Access to require login before accessing Thoth.

---

#### Alternative: Tailscale (VPN-Style, Private Network)

If you want access from anywhere but prefer a **private network** (not internet):

1. Install Tailscale: https://tailscale.com
2. Connect your home computer and other devices
3. Access Thoth at: `http://<home-computer-tailscale-ip>:8080`

**Pros:** More private, peer-to-peer, no central server  
**Cons:** Only works for devices on your Tailscale network (not true internet)

---

#### Alternative: ngrok (Quick & Easy, Limited)

For quick testing (not production):

```bash
ngrok http 8080
# Gives you a public URL like: https://abc123.ngrok.io
```

**Pros:** Fastest setup, no server needed  
**Cons:** Free tier limited bandwidth, URL changes on restart

---

## Security Hardening Checklist

If exposing over network:

- [ ] **Change THOTH_BIND from default 127.0.0.1**
  ```bash
  # Enable network access
  THOTH_BIND=0.0.0.0
  ```

- [ ] **Add reverse proxy** (nginx, Caddy, or Cloudflare)
  - Provides authentication layer
  - Enforces HTTPS/TLS
  - Rate limiting
  - DDoS protection

- [ ] **Enable OS firewall** to limit access
  ```bash
  # macOS: Only allow from specific IPs
  sudo pfctl -e
  
  # Linux: Only allow port 8080 from trusted network
  sudo ufw allow from 192.168.1.0/24 to any port 8080
  ```

- [ ] **Monitor logs** for suspicious activity
  ```bash
  docker-compose logs -f | grep -i error
  ```

- [ ] **Set strong API keys** in .env
  ```bash
  OPENROUTER_API_KEY=sk-or-...
  OPENAI_API_KEY=sk-...
  ```

- [ ] **Disable Thoth if not in use**
  ```bash
  docker-compose down
  ```

- [ ] **Keep Docker updated**
  ```bash
  docker --version  # Should be 20.10+
  ```

---

## Common Network Scenarios

### Scenario 1: "I just want to use it on my Mac"

**Use default (localhost):**
```bash
# .env
THOTH_BIND=127.0.0.1  # or omit (this is default)
```

Access: `http://localhost:8080`

**Security:** ✅ Maximum security (local only)

---

### Scenario 2: "I want to access from my phone/tablet on home WiFi"

**Step 1:** Find your machine's local IP
```bash
# macOS/Linux
ifconfig | grep "inet " | grep -v 127.0.0.1

# Windows (WSL2)
hostname -I
```

**Step 2:** Enable network binding
```bash
# .env
THOTH_BIND=0.0.0.0
```

**Step 3:** Access from phone
```
http://<your-machine-ip>:8080
```

**Example:**
```
My Mac IP is 192.168.1.100
From phone: http://192.168.1.100:8080
```

**Security:** ⚠️ Anyone on your network can access (no auth)

**Recommendation:** Run behind nginx with auth (see above)

---

### Scenario 3: "I want external internet access"

**Option A: Reverse Proxy (Recommended)**
- Use Cloudflare Tunnel (easiest, no port forwarding)
- Or: Nginx + dynamic DNS

**Option B: Port Forward (Risky)**
- ❌ Exposes home IP
- ❌ No authentication
- ❌ Vulnerable to bots/attackers

**Never do direct port forward without:**
1. Reverse proxy with auth
2. HTTPS/TLS
3. Rate limiting
4. DDoS protection

---

## Troubleshooting Network Access

**Problem: Can't access from phone on same WiFi**

```bash
# Check binding
docker-compose ps
# Should show: 0.0.0.0:8080->8080

# Check firewall allows port 8080
# macOS: System Preferences > Security & Privacy > Firewall

# Verify machine IP
ifconfig | grep "inet "

# Test from command line
curl http://127.0.0.1:8080  # Should work
curl http://<your-ip>:8080  # Should work if THOTH_BIND=0.0.0.0
```

**Problem: THOTH_BIND changes don't take effect**

```bash
# Rebuild container
docker-compose down
docker-compose up -d --build
```

---

## Summary

| Scenario | THOTH_BIND | Access | Security |
|----------|-----------|--------|----------|
| Local only | `127.0.0.1` | `localhost:8080` | ✅ Maximum |
| Home WiFi | `0.0.0.0` | `192.168.x.x:8080` | ⚠️ Add proxy |
| Internet | `127.0.0.1` | Cloudflare/Nginx | ✅ Hardened |

**Default recommendation:** Start with `127.0.0.1` (localhost), add networking only when needed, always use a reverse proxy for external access.
