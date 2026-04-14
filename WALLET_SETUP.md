# 💰 MetaMask Wallet Setup for Earnings

Your rentmybrowser node is now configured to accept your MetaMask wallet address for earnings. Follow these steps to connect it.

## Step 1: Get Your MetaMask Address

1. **Open MetaMask** in your browser
2. Click your **account icon** (top right of MetaMask popup)
3. Click **"Copy address to clipboard"**
4. Your address will look like: `0x1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b`

## Step 2: Add Address to GitHub Secrets

**Option A: Using Command Line (Recommended)**

```powershell
# Copy and paste this with YOUR address (replace the example)
gh secret set RMB_WALLET_ADDRESS --body "0x1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b"
```

**Option B: Using GitHub Web Interface**

1. Go to: https://github.com/Arnav1771/rentmybrowser/settings/secrets/actions
2. Click **"New repository secret"**
3. **Name:** `RMB_WALLET_ADDRESS`
4. **Value:** Paste your MetaMask address (0x...)
5. Click **"Add secret"**

## Step 3: Verify It Was Added

```powershell
cd c:\Users\Bhargava\Documents\rentmybrowser
gh secret list
```

You should see `RMB_WALLET_ADDRESS` in the output.

## Step 4: Test (Optional)

Trigger a manual workflow run to verify your wallet is being used:

```powershell
gh workflow run browser-node.yml
```

Then check the logs after ~5 minutes:

```powershell
gh run view --job=<JOB_ID> --log | Select-String "RMB_WALLET_ADDRESS"
```

You should see confirmed status like:
```
🔍 DEBUG: RMB_WALLET_ADDRESS set = YES (0x1a2b3c4d...)
```

## Step 5: Monitor Earnings

Once your wallet is set up, all earnings will be sent to your MetaMask address. Check:
- **Dashboard:** https://rentmybrowser.dev/dashboard
- **MetaMask:** Your wallet should show incoming transactions

## Troubleshooting

**Q: What if I don't add a wallet address?**
A: The system will auto-generate one each run. Earnings still work, but you won't have direct access to the wallet's private key.

**Q: Can I change my wallet address later?**
A: Yes, just run `gh secret set RMB_WALLET_ADDRESS --body "0xNewAddressHere"` to update it.

**Q: What network is rent-my-browser on?**
A: Check the documentation at https://rentmybrowser.dev/api-docs for the current network (Ethereum, Polygon, etc.).

---

**That's it!** Your node will now route earnings to your MetaMask wallet starting with the next workflow run.
