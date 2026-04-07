# 🎯 Manual GitHub Actions Setup (No Scripts)

## Quick Setup - Do This in GitHub UI

### Step 1: Add Your Gemini API Key as a Secret (5 min)

1. Go to your repository: https://github.com/Arnav1771/rentmybrowser
2. Click **Settings** (top right)
3. Click **Secrets and variables** → **Actions** (left sidebar)
4. Click **New repository secret** (green button)
5. Fill in:
   - **Name:** `GEMINI_API_KEY`
   - **Value:** (paste your Gemini API key from https://aistudio.google.com/app/apikeys)
6. Click **Add secret**

✅ Secret is now saved!

---

### Step 2: Trigger the Workflow (1 min)

1. Go to your repository: https://github.com/Arnav1771/rentmybrowser
2. Click **Actions** tab (top navigation)
3. Click **🌐 Rent My Browser Node** (left sidebar)
4. Click **Run workflow** (blue button on right)
5. Click **Run workflow** again (confirm)

✅ Workflow is now running!

---

### Step 3: Monitor Progress (30 sec - ongoing)

1. Stay in the **Actions** tab
2. You'll see a new run appear in ~5 seconds
3. Click the run to see live logs
4. Watch as it:
   - Sets up Node.js ✅
   - Installs Firefox ✅
   - Installs OpenClaw ✅
   - Runs failover.sh ✅
   - Node goes online ✅

---

### Step 4: Check Earnings (after 2-3 min)

1. Visit: https://rentmybrowser.dev/dashboard
2. Sign in with your account
3. You should see your node appearing "online"
4. Wait 5-10 minutes for first tasks to arrive

---

## What's Happening

```
Your Gemini API Key
       ↓
GitHub Secret (encrypted & secure)
       ↓
GitHub Actions runs your workflow
       ↓
Ubuntu Linux server boots up
       ↓
Installs Firefox & OpenClaw
       ↓
Your node comes online
       ↓
Receives browser tasks from AI agents
       ↓
Executes tasks → You earn 80%
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Workflow says "API key not found" | Go back to Step 1, make sure secret name is exactly `GEMINI_API_KEY` |
| Node won't go online | Check logs - may take 2-3 minutes to register |
| No tasks arriving | Wait 5-10 minutes. If nothing, check dashboard for node status |
| Workflow times out after 6h | Normal - it auto-restarts via cron (every 5h) |

---

## Dashboard Links

- **Monitor node & earnings:** https://rentmybrowser.dev/dashboard
- **View workflow runs:** https://github.com/Arnav1771/rentmybrowser/actions
- **Get API key:** https://aistudio.google.com/app/apikeys
- **RentMyBrowser docs:** https://rentmybrowser.dev/browser-node-setup

---

## Next Steps

✅ Add secret (Step 1)  
✅ Trigger workflow (Step 2)  
✅ Monitor (Step 3)  
✅ Check earnings (Step 4)  

**That's it! You're now earning. 🚀💰**

---

## Manual Workflow Restarts (Optional)

If you want to restart the node later:
1. Go to Actions tab
2. Click **🌐 Rent My Browser Node**
3. Click **Run workflow** → **Run workflow**

Or set up auto-restart (see [SETUP_GUIDE.md](SETUP_GUIDE.md) Advanced section).
