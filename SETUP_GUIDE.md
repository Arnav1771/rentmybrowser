# 🌐 RentMyBrowser + GitHub Actions Setup Guide

## What You're Setting Up

**RentMyBrowser** is a platform where you earn money by renting out your idle browser to AI agents. You'll be:

1. Running an **OpenClaw node operator** on GitHub Actions (free Linux compute)
2. Installing a skill that accepts browser rental tasks from AI agents
3. Earning **80% of task revenue** automatically
4. Using Gemini API with automatic model failover when rate limits hit

### The Economics
- **Task cost**: 5-15 credits per step (~$0.05-$0.15)
- **Your revenue**: 80% of task cost
- **Minimum to start**: $0
- **Expected earnings**: ~$5-$50/day (varies by task volume)

---

## Prerequisites

✅ **GitHub Account** with Pro/Enterprise subscription (for compute minutes)  
✅ **Gemini API Key** (free tier: https://aistudio.google.com/app/apikeys)  
✅ **GitHub CLI** (`gh`) installed on your local machine  
✅ **Git** installed on your local machine

---

## Step-by-Step Setup

### Phase 1: Prepare Your Local Environment

#### 1.1 Get Your Gemini API Key

1. Visit [aistudio.google.com/app/apikeys](https://aistudio.google.com/app/apikeys)
2. Click **"Create API Key"**
3. Select **"Create API key in new project"**
4. Copy the API key (keep it secret!)
5. Store it safely — you'll need it in the next steps

#### 1.2 Verify GitHub CLI

```bash
# Check if gh is installed
gh --version

# If not installed, download from: https://cli.github.com/
```

#### 1.3 Authenticate with GitHub

```bash
gh auth login
# Follow prompts to authenticate
```

---

### Phase 2: Create Your Private GitHub Repository

#### 2.1 Create the Repo via GitHub CLI

```bash
# Navigate to your rentmybrowser directory
cd c:\Users\Bhargava\Documents\rentmybrowser

# Create a private repository
gh repo create rentmybrowser-node --private --source=. --remote=origin --push
```

**OR manually create via GitHub:**
- Go to [github.com/new](https://github.com/new)
- Repository name: `rentmybrowser-node`
- Description: "🌐 Rent My Browser node on GitHub Actions"
- **Privacy: PRIVATE** (important for security)
- Click **Create repository**
- Then push your code:

```bash
cd c:\Users\Bhargava\Documents\rentmybrowser
git init
git add .
git commit -m "Initial commit: RentMyBrowser node setup"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/rentmybrowser-node.git
git push -u origin main
```

---

### Phase 3: Add GitHub Secrets

Your Gemini API key must be stored as a GitHub Secret (encrypted).

#### 3.1 Add via GitHub CLI

```bash
# Replace with your actual API key
gh secret set GEMINI_API_KEY --body "YOUR_GEMINI_API_KEY" -R YOUR_USERNAME/rentmybrowser-node
```

#### 3.2 Add via GitHub Web UI

1. Go to your repo: `github.com/YOUR_USERNAME/rentmybrowser-node`
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. **Name**: `GEMINI_API_KEY`
5. **Value**: Paste your Gemini API key
6. Click **Add secret**

**Verify the secret was added:**
```bash
gh secret list -R YOUR_USERNAME/rentmybrowser-node
```

---

### Phase 4: Trigger Your First Workflow Run

#### 4.1 Via GitHub CLI

```bash
gh workflow run browser-node.yml -R YOUR_USERNAME/rentmybrowser-node
```

#### 4.2 Via GitHub Web UI

1. Go to your repo
2. Click **Actions** tab
3. Select **🌐 Rent My Browser Node** workflow
4. Click **Run workflow** → **Run workflow**
5. Wait 30 seconds for the run to appear

#### 4.3 Monitor the Run

```bash
# Watch logs in real-time
gh run list -R YOUR_USERNAME/rentmybrowser-node --limit 1
gh run view <RUN_ID> --log

# Or view in browser:
# github.com/YOUR_USERNAME/rentmybrowser-node/actions
```

---

## Understanding the Workflow

### How It Works

```
┌─────────────────────────────────────────────────────┐
│ GitHub Actions (Ubuntu Linux, runs 24/7)            │
│                                                       │
│  1. Install Node.js 22 + Firefox                     │
│  2. Install OpenClaw (agent platform)                │
│  3. Install ClawHub (skill marketplace)              │
│  4. Run failover.sh script                           │
│     ├─ Initialize Gemini model                       │
│     ├─ Run OpenClaw onboarding                       │
│     ├─ Install rent-my-browser skill                 │
│     ├─ Monitor health every 2 minutes                │
│     └─ Switch models on 5 consecutive failures       │
│  5. Node goes online and waits for tasks             │
│  6. Tasks arrive → browser executes → you earn       │
│  7. After 5h 45m, workflow stops & cron restarts     │
└─────────────────────────────────────────────────────┘
```

### The Gemini Model Rotation

Your node automatically cycles through 4 Gemini models if rate limits hit:

| Model            | Speed | Cost | Use When                   |
|------------------|-------|------|---------------------------|
| gemini-2.5-flash | Fast  | Low  | First choice               |
| gemini-2.0-flash | Fast  | Low  | gemini-2.5 rate limited    |
| gemini-1.5-flash | Fast  | Low  | Both 2.x models limited    |
| gemini-1.5-pro   | Slow  | High | All fast models limited    |

**Health Check Logic:**
- Every 2 minutes: Check gateway status + recent error logs
- If 3+ rate limit errors in last 50 log lines → mark as failed
- After 5 consecutive failures → switch to next model
- Resets failure counter when healthy

### Workflow Timing

| Trigger    | Frequency | What Happens                              |
|------------|-----------|-------------------------------------------|
| Cron       | Every 5h  | Scheduled auto-restart                    |
| Manual     | Anytime   | Click "Run workflow" in Actions tab        |
| Webhook    | On push   | (Optional: can be added)                  |

**GitHub Limits:**
- Max 6 hours per workflow run (we use 5h 45m)
- If your Pro plan has 3,000 minutes/month = ~1 continuous run per month
- Workflows can chain with `if.always()` to restart automatically

---

## Monitoring Your Earnings

### Check Node Status

1. **Via GitHub Actions UI:**
   - Go to Actions → 🌐 Rent My Browser Node
   - Click latest run → view logs

2. **Check Node Online Status:**
   - Visit [rentmybrowser.dev/dashboard](https://rentmybrowser.dev/dashboard)
   - Sign in with the same account
   - View your node's tasks and earnings

### Earnings Appear in:
- RentMyBrowser dashboard
- Your account balance (can withdraw to bank/crypto)
- Billing section shows transactions

---

## Troubleshooting

### Workflow Won't Start
- ✅ Check GitHub CLI is authenticated: `gh auth status`
- ✅ Verify repository exists: `gh repo view`
- ✅ Check GEMINI_API_KEY secret: `gh secret list`

### Node Crashes or Logs Empty
- ✅ Inspect logs: Go to Actions → click run → view job logs
- ✅ Check Gemini API key validity on [aistudio.google.com](https://aistudio.google.com)
- ✅ Verify internet connectivity (GitHub Actions has it)

### Not Receiving Tasks
- ✅ Wait 2-3 minutes after node startup (requires heartbeat registration)
- ✅ Check node shows "online" on [rentmybrowser.dev/dashboard](https://rentmybrowser.dev/dashboard)
- ✅ Verify no tasks are currently available (check task queue)

### High Resource Usage
- ✅ This is normal — Firefox uses ~500MB RAM
- ✅ GitHub Actions provides 7GB RAM, so no issue

---

## Advanced: Auto-Restart with Workflows

To run continuously without manual intervention, add a second workflow that chains restarts:

**File: `.github/workflows/auto-restart.yml`**
```yaml
name: Auto Restart Browser Node

on:
  workflow_run:
    workflows: ["🌐 Rent My Browser Node"]
    types:
      - completed

jobs:
  restart:
    runs-on: ubuntu-latest
    if: github.event.workflow_run.conclusion == 'success'
    steps:
      - uses: actions/github-script@v7
        with:
          script: |
            github.rest.actions.createWorkflowDispatch({
              owner: context.repo.owner,
              repo: context.repo.repo,
              workflow_id: 'browser-node.yml',
              ref: 'main'
            })
```

This automatically restarts the workflow after it completes!

---

## Next Steps

### Short Term (Today)
- [ ] Get Gemini API key
- [ ] Create GitHub repository
- [ ] Add GEMINI_API_KEY secret
- [ ] Trigger workflow
- [ ] Check logs

### Medium Term (This Week)
- [ ] Monitor first earnings
- [ ] Verify node appears online on rentmybrowser.dev dashboard
- [ ] Join Discord community for support: [discord.gg/Ma7GuySQ7h](https://discord.com/invite/Ma7GuySQ7h)

### Long Term (Ongoing)
- [ ] Monitor different task types and earnings patterns
- [ ] Consider running multiple nodes on free-tier alternatives
- [ ] Optimize model selection based on your task mix

---

## Quick Command Reference

```bash
# Setup
gh repo create rentmybrowser-node --private --source=. --push
gh secret set GEMINI_API_KEY --body "YOUR_KEY"

# Manage
gh workflow run browser-node.yml
gh run list
gh run view <RUN_ID> --log

# Debug
gh run view <RUN_ID> -v
gh secret list
```

---

## Security Best Practices

⚠️ **Important:**
- ✅ Keep your repository **PRIVATE**
- ✅ Never commit API keys directly
- ✅ Use GitHub Secrets for all sensitive data
- ✅ Rotate API keys regularly
- ✅ Monitor your account for suspicious activity

---

## Support

- **Documentation**: [rentmybrowser.dev/api-docs](https://rentmybrowser.dev/api-docs)
- **Discord**: [discord.gg/Ma7GuySQ7h](https://discord.com/invite/Ma7GuySQ7h)
- **GitHub Issues**: [github.com/0xpasho/rent-my-browser/issues](https://github.com/0xpasho/rent-my-browser/issues)
- **Node Setup Docs**: [rentmybrowser.dev/browser-node-setup](https://rentmybrowser.dev/browser-node-setup)

---

**Happy earning! 🚀**
