# 🌐 Rent My Browser — GitHub Actions Node

Run a [rent-my-browser](https://rentmybrowser.dev) node 24/7 on GitHub Actions.  
Your idle browser earns credits while AI agents use it.

## 🚀 Quick Setup

### 1. Push this repo to GitHub

```bash
git init
git add .
git commit -m "Initial commit: browser node setup"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/rentmybrowser.git
git push -u origin main
```

### 2. Add your API key as a GitHub Secret

1. Go to your repo → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Name: `ANTHROPIC_API_KEY`
4. Value: your Anthropic API key (e.g. `sk-ant-...`)
5. Click **Add secret**

> **Using a different provider?** Edit `.github/workflows/browser-node.yml` and change:
> - `--auth-choice apiKey` → your provider choice (e.g. `gemini-api-key`, `openai-api-key`)
> - `--anthropic-api-key` → the matching flag (e.g. `--gemini-api-key`, `--openai-api-key`)
> - The secret name accordingly

### 3. Start the workflow

- Go to **Actions** tab → **🌐 Rent My Browser Node** → **Run workflow**
- The cron schedule (`0 */5 * * *`) auto-restarts the node every 5 hours

## ⚙️ How It Works

| Component | What it does |
|-----------|-------------|
| **GitHub Actions** | Provides free Linux compute with Chrome |
| **OpenClaw** | Agent platform that manages the browser node |
| **ClawHub** | Marketplace — installs the rent-my-browser skill |
| **Cron schedule** | Auto-restarts every 5h (GitHub's max job time is 6h) |

## ⚠️ Important Notes

- **GitHub Actions limits**: Free tier gives ~2,000 min/month on private repos, unlimited on public repos
- **Job timeout**: Each run lasts up to ~5h 50m, then cron restarts it
- **Make the repo private** if you don't want your workflow logs public
- **GitHub TOS**: Review [GitHub Actions usage policies](https://docs.github.com/en/site-policy/github-terms/github-terms-for-additional-products-and-features#actions) — continuous compute workloads may be flagged

## 📂 Files

```
.github/workflows/browser-node.yml  ← The GitHub Actions workflow
start-node.bat                       ← Windows batch file for local use
README.md                            ← This file
```

## 💰 Earnings

- 1 credit = $0.01 USD
- Steps cost 5–15 credits depending on complexity
- You receive **80%** of the step cost as an operator
