---
name: rentmybrowser-workspace
description: |
  Workspace instructions for rentmybrowser—a 24/7 GitHub Actions browser node that earns income by serving AI agents. 
  Use when: working on any part of the rentmybrowser project (setup, deployment, troubleshooting, operations, documentation).
---

# Rentmybrowser Workspace Instructions

## 🎯 Project Overview

**Purpose**: Earn $5–50/day by renting an idle browser to AI agents via GitHub Actions.

**How It Works**:
```
You + Gemini API Key
  → GitHub Actions Ubuntu VM (free compute)
  → Firefox Browser + OpenClaw Agent Platform
  → ClawHub Skill Installer
  → rent-my-browser Skill (polls for tasks)
  → AI agents send browser tasks
  → You earn 80% of revenue
  → Auto-restarts every 5 hours (cron)
```

**Key Components**:
- **GitHub Actions**: Free Linux compute, 6h per run max
- **OpenClaw**: Agent orchestration + browser node
- **failover.sh**: Monitors health, rotates Gemini models (4-model loop: 2.5-flash → 2.0-flash → 1.5-flash → 1.5-pro)
- **Health checks**: Every 2 minutes; switches after 5 consecutive API failures (429 errors, quota exceeded)

---

## 🚀 Build/Run Commands

### **Windows Setup**
```powershell
powershell -ExecutionPolicy Bypass .\setup.ps1
# Interactive menu (10 options):
# [1] Initialize git repo
# [3] Check prerequisites  
# [4] Create GitHub Repository
# [5] Add GEMINI_API_KEY Secret
# [6] Trigger workflow
# [7] Check node status
```

### **Linux/macOS Setup**
```bash
bash setup.sh
# Same menu as Windows (with emoji formatting)
```

### **Trigger Workflow Manually**
```bash
gh workflow run browser-node.yml
gh run view --log  # Check logs
```

### **CI/Build System**
- **Workflow file**: `.github/workflows/browser-node.yml` (runs every ~5h via cron)
- **Failover monitor**: `failover.sh` runs inside the workflow; detects rate limits and rotates models

---

## 📂 Key Files & Responsibilities

| File | Purpose |
|------|---------|
| `setup.ps1` / `setup.sh` | Interactive setup: init repo, add secrets, trigger workflow, check status |
| `failover.sh` | Health monitor + Gemini model rotation; runs in GitHub Actions workflow |
| `start-node.bat` | Legacy Windows batch wrapper (alternative to setup.ps1) |
| `.github/workflows/browser-node.yml` | GitHub Actions CI/CD workflow; runs browser node every 5h |
| `QUICK_START.md` | 5-minute setup guide (start here!) |
| `SETUP_GUIDE.md` | Detailed step-by-step setup with troubleshooting |
| `MANUAL_SETUP.md` | Reference for manual GitHub/Secret configuration |
| `TROUBLESHOOTING.md` | Common errors and fixes |
| `VERIFICATION_CHECKLIST.md` | Pre-deployment verification checklist |
| `EARNINGS_GUIDE.md` | Revenue estimates and task complexity breakdown |
| `method.md` | Technical deep-dive: architecture, model rotation, health checks |
| `INDEX.md` | Documentation roadmap; start here for reference |

---

## 🔧 Architecture & Configuration

### **Environment Variables**
- **`GEMINI_API_KEY`**: Only required secret (stored in GitHub Secrets)
- Stored as GitHub secret, injected at runtime

### **Model Rotation Logic** (See: [method.md](./method.md))
1. Start with `gemini-2.5-flash`
2. On 429 error or quota exceeded → rotate to next model
3. After **5 consecutive failures** → try next model
4. Loop: 2.5-flash → 2.0-flash → 1.5-flash → 1.5-pro → (repeat)
5. Health checked every 2 minutes

### **Deployment Flow**
1. User runs setup script (option [4]–[6])
2. GitHub repo created with workflow committed
3. GEMINI_API_KEY added as GitHub secret
4. Workflow triggered manually or via cron (every 5h)
5. Ubuntu VM boots, pulls code, runs browser node
6. Node registers with rent-my-browser platform
7. Tasks arrive, browser executes, revenue earned
8. After ~5h 50m, cron triggers restart

---

## 📚 Documentation Pattern

