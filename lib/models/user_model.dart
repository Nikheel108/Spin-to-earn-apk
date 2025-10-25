import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final int points;
  final double totalEarnings;
  final double todayEarning;
  final String? referredBy;
  final String myReferralCode;
  final String upiId;
  final DateTime? lastLoginDate;
  final DateTime? lastSpinDate;
  final int spinsToday;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.points = 0,
    this.totalEarnings = 0,
    this.todayEarning = 0,
    this.referredBy,
    required this.myReferralCode,
    this.upiId = '_',
    this.lastLoginDate,
    this.lastSpinDate,
    this.spinsToday = 0,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      points: data['points'] ?? 0,
      totalEarnings: (data['totalEarnings'] ?? 0).toDouble(),
      todayEarning: (data['todayEarning'] ?? 0).toDouble(),
      referredBy: data['referredBy'],
      myReferralCode: data['myReferralCode'] ?? '',
      upiId: data['upiId'] ?? '_',
      lastLoginDate: data['lastLoginDate'] != null
          ? (data['lastLoginDate'] as Timestamp).toDate()
          : null,
      lastSpinDate: data['lastSpinDate'] != null
          ? (data['lastSpinDate'] as Timestamp).toDate()
          : null,
      spinsToday: data['spinsToday'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'uid': uid,
      'points': points,
      'totalEarnings': totalEarnings,
      'todayEarning': todayEarning,
      'referredBy': referredBy,
      'myReferralCode': myReferralCode,
      'upiId': upiId,
      'lastLoginDate': lastLoginDate != null ? Timestamp.fromDate(lastLoginDate!) : null,
      'lastSpinDate': lastSpinDate != null ? Timestamp.fromDate(lastSpinDate!) : null,
      'spinsToday': spinsToday,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? points,
    double? totalEarnings,
    double? todayEarning,
    String? referredBy,
    String? myReferralCode,
    String? upiId,
    DateTime? lastLoginDate,
    DateTime? lastSpinDate,
    int? spinsToday,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      points: points ?? this.points,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      todayEarning: todayEarning ?? this.todayEarning,
      referredBy: referredBy ?? this.referredBy,
      myReferralCode: myReferralCode ?? this.myReferralCode,
      upiId: upiId ?? this.upiId,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      lastSpinDate: lastSpinDate ?? this.lastSpinDate,
      spinsToday: spinsToday ?? this.spinsToday,
    );
  }
}
