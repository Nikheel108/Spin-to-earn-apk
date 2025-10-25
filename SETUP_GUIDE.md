# Quick Setup Guide

## Before Running the App

### 1. Get SHA-1 and SHA-256 Fingerprints

Run this command in the project root:

```bash
cd android
gradlew signingReport
```

Copy the SHA-1 and SHA-256 values from the output.

### 2. Add Fingerprints to Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **spin-to-earn-9be46**
3. Go to **Project Settings** (gear icon)
4. Scroll down to **Your apps** section
5. Click on your Android app
6. Click **Add fingerprint**
7. Paste both SHA-1 and SHA-256 fingerprints

### 3. Enable Google Sign-In in Firebase

1. In Firebase Console, go to **Authentication**
2. Click **Sign-in method** tab
3. Click on **Google** provider
4. Toggle **Enable**
5. Select a support email
6. Click **Save**

### 4. Set Up Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in production mode**
4. Select a location (closest to your users)
5. Click **Enable**

### 5. Configure Firestore Security Rules

In Firestore Database, go to **Rules** tab and paste:

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

Click **Publish**.

### 6. Run the App

```bash
flutter run
```

## Testing the App

### Test User Flow

1. **Login**: Click "Sign in with Google" and authenticate
2. **Daily Bonus**: You'll receive 1000-3000 points on first login
3. **Spin**: Go to Spin tab and spin the wheel (5 spins/day)
4. **Watch Ad**: After each spin, a rewarded ad will show
5. **Wallet**: Check your balance in Wallet tab
6. **Withdraw**: Enter UPI ID and amount (min ₹10) to create withdrawal request
7. **Referral**: Go to Profile tab, copy your referral code
8. **Apply Referral**: Use another account to apply the referral code

### Check Firestore Data

1. Go to Firebase Console → Firestore Database
2. You should see three collections:
   - **users**: Your user data
   - **referralCodes**: Your referral code mapping
   - **withdrawalRequests**: Any withdrawal requests you made

## Common Issues

### "Sign-in failed" Error

**Solution**: Make sure you've added SHA-1 and SHA-256 fingerprints to Firebase Console.

### Ads Not Showing

**Solution**: Test ads may take 30-60 seconds to load on first run. Check your internet connection.

### "Permission denied" in Firestore

**Solution**: Make sure you've published the security rules in Firestore.

## Production Setup (When Ready)

### 1. Replace Test Ad IDs

Edit `lib/services/ads_service.dart` and replace test IDs with your AdMob IDs:

```dart
String get rewardedAdUnitId {
  if (Platform.isAndroid) {
    return 'YOUR_REWARDED_AD_UNIT_ID'; // Replace this
  }
  return '';
}
```

### 2. Update AdMob App ID

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="YOUR_ADMOB_APP_ID"/> <!-- Replace this -->
```

### 3. Generate Release APK

```bash
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## Next Steps

- Test all features thoroughly
- Set up a backend to process withdrawal requests
- Add Firebase Analytics for tracking
- Add Firebase Crashlytics for error reporting
- Implement push notifications for withdrawal status updates
- Add more reward options and gamification features

## Support

If you encounter any issues:
1. Check the main README.md for detailed documentation
2. Verify all Firebase configurations
3. Check Flutter and Firebase documentation
4. Ensure all dependencies are up to date with `flutter pub get`
