import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  Future<void> loadUser(String uid) async {
    _firestoreService.getUserStream(uid).listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> updateUpiId(String upiId) async {
    if (_user != null) {
      await _firestoreService.updateUpiId(_user!.uid, upiId);
    }
  }

  Future<void> createWithdrawalRequest(String upiId, double amount) async {
    if (_user != null) {
      await _firestoreService.createWithdrawalRequest(_user!.uid, upiId, amount);
    }
  }

  Future<String?> applyReferralCode(String referralCode) async {
    if (_user != null) {
      return await _firestoreService.applyReferralCode(_user!.uid, referralCode);
    }
    return 'User not found';
  }
}
