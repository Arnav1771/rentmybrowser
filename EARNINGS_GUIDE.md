# 💰 Earnings & Analytics Guide

## Understanding Your Earnings

### Task Pricing Model

| Type | Complexity | Credits | USD | Fixed? |
|------|-----------|---------|-----|--------|
| Headless | Simple | 5 | $0.05 | ✅ |
| Headless | Adversarial | 10 | $0.10 | ✅ |
| Real | Simple | 10 | $0.10 | ✅ |
| Real | Adversarial | 15 | $0.15 | ✅ |

**What you earn: 80% of task cost**

| Task Type | Your Revenue |
|-----------|--------------|
| Headless Simple | $0.04 |
| Headless Adversarial | $0.08 |
| Real Simple | $0.08 |
| Real Adversarial | $0.12 |

**Average:** Expected ~$5-50/day depending on task volume

---

## Estimating Your Earnings

### Factor 1: Task Volume
- **Low demand days:** 5-10 tasks (50-60 minutes of work) = $0.40-$1.20
- **Normal days:** 20-50 tasks (2-4 hours of work) = $1.60-$6.00
- **High demand days:** 100+ tasks (8+ hours of work) = $8-$15+

### Factor 2: Task Mix
Your earnings vary based on task types accepted:

```
Scenario A: Mostly simple tasks
100 tasks × $0.08 (avg) = $8/day

Scenario B: 50/50 mix
50 simple × $0.08 = $4.00
50 complex × $0.12 = $6.00
Total = $10/day

Scenario C: Mostly complex
100 complex × $0.12 = $12/day
```

### Factor 3: Model Efficiency
- **Fast models (2.5/2.0-flash):** Higher throughput = more tasks completed
- **Slow models (1.5-pro):** Fewer tasks but same earnings per task
- **Your node balances:** Switches models intelligently to maximize uptime

---

## Monitoring Dashboard

### Daily Check

Visit https://rentmybrowser.dev/dashboard after signing in:

1. **Node Status:**
   - ✅ Shows "Online" or ❌ "Offline"
   - Shows uptime percentage
   - Current model (if using multiple)

2. **Today's Earnings:**
   - Tasks completed (count)
   - Total credits earned
   - Total USD earned ($)
   - Average time per task

3. **Performance Metrics:**
   - Success rate (% of tasks completed successfully)
   - Average task duration
   - Tasks completed this session

### Weekly Review

Track these metrics weekly:

```
Week of April 7-13:
├─ Total tasks: 287
├─ Total earnings: $23.04 (avg $3.29/day)
├─ Best day: Tuesday $4.52 (48 tasks)
├─ Worst day: Sunday $1.20 (12 tasks)
├─ Average per task: $0.080
├─ Uptime: 99.2%
└─ Model preference: 60% flash, 40% pro
```

---

## Maximizing Earnings

### Strategy 1: 24/7 Uptime

**Goal:** Run continuously to never miss tasks

```
Setup auto-restart workflow:
├─ Primary workflow runs 5h 45m
├─ Auto-restart workflow detects completion
├─ Immediately re-triggers primary
└─ Result: ~continuous operation
```

**Expected gain:** +$50-100/week

**Setup:** See SETUP_GUIDE.md "Advanced: Auto-Restart"

---

### Strategy 2: Multiple Nodes

**Goal:** Run more parallel browsers, earn more simultaneously

```
Node 1 (rentmybrowser-node):
├─ Gemini API Key A
└─ Running on GitHub Actions

Node 2 (rentmybrowser-node-2):
├─ Gemini API Key B (different project)
└─ Running on GitHub Actions

Node 3 (personal-computer):
├─ Runs locally during off hours
└─ Same API Key as Node 1 (or separate)
```

**Expected gain:** 2x earnings = $20-100/week

**Setup:** Duplicate repository, add different secrets

---

### Strategy 3: Task Selection

Some nodes allow task filtering (future feature):

```
Ideal: Only accept high-value tasks
├─ Real Adversarial ($0.12 each)
├─ Reject Headless Simple ($0.04)
└─ Result: Higher average earnings per task
```

**Expected gain:** +$2-5/day (25% improvement)

---

### Strategy 4: Off-Peak Optimization

Monitor task volume patterns:

```
Peak hours (more competition):
├─ 9am-5pm (US business hours)
├─ More tasks but also more nodes
└─ Harder to get high-value tasks

Off-peak hours (less competition):
├─ 6pm-8am (US business hours)
├─ Fewer tasks but easier to get complex ones
└─ Higher success rate
```

**Action:** Enable schedule for off-peak times if using cron

---

## Revenue Tracking

### Set Up Analytics Spreadsheet

Track daily earnings to identify trends:

