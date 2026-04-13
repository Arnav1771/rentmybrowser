# 🌐 Rent My Browser — GitHub Actions Node

Run a [rent-my-browser](https://rentmybrowser.dev) node 24/7 on GitHub Actions.  
Your idle browser earns credits while AI agents use it.

## 🚀 Quick Setup

### 1. Create a private repo on GitHub
Go to [github.com/new](https://github.com/new) and create a **private** repo (e.g. `rentmybrowser`)

### 2. Add the `GEMINI_API_KEY` secret
In your repo → **Settings → Secrets and variables → Actions → New repository secret**:
- Name: `GEMINI_API_KEY`
- Value: your key from [aistudio.google.com](https://aistudio.google.com/app/apikeys)

### 3. Enable GitHub Actions
Push this repo's code to your new repo and the workflow will run automatically via cron every 5 hours, or trigger it manually from the **Actions** tab.

### 4. That's it!
The node runs 24/7 with auto-restart every 5 hours.

## ⚙️ How It Works

| Component | What it does |
|-----------|-------------|
| **GitHub Actions** | Ubuntu runner (free compute, runs in CI) |
| **OpenClaw** | Agent platform managing the browser node |
| **failover.sh** | Onboards OpenClaw, installs skill, starts gateway, monitors health |
| **Cron** | Auto-restarts every 5h (GitHub Actions max is 6h) |

### What happens on each run

1. Validates `GEMINI_API_KEY` secret is set
2. Installs OpenClaw CLI (`npm i -g openclaw`)
3. Runs `openclaw onboard` non-interactively (no systemd/daemon flags)
4. Starts the gateway explicitly with `openclaw gateway start`
5. Waits up to 60s for TCP port 18789 to be listening (CI-safe health check)
6. Clones [`0xPasho/rent-my-browser`](https://github.com/0xPasho/rent-my-browser) to `~/.openclaw/skills/rent-my-browser`
7. Registers the skill with `openclaw skill add --local`
8. Monitors gateway health every 2 minutes for ~5h 45m, then exits cleanly for cron restart

## 📂 Files

```
.github/workflows/browser-node.yml  ← GitHub Actions workflow
failover.sh                          ← Onboard + health monitor
README.md                            ← This file
```

## ⚠️ Notes

- **Only 1 secret needed**: `GEMINI_API_KEY`
- **Free tier**: ~2,000 min/month (private repos), unlimited (public repos)
- **Each run**: ~5h 45m, then cron restarts automatically
- **GitHub TOS**: Review [Actions usage limits](https://docs.github.com/en/actions/learn-github-actions/usage-limits-billing-and-administration)
