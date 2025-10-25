import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';
import '../services/ads_service.dart';

class SpinScreen extends StatefulWidget {
  const SpinScreen({super.key});

  @override
  State<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends State<SpinScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AdsService _adsService = AdsService();
  final StreamController<int> _controller = StreamController<int>();
  
  final List<int> _rewards = [10, 25, 50, 100, 10, 25, 50, 100];
  bool _isSpinning = false;
  int _remainingSpins = 5;

  @override
  void initState() {
    super.initState();
    _loadRemainingSpins();
    _adsService.loadRewardedAd();
  }

  Future<void> _loadRemainingSpins() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null) {
      final remaining = await _firestoreService.getRemainingSpins(userProvider.user!.uid);
      setState(() {
        _remainingSpins = remaining;
      });
    }
  }

  Future<void> _spin() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user == null) return;

    // Check if user can spin
    final canSpin = await _firestoreService.canSpin(userProvider.user!.uid);
    if (!canSpin) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have reached your daily spin limit!')),
        );
      }
      return;
    }

    setState(() {
      _isSpinning = true;
    });

    // Random reward index
    final random = Random();
    final selectedIndex = random.nextInt(_rewards.length);
    final selectedReward = _rewards[selectedIndex];

    // Spin the wheel
    _controller.add(selectedIndex);

    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 4));

    // Show rewarded ad
    final adShown = await _adsService.showRewardedAd();
    
    // Update points in Firestore
    await _firestoreService.updatePointsAfterSpin(
      userProvider.user!.uid,
      selectedReward,
    );

    // Reload remaining spins
    await _loadRemainingSpins();

    setState(() {
      _isSpinning = false;
    });

    // Show result dialog
    if (mounted) {
      _showRewardDialog(selectedReward);
    }

    // Load next rewarded ad
    _adsService.loadRewardedAd();
  }

  void _showRewardDialog(int reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 30),
            SizedBox(width: 10),
            Text('Congratulations!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You won',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              '$reward Points',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '₹${(reward / 1000).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spin to Earn'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.purple.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade700,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // User info card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Your Balance',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${user?.points ?? 0} pts',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        Text(
                          '₹${((user?.points ?? 0) / 1000).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.grey.shade300,
                    ),
                    Column(
                      children: [
                        const Text(
                          'Spins Left',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$_remainingSpins/5',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Fortune Wheel
              Expanded(
                child: Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: FortuneWheel(
                      selected: _controller.stream,
                      animateFirst: false,
                      items: _rewards.map((reward) {
                        return FortuneItem(
                          child: Text(
                            '$reward',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: FortuneItemStyle(
                            color: _getColorForReward(reward),
                            borderColor: Colors.white,
                            borderWidth: 2,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Spin Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: _isSpinning || _remainingSpins <= 0 ? null : _spin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    minimumSize: const Size(double.infinity, 60),
                  ),
                  child: _isSpinning
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
                          'SPIN NOW!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Info text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Watch a rewarded ad after each spin to claim your reward!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForReward(int reward) {
    switch (reward) {
      case 10:
        return Colors.blue.shade600;
      case 25:
        return Colors.green.shade600;
      case 50:
        return Colors.orange.shade600;
      case 100:
        return Colors.red.shade600;
      default:
        return Colors.purple.shade600;
    }
  }
}