```
Date | Online Time | Tasks | Earnings | Model | Notes
-----|-------------|-------|----------|-------|------
4/7  | 5h 45m     | 28    | $2.20    | flash | First day
4/8  | Offline    | -     | $0.00    | -     | Issue
4/9  | 5h 45m     | 42    | $3.36    | mix   | Good day
4/10 | 5h 45m     | 35    | $2.80    | flash | Busy
```

### Month-End Summary

After running for a month:

```
April Summary:
├─ Total tasks: 895
├─ Total earned: $71.60
├─ Daily average: $2.39
├─ Monthly projection: $71.60
├─ Most profitable day: April 10 ($4.20)
├─ Least profitable: April 2 ($0.00)
├─ Avg time online: 5.7 hours/day
└─ Earnings per online hour: $0.41/hr
```

---

## Dashboard Deep Dive

### Task Breakdown View

See what types of tasks you're getting:

| Task Type | Count | Revenue | % of Total |
|-----------|-------|---------|-----------|
| Headless Simple | 150 | $6.00 | 20% |
| Headless Adv | 120 | $9.60 | 28% |
| Real Simple | 80 | $6.40 | 22% |
| Real Adversarial | 100 | $12.00 | 30% |
| **TOTAL** | **450** | **$34.00** | **100%** |

**Insight:** Mostly getting complex tasks = good! High average value.

### Success Rate Monitoring

```
Dashboard shows: 98.5% success rate

This means:
├─ 450 tasks attempted
├─ 443 completed successfully
├─ 7 failed (node crashed, lost connection, etc.)
└─ Result: Minimal lost revenue
```

**Target:** Keep above 98% success

---

## Earnings Forecast

### Conservative Estimate (Part-Time)

```
Run 4h/day average:
├─ 20 tasks/day × $0.08 = $1.60/day
├─ 7 days/week = $11.20/week
└─ 30 days/month = $48/month
```

### Moderate Estimate (Near 24/7)

```
Run 20h/day average:
├─ 100 tasks/day × $0.08 = $8/day
├─ 7 days/week = $56/week
└─ 30 days/month = $240/month
```

### Optimistic Estimate (24/7 + Multiple Nodes)

```
Run 24h/day × 2 nodes:
├─ 200 tasks/day × $0.08 = $16/day
├─ 7 days/week = $112/week
└─ 30 days/month = $480/month
```

**Reality:** Probably between conservative and moderate = $50-200/month

---

## Troubleshooting Low Earnings

### Low Daily Total?

**Diagnostic:**
```
Check: Tasks per day
├─ < 10 tasks/day = No tasks available
├─ 10-50 tasks/day = Normal
└─ > 50 tasks/day = Great!

Check: Node uptime
├─ < 50% = Too much downtime, increase uptime
├─ 50-90% = Good
└─ > 90% = Excellent
```

**Solutions:**
1. Increase uptime (auto-restart workflow)
2. Run multiple nodes
3. Wait for higher demand periods
4. Join Discord for tips from top node operators

---

### Low Revenue Per Task?

**Check: Task mix**
```
Dashboard shows mostly simple tasks?
└─ Not ideal, but nothing you can control

Dashboard shows mostly complex tasks?
└─ Perfect! Earnings are optimal
```

**Note:** Task types are assigned by platform based on your node specs

---

### Node Frequently Offline?

**Common causes:**
1. Workflow crashes (check logs)
2. API key invalid (test it)
3. No auto-restart enabled (see SETUP_GUIDE.md)
4. Manual intervention needed (see TROUBLESHOOTING.md)

---

## Withdrawal & Payouts

### Check Your Balance

1. Visit https://rentmybrowser.dev/dashboard
2. Look for "Balance" section
3. Shows: Total USD earned and available to withdraw

### Request Withdrawal

1. Click "Withdraw" button
2. Choose payment method:
   - Bank transfer (US)
   - PayPal
   - Cryptocurrency (USDC on Base)
3. Enter amount
4. Confirm details
5. Processing time: 1-3 business days

### Minimum Withdrawal

Typically: $5 or $10 minimum

---

## Tax Considerations ⚠️

You may need to report earnings as income.

**Recommended:**
- Keep track of monthly earnings
- Save earnings reports from dashboard
- Consult tax professional about reporting requirements
- Different by country/region

---

## Support & Resources

**Dashboard Issues:**
- Earnings not showing? = 10-15 minute delay after task completion
- Numbers seem wrong? = Check timezone (usually UTC)
- Need withdrawal help? = Contact support@rentmybrowser.dev

**Community:**
- Discord: https://discord.com/invite/Ma7GuySQ7h
- Compare earnings with other node operators
- Share optimization strategies

---

**Happy earning! Track your progress and optimize over time. 🚀💰**
