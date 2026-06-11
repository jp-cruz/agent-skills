# Remote Access to Thoth (Safe Methods)

**Don't expose the web UI to the internet.** Thoth offers better ways to access it remotely.

---

## Why Not Web UI Over Internet?

Direct web access requires:
- ❌ Reverse proxy setup (complex)
- ❌ Authentication layer (additional work)
- ❌ HTTPS certificates (maintenance)
- ❌ Constant exposure (DDoS risk)

## Better: Thoth's Native Integrations

Thoth can be accessed through messaging platforms you already use:

---

## Option 1: Discord Bot (Recommended)

Access Thoth directly from Discord. All the power, safer interface.

**Setup:**
1. In Thoth, go to Settings → Integrations
2. Enable Discord bot
3. Create a Discord server or use existing one
4. Add bot to your server
5. Start chatting with Thoth via Discord

**Advantages:**
- ✅ Authenticated (only your Discord account)
- ✅ Encrypted (Discord's encryption)
- ✅ No web UI exposure
- ✅ Works from phone, desktop, browser
- ✅ Message history in Discord
- ✅ Can share conversations with others selectively

**Limitations:**
- Discord API rate limits
- Message length limits (Discord's 2000 char limit)

**Setup Link:** [Thoth Discord Integration](https://github.com/siddsachar/Thoth#discord-integration)

---

## Option 2: SMS/Text Message Integration

Control Thoth by texting it. Simple, no app needed.

**Setup:**
1. In Thoth, go to Settings → Integrations
2. Enable SMS integration
3. Link your phone number
4. Configure SMS provider (Twilio, AWS SNS, etc.)
5. Start texting Thoth

**Advantages:**
- ✅ Authenticated (only your phone number)
- ✅ Works on any phone (no app needed)
- ✅ Simple interface
- ✅ Private (no internet exposure)
- ✅ Instant notifications

**Limitations:**
- Requires SMS provider (small cost)
- Longer response times (SMS latency)
- Character limits

**Setup Link:** [Thoth SMS Integration](https://github.com/siddsachar/Thoth#sms-integration)

---

## Option 3: Signal Bot

Use Signal's secure messaging to control Thoth.

**Setup:**
1. Install Signal (https://signal.org)
2. In Thoth, go to Settings → Integrations
3. Enable Signal bot
4. Link Signal to Thoth
5. Start chatting privately

**Advantages:**
- ✅ End-to-end encrypted
- ✅ Authenticated (your Signal account)
- ✅ Most private messaging option
- ✅ No corporate platform
- ✅ Works on phone and desktop

**Limitations:**
- Requires Signal app
- Smaller user base

**Setup Link:** [Thoth Signal Integration](https://github.com/siddsachar/Thoth#signal-integration)

---

## Option 4: Facebook/Instagram Messenger Bot

Control Thoth via Messenger if you use Meta's platforms.

**Setup:**
1. In Thoth, go to Settings → Integrations
2. Enable Messenger bot
3. Connect Facebook app
4. Add bot to your Messenger
5. Start chatting

**Advantages:**
- ✅ Authenticated via Facebook
- ✅ Encrypted by default
- ✅ Works on phone and web
- ✅ Good for family/team access

**Limitations:**
- Requires Meta account
- Dependent on Meta's infrastructure

**Setup Link:** [Thoth Messenger Integration](https://github.com/siddsachar/Thoth#messenger-integration)

---

## If You Still Want Web Access Remotely

If you absolutely need web UI access from the internet:

1. **Use Tailscale** (VPN-style, private network)
   - Install on home computer and other devices
   - Create private network
   - Access Thoth as if you're home
   - Secure, peer-to-peer

2. **Use Cloudflare Tunnel** (with authentication)
   - Set up Cloudflare Tunnel
   - Enable Cloudflare Access
   - Require login before web access
   - DDoS protected

See [NETWORK_SETUP.md](references/NETWORK_SETUP.md) for detailed setup.

---

## Comparison Table

| Method | Auth | Encryption | Setup | Use Case |
|--------|------|-----------|-------|----------|
| **Discord Bot** | ✅ | ✅ | 10 min | Primary access, teams |
| **SMS** | ✅ | ⚠️ | 15 min | Phone-only, simple |
| **Signal** | ✅ | ✅✅ | 10 min | Max privacy |
| **Messenger** | ✅ | ✅ | 10 min | Facebook users |
| **Web UI (Tailscale)** | ✅ | ✅ | 20 min | Full web UI, private |
| **Web UI (Cloudflare)** | ✅ | ✅ | 30 min | Full web UI, public |

---

## Recommendation

**Start with Discord Bot** — it's the best balance of:
- Easy setup
- Full Thoth features
- Secure by default
- Great UX
- No infrastructure needed

Then add SMS if you want phone-only access.

Only expose the web UI if you specifically need it (advanced debugging, team dashboard, etc.).

---

## More Information

- Thoth documentation: https://github.com/siddsachar/Thoth
- Discord setup: [THOTH_DISCORD_BOT.md](THOTH_DISCORD_BOT.md)
- SMS setup: [THOTH_SMS_INTEGRATION.md](THOTH_SMS_INTEGRATION.md)
- Web UI security: [NETWORK_SETUP.md](references/NETWORK_SETUP.md)
