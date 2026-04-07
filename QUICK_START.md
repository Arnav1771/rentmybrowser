# 🚀 Quick Start Guide

## 5-Minute Setup

1. **Get Gemini API Key** (1 min)
   ```
   → Open: https://aistudio.google.com/app/apikeys
   → Create API Key
   → Copy the key
   ```

2. **Run Setup Script** (3 min)
   ```powershell
   powershell -ExecutionPolicy Bypass .\setup.ps1
   ```

3. **Follow Menu Options:**
   - **[3]** Check Prerequisites
   - **[4]** Create GitHub Repository
   - **[5]** Add GEMINI_API_KEY Secret
   - **[6]** Trigger Workflow

4. **Start Earning!** (1 min)
   - Wait 30 seconds for workflow to start
   - Visit: https://github.com/YOUR_USERNAME/rentmybrowser-node/actions
   - Check earnings at: https://rentmybrowser.dev/dashboard

---

## How It Works

```
Your Gemini API Key
         ↓
   GitHub Secrets (encrypted)
         ↓
   GitHub Actions Workflow (every 5h)
         ↓
   Ubuntu Linux: Firefox + OpenClaw
         ↓
   rent-my-browser Skill Activated
         ↓
   Node goes online, waits for tasks
         ↓
   AI Agents send browser tasks
         ↓
   Your browser executes tasks
         ↓
   You earn 80% of revenue
```

---

## Common Commands

```bash
# Check if repo is set up
gh repo view

# See your secrets
gh secret list

# Trigger workflow manually
gh workflow run browser-node.yml

# View latest logs
gh run view --log

# View all runs
gh run list --limit 10
```

---

## Earning Potential

| Task Complexity | Credits | Your Earnings |
|-----------------|---------|---------------|
| Simple          | 5-10    | $0.04-0.08    |
| Medium          | 10-12   | $0.08-0.96    |
| Complex         | 15      | $0.12         |

**Estimate:** 10-50 tasks/day = $5-50/day (varies by demand)

---

## Troubleshooting

❌ **"GEMINI_API_KEY not found"**
→ Go to option [5] and add the secret

❌ **"gh: command not found"**
→ Install GitHub CLI: https://cli.github.com/

❌ **Workflow doesn't run**
→ Option [3] to verify prerequisites
→ Option [7] to check status

❌ **No tasks arriving**
→ Wait 2-3 minutes after workflow starts
→ Check dashboard: https://rentmybrowser.dev/dashboard

---

## Next Steps

✅ Complete setup (above)
✅ Monitor first workflow run (1-2 hours)
✅ Verify earnings appear on dashboard
✅ Set up auto-restart (optional, see SETUP_GUIDE.md)
✅ Join Discord: https://discord.com/invite/Ma7GuySQ7h

---

## Support

- **Setup Issues**: See SETUP_GUIDE.md
- **RentMyBrowser Docs**: https://rentmybrowser.dev/browser-node-setup
- **Community**: https://discord.com/invite/Ma7GuySQ7h
- **GitHub Issues**: https://github.com/0xpasho/rent-my-browser/issues

---

**Ready to earn? Run `powershell .\setup.ps1` now! 💰**
