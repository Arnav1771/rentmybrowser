# ✅ Setup Verification Checklist

Use this checklist to verify everything is working before you start earning.

---

## Phase 1: Prerequisites ✓

- [ ] GitHub Account (preferably Pro for better compute quota)
- [ ] Gemini API Key (get at https://aistudio.google.com/app/apikeys)
- [ ] GitHub CLI installed (`gh --version` should work)
- [ ] Git installed (`git --version` should work)
- [ ] This directory cloned or created locally

---

## Phase 2: Repository Setup ✓

- [ ] Repository created on GitHub (private)
- [ ] Code pushed to GitHub
- [ ] Repository URL set:
  ```bash
  git remote -v
  # Should show your repository URL
  ```

---

## Phase 3: Secrets Configuration ✓

- [ ] GEMINI_API_KEY secret added to GitHub:
  ```bash
  gh secret list
  # Should show: GEMINI_API_KEY
  ```

- [ ] Secret is valid (test on https://aistudio.google.com/app/usage)

---

## Phase 4: Workflow Execution ✓

- [ ] Workflow triggered:
  ```bash
  gh workflow run browser-node.yml
  # Or via GitHub Actions UI
  ```

- [ ] Workflow shows in Actions tab:
  ```
  https://github.com/YOUR_USERNAME/rentmybrowser-node/actions
  ```

- [ ] Latest run shows "in progress" or "completed"

---

## Phase 5: Node Verification ✓

- [ ] Workflow runs for 5+ minutes (check logs)
- [ ] No errors in logs related to API key:
  ```bash
  gh run view --log | grep -i "error"
  ```

- [ ] Node goes online (wait 2-3 minutes, then check):
  ```
  https://rentmybrowser.dev/dashboard
  ```

---

## Phase 6: Earnings Verification ✓

- [ ] Node appears "online" on dashboard
- [ ] First task accepted (may take 5-10 minutes)
- [ ] Dashboard shows earnings (even if $0.01)

---

## Phase 7: Monitoring Setup ✓

- [ ] Bookmarked dashboard: https://rentmybrowser.dev/dashboard
- [ ] Bookmarked actions page: https://github.com/YOUR_USERNAME/rentmybrowser-node/actions
- [ ] Read TROUBLESHOOTING.md for common issues
- [ ] Joined Discord for support: https://discord.com/invite/Ma7GuySQ7h

---

## Troubleshooting Checks

If something isn't working, verify:

### Workflow won't start
```bash
# Check authentication
gh auth status

# Check repository
gh repo view

# Try trigger manually
gh workflow run browser-node.yml
```

### Secret not found error
```bash
# Verify secret exists
gh secret list

# Verify name is exactly: GEMINI_API_KEY
```

### Node won't go online
```bash
# Wait 2-3 minutes (registration takes time)

# Check logs for errors
gh run view --log | tail -50

# Verify API key is valid on:
https://aistudio.google.com/app/usage
```

### API key rejected
```bash
# Regenerate API key
https://aistudio.google.com/app/apikeys

# Update secret
gh secret set GEMINI_API_KEY --body "NEW_KEY"

# Re-trigger workflow
gh workflow run browser-node.yml
```

---

## Expected Timeline

| Time | Status | Action |
|------|--------|--------|
| T+0:00 | Workflow starts | Check Actions tab |
| T+1:00 | Setup complete | Check logs for errors |
| T+2:00 | Node registering | Wait for heartbeat |
| T+3:00 | Node online | Check dashboard |
| T+5:00 | First task | May receive first task |
| T+10:00 | Earnings | Should see $0.04+ earned |

---

## Success Criteria

Your setup is working if:

✅ **Workflow Running:** Latest run in Actions tab shows recent completion time (within last hour)

✅ **Node Online:** Dashboard shows your node with "online" status

✅ **Receiving Tasks:** Dashboard shows 1+ tasks completed

✅ **Earning Revenue:** Dashboard shows earnings > $0.00

✅ **Logs Clean:** No critical errors in workflow logs

---

## Common Blockers & Fixes

| Blocker | Check | Fix |
|---------|-------|-----|
| No Tasks | Wait 3+ min | Node may still be registering |
| Tasks Failing | Check logs | API key may be invalid |
| Node Offline | Check API usage | May have hit rate limit |
| Workflow Timeout | Check logs | Tasks taking too long |
| Low Earnings | Check task count | Normal - wait for more volume |

---

## Next Steps After Verification

Once all checks pass (✅):

1. **First Week:**
   - Monitor daily
   - Track earnings
   - Check logs for patterns

2. **Second Week:**
   - Enable auto-restart (optional, see SETUP_GUIDE.md)
   - Consider running locally too
   - Share setup with friends

3. **Ongoing:**
   - Monitor earnings trends
   - Optimize models
   - Consider second node if profitable

---

## Document Reference

| Need | Document |
|------|----------|
| Setup help | SETUP_GUIDE.md |
| Quick setup | QUICK_START.md |
| Troubleshooting | TROUBLESHOOTING.md |
| Earnings info | EARNINGS_GUIDE.md |
| Technical details | method.md |
| Full index | INDEX.md |

---

## Support Resources

- **Questions:** Read the relevant document above
- **Common Issues:** TROUBLESHOOTING.md
- **Community:** https://discord.com/invite/Ma7GuySQ7h
- **Docs:** https://rentmybrowser.dev/browser-node-setup
- **GitHub Issues:** https://github.com/0xpasho/rent-my-browser/issues

---

**All checks passed? Congratulations! You're now an earning node operator! 🎉**
