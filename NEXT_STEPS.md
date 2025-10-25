# Next Steps to Run Your App

## ⚡ Quick Start (5 Minutes)

### Step 1: Get SHA Fingerprints
Open terminal in project root and run:
```bash
cd android
gradlew signingReport
```

Look for output like:
```
SHA1: AA:BB:CC:DD:EE:FF:...
SHA-256: 11:22:33:44:55:66:...
```

Copy both values.

### Step 2: Add to Firebase Console
1. Go to https://console.firebase.google.com/
2. Select project: **spin-to-earn-9be46**
3. Click ⚙️ (Settings) → Project settings
4. Scroll to "Your apps" → Android app
5. Click "Add fingerprint" button
6. Paste SHA-1, click Save
7. Click "Add fingerprint" again
8. Paste SHA-256, click Save

### Step 3: Enable Google Sign-In
1. In Firebase Console, click "Authentication" in left menu
2. Click "Sign-in method" tab
3. Click "Google" row
4. Toggle "Enable" switch to ON
5. Select your email as support email
6. Click "Save"

### Step 4: Create Firestore Database
1. In Firebase Console, click "Firestore Database" in left menu
2. Click "Create database" button
3. Select "Start in production mode"
4. Choose location (e.g., asia-south1 for India)
5. Click "Enable"

### Step 5: Set Security Rules
1. In Firestore Database, click "Rules" tab
2. Replace all content with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /referralCodes/{code} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
    }
    match /withdrawalRequests/{requestId} {
      allow read: if request.auth != null && resource.data.uid == request.auth.uid;
      allow create: if request.auth != null;
    }
  }
}
```

3. Click "Publish"

### Step 6: Run the App
```bash
flutter run
```

## 🎮 Testing the App

### Test Scenario 1: First Login
1. Click "Sign in with Google"
2. Select your Google account
3. ✅ You should see Home screen with Spin tab
4. ✅ Check Wallet tab - you should have 1000-3000 points (daily bonus)

### Test Scenario 2: Spinning Wheel
1. Go to Spin tab
2. Click "SPIN NOW!" button
3. ✅ Wheel should spin and stop on a reward
4. ✅ Rewarded ad should show (test ad)
5. ✅ Dialog shows your reward
6. ✅ Balance updates in Wallet tab
7. ✅ Spins left counter decreases

### Test Scenario 3: Withdrawal
1. Go to Wallet tab
2. Click "Withdraw to UPI" button
3. Enter UPI ID: test@upi
4. Enter amount: 10
5. Click Submit
6. ✅ Interstitial ad shows
7. ✅ Success message appears
8. ✅ Check Firebase Console → Firestore → withdrawalRequests collection

### Test Scenario 4: Referral System
1. Go to Profile tab
2. ✅ See your referral code (6 characters)
3. Click copy icon
4. ✅ "Copied to clipboard" message shows
5. Sign out and create new account
6. In new account, go to Profile → Click "Enter Referral Code"
7. Paste the code from first account
8. Click Apply
9. ✅ Both accounts get +20,000 points (₹20)

## 🔍 Verify in Firebase Console

### Check Users Collection
1. Firebase Console → Firestore Database
2. Click "users" collection
3. ✅ You should see your user document with:
   - name, email, uid
   - points (should be > 0)
   - myReferralCode
   - lastLoginDate
   - etc.

### Check Referral Codes Collection
1. Click "referralCodes" collection
2. ✅ You should see document with your referral code as ID
3. ✅ Contains uid field pointing to your user

### Check Withdrawal Requests
1. Click "withdrawalRequests" collection
2. ✅ If you made a withdrawal, you'll see it here
3. ✅ Status should be "pending"

## 📱 Run on Physical Device

### Connect Android Phone
1. Enable Developer Options on phone
2. Enable USB Debugging
3. Connect phone via USB
4. Run: `flutter devices` (should show your phone)
5. Run: `flutter run`

### Run on Emulator
1. Open Android Studio
2. Device Manager → Create Virtual Device
3. Select a device (e.g., Pixel 6)
4. Download system image (API 33 recommended)
5. Start emulator
6. Run: `flutter run`

## 🐛 Troubleshooting

### "Sign-in failed" or "Error 10"
**Problem**: SHA fingerprints not added to Firebase

**Solution**:
1. Make sure you added BOTH SHA-1 and SHA-256
2. Wait 5 minutes for Firebase to update
3. Restart the app

### "Permission denied" in Firestore
**Problem**: Security rules not set

**Solution**:
1. Go to Firestore → Rules tab
2. Copy rules from Step 5 above
3. Click Publish
4. Restart app

### Ads not showing
**Problem**: Test ads take time to load

**Solution**:
1. Wait 30-60 seconds
2. Check internet connection
3. Test ads work in debug mode only initially

### App crashes on startup
**Problem**: Firebase not initialized properly

**Solution**:
1. Check `google-services.json` exists in `android/app/`
2. Run `flutter clean`
3. Run `flutter pub get`
4. Run `flutter run` again

## 📊 Monitor Your App

### Real-time Monitoring
- Firebase Console → Firestore Database (see data updates)
- Firebase Console → Authentication (see user logins)

### Check Logs
```bash
flutter logs
```

## 🎯 What's Working

✅ Google Sign-In authentication
✅ User creation in Firestore
✅ Daily login bonus
✅ Spinning wheel with 5 daily spins
✅ Rewarded ads after spins
✅ Points accumulation
✅ Wallet balance display
✅ UPI withdrawal requests
✅ Referral code generation
✅ Referral code application
✅ ₹20 reward for referrals
✅ Banner ads in Wallet
✅ Interstitial ads after withdrawal
✅ Profile management
✅ Bottom navigation

## 🚀 You're All Set!

Your app is fully functional with:
- 🔐 Firebase Authentication
- 💾 Cloud Firestore database
- 🎰 Spinning wheel game
- 💰 Wallet & withdrawal system
- 👥 Referral program
- 📱 Google Ads integration

**Just complete the 6 steps above and run `flutter run`!**

## 📞 Need Help?

1. Check `README.md` for detailed documentation
2. Check `SETUP_GUIDE.md` for setup instructions
3. Check `IMPLEMENTATION_SUMMARY.md` for technical details
4. Review Firebase Console for data verification
5. Check Flutter logs for error messages

## 🎉 Enjoy Your App!

Once running, you can:
- Spin daily to earn points
- Watch ads for rewards
- Refer friends for bonuses
- Withdraw earnings via UPI
- Track your earnings in real-time

**Happy Spinning! 🎰💰**
