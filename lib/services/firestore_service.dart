import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a unique referral code
  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  // Check if user exists and create if not
  Future<UserModel> checkAndCreateUser(String uid, String name, String email) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();

    if (userDoc.exists) {
      // User exists, check if we need to give daily bonus
      UserModel user = UserModel.fromFirestore(userDoc);
      
      final now = DateTime.now();
      final lastLogin = user.lastLoginDate;
      
      // Check if it's a new day
      if (lastLogin == null || 
          (now.year != lastLogin.year || 
           now.month != lastLogin.month || 
           now.day != lastLogin.day)) {
        
        // Give daily bonus (₹1-3 = 1000-3000 points)
        final random = Random();
        final dailyBonus = (random.nextInt(3) + 1) * 1000;
        
        // Reset today's earning and spins
        user = user.copyWith(
          points: user.points + dailyBonus,
          todayEarning: dailyBonus / 1000.0,
          lastLoginDate: now,
          spinsToday: 0,
          lastSpinDate: null,
        );
        
        await _firestore.collection('users').doc(uid).update({
          'points': user.points,
          'todayEarning': user.todayEarning,
          'lastLoginDate': Timestamp.fromDate(now),
          'spinsToday': 0,
          'lastSpinDate': null,
        });
      } else {
        // Same day, just update last login
        await _firestore.collection('users').doc(uid).update({
          'lastLoginDate': Timestamp.fromDate(now),
        });
        user = user.copyWith(lastLoginDate: now);
      }
      
      return user;
    } else {
      // Create new user
      final referralCode = _generateReferralCode();
      
      // Give initial daily bonus (₹1-3 = 1000-3000 points)
      final random = Random();
      final initialBonus = (random.nextInt(3) + 1) * 1000;
      
      final newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        points: initialBonus,
        totalEarnings: initialBonus / 1000.0,
        todayEarning: initialBonus / 1000.0,
        myReferralCode: referralCode,
        lastLoginDate: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(newUser.toFirestore());
      
      // Store referral code mapping
      await _firestore.collection('referralCodes').doc(referralCode).set({
        'uid': uid,
      });

      return newUser;
    }
  }

  // Get user stream
  Stream<UserModel> getUserStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => UserModel.fromFirestore(doc));
  }

  // Update user points after spin
  Future<void> updatePointsAfterSpin(String uid, int points) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final user = UserModel.fromFirestore(userDoc);
    
    final now = DateTime.now();
    final lastSpin = user.lastSpinDate;
    
    int newSpinsToday = user.spinsToday;
    
    // Check if it's a new day
    if (lastSpin == null || 
        (now.year != lastSpin.year || 
         now.month != lastSpin.month || 
         now.day != lastSpin.day)) {
      newSpinsToday = 1;
    } else {
      newSpinsToday = user.spinsToday + 1;
    }
    
    final earnings = points / 1000.0;
    
    await _firestore.collection('users').doc(uid).update({
      'points': user.points + points,
      'totalEarnings': user.totalEarnings + earnings,
      'todayEarning': user.todayEarning + earnings,
      'lastSpinDate': Timestamp.fromDate(now),
      'spinsToday': newSpinsToday,
    });
  }

  // Check if user can spin
  Future<bool> canSpin(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final user = UserModel.fromFirestore(userDoc);
    
    final now = DateTime.now();
    final lastSpin = user.lastSpinDate;
    
    // Check if it's a new day
    if (lastSpin == null || 
        (now.year != lastSpin.year || 
         now.month != lastSpin.month || 
         now.day != lastSpin.day)) {
      return true; // New day, can spin
    }
    
    return user.spinsToday < 5;
  }

  // Get remaining spins
  Future<int> getRemainingSpins(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final user = UserModel.fromFirestore(userDoc);
    
    final now = DateTime.now();
    final lastSpin = user.lastSpinDate;
    
    // Check if it's a new day
    if (lastSpin == null || 
        (now.year != lastSpin.year || 
         now.month != lastSpin.month || 
         now.day != lastSpin.day)) {
      return 5; // New day, 5 spins available
    }
    
    return 5 - user.spinsToday;
  }

  // Update UPI ID
  Future<void> updateUpiId(String uid, String upiId) async {
    await _firestore.collection('users').doc(uid).update({
      'upiId': upiId,
    });
  }

  // Create withdrawal request
  Future<void> createWithdrawalRequest(String uid, String upiId, double amount) async {
    await _firestore.collection('withdrawalRequests').add({
      'uid': uid,
      'upiId': upiId,
      'amount': amount,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });
  }

  // Apply referral code
  Future<String?> applyReferralCode(String uid, String referralCode) async {
    try {
      // Check if user already has a referredBy
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final user = UserModel.fromFirestore(userDoc);
      
      if (user.referredBy != null) {
        return 'You have already used a referral code';
      }
      
      // Check if referral code exists
      final referralDoc = await _firestore.collection('referralCodes').doc(referralCode).get();
      
      if (!referralDoc.exists) {
        return 'Invalid referral code';
      }
      
      final referrerUid = referralDoc.data()!['uid'] as String;
      
      if (referrerUid == uid) {
        return 'You cannot use your own referral code';
      }
      
      // Give 2000 points (₹20) to both users
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(uid);
        final referrerRef = _firestore.collection('users').doc(referrerUid);
        
        final userSnapshot = await transaction.get(userRef);
        final referrerSnapshot = await transaction.get(referrerRef);
        
        final userData = UserModel.fromFirestore(userSnapshot);
        final referrerData = UserModel.fromFirestore(referrerSnapshot);
        
        transaction.update(userRef, {
          'points': userData.points + 20000,
          'totalEarnings': userData.totalEarnings + 20,
          'referredBy': referralCode,
        });
        
        transaction.update(referrerRef, {
          'points': referrerData.points + 20000,
          'totalEarnings': referrerData.totalEarnings + 20,
        });
      });
      
      return null; // Success
    } catch (e) {
      return 'Error applying referral code: $e';
    }
  }

  // Add points from rewarded ad
  Future<void> addRewardedAdPoints(String uid, int points) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final user = UserModel.fromFirestore(userDoc);
    
    final earnings = points / 1000.0;
    
    await _firestore.collection('users').doc(uid).update({
      'points': user.points + points,
      'totalEarnings': user.totalEarnings + earnings,
      'todayEarning': user.todayEarning + earnings,
    });
  }
}