**Tiered Guides** (by audience):
- **QUICK_START.md**: First-time users (5 min read)
- **SETUP_GUIDE.md**: Detailed walkthrough with validation
- **MANUAL_SETUP.md**: Reference; skip if using setup script
- **TROUBLESHOOTING.md**: Error diagnostics + fixes
- **method.md**: Technical architecture + model rotation details
- **VERIFICATION_CHECKLIST.md**: Pre-flight checklist before going live
- **EARNINGS_GUIDE.md**: Revenue expectations and task breakdown
- **INDEX.md**: Documentation roadmap

**Pattern**: Most guides link to each other; minimal duplication.

---

## 🚨 Common Conventions & Gotchas

### **Scripts**
- Both `setup.ps1` and `setup.sh` follow same UX (interactive menu, colored output)
- Menu options are numbered and idempotent (safe to rerun)
- Use `gh` CLI for GitHub operations (requires auth: `gh auth login`)

### **Repository Setup**
- **Must use a PRIVATE repo** (GitHub's terms; free public minutes are unlimited, but security)
- Free tier = ~2,000 minutes/month (enough for 1 node)

### **Secrets & Security**
- Only 1 secret needed: `GEMINI_API_KEY`
- Always use GitHub Secrets (never hardcode in repo)
- Secret added via `gh secret set GEMINI_API_KEY` (setup script does this)

### **OpenClaw CLI Gotchas**
- ⚠️ **Skill install command**: Old versions used `install`; newer use `openclaw skill install <slug>`—setup script validates this
- ⚠️ **`/dev/tty` warnings in CI**: Non-fatal; GitHub Actions can't allocate TTY, but workflow continues
- ⚠️ **Only official flags work**: Don't try custom provider flags; only OpenClaw's official flags are supported

### **Timing & Restarts**
- GitHub Actions max run is 6 hours; cron restarts every 5h 50m to stay under limit
- Workflow auto-restart is **automatic** (no manual intervention needed)

---

## ✅ Quick Checklist Before Deployment

See [VERIFICATION_CHECKLIST.md](./VERIFICATION_CHECKLIST.md) for full pre-flight checklist.

**TL;DR**:
- [ ] Gemini API key created (https://aistudio.google.com/app/apikeys)
- [ ] GitHub repo created (private)
- [ ] `gh` CLI installed and authenticated
- [ ] Setup script run successfully (options [3]→[4]→[5]→[6])
- [ ] Workflow triggered and visible in Actions tab
- [ ] Node online after 30s (check rentmybrowser.dev/dashboard)

---

## 🎓 When Working on Different Areas

### **Adding New Features / Fixing Bugs**
1. Check [INDEX.md](./INDEX.md) for relevant guide
2. Validate against [method.md](./method.md) (architecture)
3. Test with `gh workflow run browser-node.yml`
4. Update [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) if adding new error handling

### **Improving Setup / Onboarding**
1. Update setup script (`setup.ps1` or `setup.sh`)
2. Mirror changes between both versions (keep in sync)
3. Test: `powershell -ExecutionPolicy Bypass .\setup.ps1` (Windows) or `bash setup.sh` (Linux)
4. Update corresponding guide ([QUICK_START.md](./QUICK_START.md) or [SETUP_GUIDE.md](./SETUP_GUIDE.md))

### **Troubleshooting User Issues**
1. Reference [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) first
2. Check logs: `gh run view --log`
3. Validate with [VERIFICATION_CHECKLIST.md](./VERIFICATION_CHECKLIST.md)
4. If new issue found, add to [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) and [method.md](./method.md) if technical

### **Documentation Updates**
- Avoid duplication: link to [INDEX.md](./INDEX.md) instead of repeating structure
- Keep [QUICK_START.md](./QUICK_START.md) ≤ 5 min read
- [SETUP_GUIDE.md](./SETUP_GUIDE.md) can be detailed; use sections
- Update timestamps/version numbers consistently

---

## 📖 Join Tips

**New to the project?**
1. Read [README.md](../README.md) (2 min overview)
2. Read [QUICK_START.md](./QUICK_START.md) (5 min hands-on)
3. Run `setup.ps1` option [3] to validate environment

**Already deployed?**
- Monitor earnings: https://rentmybrowser.dev/dashboard
- Check status: `gh run view --log` or `gh run list --limit 5`
- Troubleshoot: See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

**Want to understand the guts?**
- Read [method.md](./method.md) (model rotation, health checks, architecture)
- Review `failover.sh` (implementation)
- Check `.github/workflows/browser-node.yml` (CI/CD config)
