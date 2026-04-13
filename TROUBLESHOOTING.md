# 🔧 Troubleshooting & FAQ

## Common Issues & Solutions

### 🔴 Workflow Fails to Run

**Error:** "Workflow not triggering" or "No recent runs"

**Solutions:**
1. Check GitHub CLI is authenticated:
   ```bash
   gh auth status
   ```
   If not, run: `gh auth login`

2. Verify repository exists:
   ```bash
   gh repo view
   ```
   Should show your repository info

3. Check GEMINI_API_KEY secret is set:
   ```bash
   gh secret list
   ```
   Must show `GEMINI_API_KEY` in the list

4. Try triggering manually:
   ```bash
   gh workflow run browser-node.yml
   ```

---

### 🔴 Error: "GEMINI_API_KEY not found"

**Cause:** Secret not added to GitHub

**Solutions:**
1. Run setup script menu option [5]:
   ```bash
   powershell .\setup.ps1  # Windows
   bash setup.sh           # macOS/Linux
   ```

2. Or manually add via GitHub web:
   - Go to your repo → Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `GEMINI_API_KEY`
   - Value: Your Gemini API key
   - Click "Add secret"

3. Verify it was added:
   ```bash
   gh secret list
   ```

---

### 🔴 Error: "GitHub CLI not found" or "gh: command not found"

**Cause:** GitHub CLI not installed

**Solutions:**
1. **Windows:**
   - Download: https://cli.github.com/
   - Run installer
   - Restart terminal
   - Run: `gh auth login`

2. **macOS:**
   ```bash
   brew install gh
   ```

3. **Linux (Ubuntu/Debian):**
   ```bash
   sudo apt update
   sudo apt install gh
   ```

---

### 🔴 Error: "Git not found" or "fatal: not a git repository"

**Cause:** Git not installed or not in git directory

**Solutions:**
1. Install Git: https://git-scm.com/

2. Make sure you're in the rentmybrowser directory:
   ```bash
   cd ~/Documents/rentmybrowser  # or your path
   ```

3. Initialize git if needed:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   ```

---

### 🟡 Workflow Starts But Node Crashes

**Possible causes:**
- Invalid Gemini API key
- Rate limit hit immediately
- Firefox installation failed
- OpenClaw installation failed

**Solutions:**
1. Check workflow logs:
   ```bash
   gh run view --log
   ```

2. Verify Gemini API key is valid:
   - Visit https://aistudio.google.com/app/apikeys
   - Make sure the key hasn't been deleted or revoked
   - Test the key is working

3. Check for rate limits:
   - Visit https://aistudio.google.com/app/usage
   - Make sure you haven't hit Gemini API rate limits

4. Look for specific error messages in logs:
   ```bash
   gh run view <RUN_ID> -v  # verbose output
   ```

---

### 🟡 Node Online But No Tasks Arriving

**Possible causes:**
- Node still registering (takes 2-3 minutes)
- No tasks available in queue
- Node not actually online on platform

**Solutions:**
1. **Wait 2-3 minutes** - Registration takes time

2. Verify node is online:
   - Visit https://rentmybrowser.dev/dashboard
   - Sign in with your account
   - Check if your node shows "online"

3. If not showing online:
   - Check workflow is still running:
     ```bash
     gh run list --limit 1
     ```
   - Check logs for connection errors in failover.sh output

4. Check task availability:
   - Visit https://rentmybrowser.dev
   - Look for available tasks
   - If no tasks, wait or submit a test task

---

### 🟡 High Resource Usage / Workflow Timing Out

**Possible causes:**
- Browser consuming too much memory
- Tasks taking too long
- GitHub Actions timeout (6 hours max)

**Solutions:**
1. This is normal - Firefox uses ~500MB RAM
   - GitHub provides 7GB total, so plenty of room

2. Workflow timing:
   - Currently set to run 5h 45m before auto-restart
   - GitHub max is 6 hours
   - Cron triggers restart every 5 hours

3. If workflow still times out:
   - Reduce TOTAL_RUNTIME in failover.sh
   - Edit line: `TOTAL_RUNTIME=20700` to smaller value
   - 3600 seconds = 1 hour

---

### 🟡 Model Switching Too Frequently

**Issue:** Seeing "Switching to model" messages too often

**Cause:** 
- Your tasks are hitting rate limits quickly
- Health check too aggressive
- Not enough spacing between models

**Solutions:**
1. **Increase MAX_FAILURES** in failover.sh:
   ```bash
   MAX_FAILURES=10  # Changed from 5
   ```

2. **Increase HEALTH_CHECK_INTERVAL** in failover.sh:
   ```bash
   HEALTH_CHECK_INTERVAL=300  # 5 minutes instead of 2
   ```

3. **Check Gemini quota:**
   - Visit https://aistudio.google.com/app/usage
   - Ensure you haven't hit daily limit

---

### � Error: `ERR_MODULE_NOT_FOUND: Cannot find package 'viem'`

**Error Message:**
```
Error [ERR_MODULE_NOT_FOUND]: Cannot find package 'viem' imported from 
/home/runner/.openclaw/skills/rent-my-browser/scripts/generate-wallet.mjs
Error: Process completed with exit code 1
```

**Cause:** The rent-my-browser skill dependencies were not installed. When the skill is copied, its `package.json` requires packages like `viem` and `ethers`, but `npm install` was never run.

**Solution:**
This is now fixed in the latest `failover.sh`. The script automatically runs `npm install` in the skill directory after copying files.

**If you're still seeing this error:**
1. Pull the latest failover.sh:
   ```bash
   git pull
   ```

2. Trigger the workflow again:
   ```bash
   gh workflow run browser-node.yml
   ```

3. If error persists, manually update failover.sh:
   - Find the section after `cp -r "$REPO_DIR/skill/." "$SKILL_DIR/"`
   - Add these lines:
   ```bash
   echo "📦 Installing skill dependencies..."
   cd "$SKILL_DIR"
   npm install 2>&1 | tee -a "$LOG_FILE"
   cd - > /dev/null
   ```

---

### �🟡 Workflow Logs Not Showing Output

**Issue:** GitHub Actions logs appear empty or truncated

**Solutions:**
1. Use GitHub web UI instead:
   - Go to Actions → click run → click job
   - Scroll within the UI

2. Try different time window:
   ```bash
   gh run view <RUN_ID> --log --pager less
   ```

3. Check if workflow is still running:
   - If "in progress", logs appear after completion
   - If "success", should have full logs

---

## Performance Optimization

### Maximize Earnings

1. **Keep Node Online 24/7:**
   - Use GitHub Pro compute credits
   - Enable auto-restart workflow (see SETUP_GUIDE.md)

2. **Monitor Task Success Rate:**
   - Visit dashboard: https://rentmybrowser.dev/dashboard
   - Track which models/tasks work best
   - Note any patterns

3. **Optimize Model Selection:**
   - Fast models (gemini-2.5-flash) earn more per hour
   - If rate limited, accept slower models briefly
   - Your node automatically balances this

4. **Check Earnings Breakdown:**
   - Dashboard shows per-task earnings
   - See which task types are most profitable
   - Prioritize accepting those tasks

---

## Monitoring Tips

### Daily Check

1. **Verify Node is Online:**
   ```bash
   gh run list --limit 1
   ```
   Should show recent run with "completed" status

2. **Check Earnings:**
   - Visit https://rentmybrowser.dev/dashboard
   - Note daily total

3. **Review Logs for Errors:**
   ```bash
   gh run view --log | grep -i "error\|failed\|rate.limit"
   ```

### Weekly Review

1. **Analyze Earnings Patterns:**
   - Is earnings trending up/down?
   - What times are busiest?
   - Which models work best?

2. **Check for Issues:**
   - Workflow failures?
   - Model switching frequency?
   - Rate limiting issues?

3. **Update if Needed:**
   - New Gemini models released?
   - Better failover strategy?
   - Update failover.sh and push changes

---

## Advanced Debugging

### Capture Full Debug Logs

```bash
# Get verbose run details
gh run view <RUN_ID> -v --log > full_debug.log

