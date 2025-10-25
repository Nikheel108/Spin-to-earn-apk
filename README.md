# Spin to Earn - Flutter App

A comprehensive Flutter application with Firebase Authentication, Firestore, Google Ads, and a referral system. Users can spin a wheel daily to earn points, watch ads for rewards, and withdraw earnings via UPI.

## Features

### 🔐 Authentication
- **Google Sign-In** using Firebase Auth
- Automatic user creation in Firestore on first login
- Daily login bonus (₹1-3 = 1000-3000 points)

### 🎰 Spin Wheel
- Interactive fortune wheel with reward slots (10, 25, 50, 100 points)
- Maximum 5 spins per day (resets daily at midnight)
- Rewarded ads after each spin
- Real-time spin tracking using Firestore

### 💰 Wallet System
- Display total balance (1000 points = ₹1)
- Today's earnings and total earnings tracking
- Withdrawal system with UPI integration
- Minimum withdrawal: ₹10
- Banner ads displayed at the bottom
- Withdrawal requests stored in Firestore with "pending" status

### 👤 Profile & Referral System
- User profile with editable UPI ID
- Unique referral code generation for each user
- One-time referral code usage
- Both referrer and referee earn ₹20 (20,000 points) each
- Referral codes stored in separate Firestore collection
- Copy and share referral codes

### 📱 Bottom Navigation
- **Spin Tab**: Spinning wheel interface
- **Wallet Tab**: Balance and withdrawal management
- **Profile Tab**: User info and referral system

### 📊 Google Ads Integration
- **Rewarded Ads**: After each spin and referral application
- **Banner Ads**: In Wallet screen
- **Interstitial Ads**: Between withdrawal requests
- Test ad units configured (replace with production IDs)

## Tech Stack

- **Flutter SDK**: ^3.9.2
- **Firebase Core**: ^3.8.1
- **Firebase Auth**: ^5.3.3
- **Cloud Firestore**: ^5.5.1
- **Google Sign In**: ^6.2.2
- **Google Mobile Ads**: ^5.2.0
- **Provider**: ^6.1.2 (State Management)
- **Shared Preferences**: ^2.3.3
- **Flutter Fortune Wheel**: ^1.3.1

## Firestore Structure

### Collections

#### `users` Collection
```
{
  uid: string,
  name: string,
  email: string,
  points: number,
  totalEarnings: number,
  todayEarning: number,
  referredBy: string | null,
  myReferralCode: string,
  upiId: string,
  lastLoginDate: timestamp,
  lastSpinDate: timestamp,
  spinsToday: number
}
```

#### `referralCodes` Collection
```
{
  documentId: referralCode (e.g., "ABC123"),
  uid: string
}
```

#### `withdrawalRequests` Collection
```
{
  uid: string,
  upiId: string,
  amount: number,
  status: "pending",
  createdAt: timestamp
}
```

## Setup Instructions

### 1. Prerequisites
- Flutter SDK installed
- Android Studio or VS Code with Flutter extensions
- Firebase project created
- Google Cloud Console project (for Google Sign-In)

### 2. Firebase Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use existing one

2. **Enable Authentication**
   - Go to Authentication → Sign-in method
   - Enable Google Sign-In provider
   - Add your SHA-1 and SHA-256 fingerprints

3. **Enable Firestore**
   - Go to Firestore Database
   - Create database in production mode
   - Set up security rules (see below)

4. **Download google-services.json**
   - Already configured in `android/app/google-services.json`

### 3. Firestore Security Rules

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

### 4. Google Ads Setup

**Important**: The app currently uses test ad unit IDs. For production:

1. Create an AdMob account
2. Register your app
3. Create ad units for:
   - Rewarded Ad
   - Interstitial Ad
   - Banner Ad
4. Replace test IDs in `lib/services/ads_service.dart`
5. Update `AndroidManifest.xml` with your AdMob App ID

### 5. Google Sign-In Configuration

1. **Get SHA-1 and SHA-256 fingerprints**:
   ```bash
   cd android
   ./gradlew signingReport
   ```

2. **Add to Firebase Console**:
   - Project Settings → Your apps → Android app
   - Add SHA-1 and SHA-256 fingerprints

3. **OAuth 2.0 Client ID**:
   - Already configured in `google-services.json`

### 6. Run the App

```bash
# Install dependencies
flutter pub get

# Run on Android device/emulator
flutter run

# Build APK
flutter build apk --release
```

## Project Structure

```
lib/
├── models/
│   └── user_model.dart          # User data model
├── providers/
│   └── user_provider.dart       # State management
├── screens/
│   ├── login_screen.dart        # Google Sign-In screen
│   ├── home_screen.dart         # Bottom navigation
│   ├── spin_screen.dart         # Spinning wheel
│   ├── wallet_screen.dart       # Balance & withdrawal
│   └── profile_screen.dart      # Profile & referral
├── services/
│   ├── auth_service.dart        # Firebase Auth
│   ├── firestore_service.dart   # Firestore operations
│   └── ads_service.dart         # Google Ads
├── firebase_options.dart        # Firebase configuration
└── main.dart                    # App entry point
```

## Key Features Implementation

### Daily Spin Limit
- Tracks `lastSpinDate` and `spinsToday` in Firestore
- Automatically resets at midnight
- UI shows remaining spins

### Daily Login Bonus
- Checks `lastLoginDate` on user login
- Awards random bonus (1000-3000 points) on new day
- Prevents duplicate bonuses on same day

### Referral System
- Generates unique 6-character alphanumeric codes
- Stores mapping in `referralCodes` collection
- One-time usage per user
- Transaction ensures both users receive points atomically

### Points to Currency Conversion
- 1000 points = ₹1
- Displayed throughout the app
- Minimum withdrawal: ₹10 (10,000 points)

## Important Notes

### Production Checklist

- [ ] Replace test AdMob IDs with production IDs
- [ ] Update AdMob App ID in `AndroidManifest.xml`
- [ ] Configure Firestore security rules
- [ ] Add app signing for release builds
- [ ] Test Google Sign-In with production SHA keys
- [ ] Set up withdrawal request processing backend
- [ ] Add error tracking (e.g., Firebase Crashlytics)
- [ ] Implement analytics (e.g., Firebase Analytics)

### Known Limitations

- Google logo asset not included (uses fallback icon)
- Test ad units show test ads only
- Withdrawal requests need manual processing
- No iOS configuration (Android only)

## Troubleshooting

### Google Sign-In Issues
- Verify SHA-1/SHA-256 fingerprints in Firebase Console
- Check `google-services.json` is up to date
- Ensure Google Sign-In is enabled in Firebase Auth

### Ads Not Showing
- Test ads may take time to load
- Check internet connection
- Verify AdMob App ID in `AndroidManifest.xml`

### Firestore Permission Denied
- Check security rules
- Verify user is authenticated
- Ensure UID matches document ID for user updates

## License

This project is for educational purposes.

## Support

For issues or questions, please check the Firebase and Flutter documentation.
