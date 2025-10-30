# 🚀 HMS Push Kit Testing Guide

## ✅ How to Verify HMS Push Kit is Working

### **Method 1: Check Console Logs** (Easiest)

When you run the app with `flutter run -d R5CT624694Y`, look for these logs:

#### **Success Indicators:**
```
🚀 [HMS PUSH] Starting initialization...
✅ [HMS PUSH] HMS is available
✅ [HMS PUSH] Notification permission granted
✅ [HMS PUSH] Auto-init enabled
🎫 [HMS PUSH] Token received: AQBLdgXMHLOE...
📱 [HMS PUSH] FULL TOKEN: [long token string]
✅ [HMS PUSH] Subscribed to "daily" topic
✅ [HMS PUSH] Initialization complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### **Failure Indicators:**
```
❌ [HMS PUSH] HMS not available on this device
⚠️ [HMS PUSH] Failed to get token: [error]
⚠️ [HMS PUSH] Failed to subscribe: [error]
```

---

### **Method 2: Test Push Notification** (Best Proof)

#### **Option A: Using Huawei Console**

1. Go to: https://developer.huawei.com/consumer/en/console
2. Navigate to: **AppGallery Connect** > **Your Project** > **Push Kit**
3. Click **"Send Message"**
4. Fill in:
   - **Message Type**: Data Message or Notification Message
   - **Target**: Topic ("daily")
   - **Title**: "Test HMS Push"
   - **Body**: "This is a test notification"
5. Click **Send**
6. Check your phone - you should receive the notification!

#### **Option B: Using REST API**

Send a POST request to:
```
POST https://push-api.cloud.huawei.com/v1/[APP_ID]/messages:send
```

With your HMS access token and push token from the logs.

---

### **Method 3: Check HMS Push in AppGallery Connect**

1. Go to: https://developer.huawei.com/consumer/en/console
2. Open your project: **AirAwareApp**
3. Click **Push Kit**
4. Go to **"Statistics"** tab
5. You should see:
   - ✅ Token requests (when app starts)
   - ✅ Subscribed topics ("daily")
   - ✅ Active devices

---

### **Method 4: Test Subscription**

The app automatically subscribes to the **"daily"** topic. To verify:

1. Open AppGallery Connect
2. Go to Push Kit > Topics
3. You should see **"daily"** topic with 1 subscriber (your device)

---

### **Method 5: In-App Verification**

Look for the **FULL TOKEN** in logs - this proves HMS Push is working:

```
📱 [HMS PUSH] FULL TOKEN: AQBLdgXMHLOE3wYDIl7m...
```

Copy this token - you'll need it to send test notifications.

---

## 🎯 What Each Log Means:

| Log | Meaning |
|-----|---------|
| `🚀 Starting initialization` | HMS Push service is starting |
| `✅ HMS is available` | Your device supports HMS |
| `✅ Notification permission granted` | App can show notifications |
| `✅ Auto-init enabled` | Token will auto-refresh |
| `🎫 Token received` | **SUCCESS!** Push Kit is working |
| `✅ Subscribed to "daily"` | Can receive topic notifications |
| `✅ Initialization complete` | **ALL DONE!** |

---

## 🔥 Quick Test (After Running App):

1. **Run the app:**
   ```bash
   flutter run -d R5CT624694Y
   ```

2. **Look for this in logs:**
   ```
   📱 [HMS PUSH] FULL TOKEN: [your token]
   ```

3. **If you see the token = HMS Push is WORKING!** ✅

4. **Send a test notification from Huawei Console**

5. **Check your phone - notification should appear!** 🎉

---

## ❌ Troubleshooting:

### Problem: "HMS not available"
**Solution**: You're running on a non-Huawei device. This is OK - HMS Push only works on Huawei devices or devices with HMS Core installed.

### Problem: "Failed to get token"
**Solution**: 
- Check internet connection
- Verify `agconnect-services.json` is correct
- Check App ID in Huawei Console

### Problem: "No logs appearing"
**Solution**:
- Make sure device is connected via USB
- Run with `flutter run -d R5CT624694Y`
- Check terminal output

---

## 🎓 For Hackathon Judges:

Show them:
1. ✅ The console logs with token
2. ✅ The subscription to "daily" topic
3. ✅ A test notification appearing on your phone
4. ✅ AppGallery Connect statistics showing active push

This proves you're using **HMS Push Kit** successfully! 🏆