# Search for specific errors
grep -i "error" full_debug.log
grep -i "rate" full_debug.log
grep -i "404\|401\|403" full_debug.log
```

### Test Locally (Advanced)

If you want to test the failover.sh locally:

```bash
# Install OpenClaw (requires Node 22+)
npm i -g openclaw
npm i -g clawhub

# Test failover script
export GEMINI_API_KEY="your_actual_api_key"
export CI=1
export NONINTERACTIVE=1
bash ./failover.sh
```

⚠️ **Warning:** This requires Chrome/Firefox installed locally!

---

## FAQ

**Q: Can I run multiple nodes?**
A: Yes! Create separate repos with different secrets

**Q: What if I run out of API credits?**
A: Request higher limits at https://aistudio.google.com/

**Q: Can I use a different browser?**
A: Current setup uses Firefox. For Chrome, modify workflow YAML

**Q: How long does it take to earn money?**
A: First tasks usually arrive within 5-10 minutes of going online

**Q: Am I earning while the task is running?**
A: No, you earn when the task is complete. If 12-step task, you earn for 12 steps

**Q: Can I withdraw earnings?**
A: Yes, via RentMyBrowser dashboard to bank or crypto wallet

**Q: Is my API key secure?**
A: Yes, GitHub Secrets are encrypted and only visible in your workflows

**Q: What happens if node crashes mid-task?**
A: Task fails, no payment. Platform retries with different node

**Q: Can I limit tasks to certain types?**
A: Future feature - currently accepts all within complexity range

**Q: How does failover.sh detect rate limits?**
A: Monitors logs for keywords like "429", "rate.limit", "quota.exceeded", "too.many.requests"

---

## Getting Help

1. **Check SETUP_GUIDE.md** - Most common issues covered
2. **Review logs** - Usually shows the exact error
3. **Discord community** - Ask experienced operators
4. **GitHub Issues** - Report bugs to maintainers
5. **RentMyBrowser Docs** - Official documentation

- Discord: https://discord.com/invite/Ma7GuySQ7h
- GitHub Issues: https://github.com/0xpasho/rent-my-browser/issues
- Docs: https://rentmybrowser.dev/browser-node-setup

---

**Still stuck? Join the Discord and ask the community! 🤝**
