# 🌐 Rent My Browser — GitHub Actions Node

Run a [rent-my-browser](https://rentmybrowser.dev) node 24/7 on GitHub Actions.  
Your idle browser earns credits while AI agents use it.

## 🚀 Quick Setup

### 1. Create a private repo on GitHub
Go to [github.com/new](https://github.com/new) and create a **private** repo (e.g. `rentmybrowser`)

### 2. Run `start-node.bat`

| Step | Option | What it does |
|------|--------|-------------|
| First | **[1]** | Initializes git, asks for your repo URL, pushes code |
| Then | **[7]** | Saves your Gemini API key as a GitHub Secret |
| Finally | **[4]** | Triggers the workflow (or use the Actions tab) |

### 3. That's it!
The node runs 24/7 with auto-restart every 5 hours.

## 🔄 Gemini Model Failover

One API key — four models. If rate limits are hit, the node automatically switches:

```
gemini-2.5-flash → gemini-2.0-flash → gemini-1.5-flash → gemini-1.5-pro → (loops back)
```

- Health checked every **2 minutes**
- Switches after **5 consecutive failures**
- Detects 429 errors, quota exceeded, rate limits

## ⚙️ How It Works

| Component | What it does |
|-----------|-------------|
| **GitHub Actions** | Free Linux compute with Chrome |
| **OpenClaw** | Agent platform managing the browser node |
| **ClawHub** | Installs the rent-my-browser skill |
| **failover.sh** | Monitors health + rotates Gemini models |
| **Cron** | Auto-restarts every 5h (GitHub max is 6h) |

## 📂 Files

```
.github/workflows/browser-node.yml  ← GitHub Actions workflow
failover.sh                          ← Gemini model rotation + health monitor
start-node.bat                       ← Windows management menu
README.md                            ← This file
```

## ⚠️ Notes

- **Free tier**: ~2,000 min/month (private repos), unlimited (public repos)
- **Each run**: ~5h 50m, then cron restarts automatically
- **Only 1 secret needed**: `GEMINI_API_KEY`
- **GitHub TOS**: Review [Actions usage policies](https://docs.github.com/en/site-policy/github-terms/github-t
- **Skill Installation Error**: If you encounter `error: unknown command 'install'` during skill setup, ensure your `openclaw` CLI is up-to-date. The correct command for installing skills is typically `openclaw skill install <skill-slug>`.