import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/ads_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final AdsService _adsService = AdsService();
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = _adsService.createBannerAd();
    _bannerAd!.load().then((_) {
      setState(() {
        _isBannerAdLoaded = true;
      });
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _showWithdrawDialog() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) return;

    final balance = user.points / 1000.0;

    if (balance < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum withdrawal amount is ₹10'),
        ),
      );
      return;
    }

    final upiController = TextEditingController(text: user.upiId != '_' ? user.upiId : '');
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Withdraw Funds'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Balance: ₹${balance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: upiController,
                decoration: const InputDecoration(
                  labelText: 'UPI ID',
                  hintText: 'example@upi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  hintText: 'Min ₹10',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Note: Minimum withdrawal is ₹10',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final upiId = upiController.text.trim();
              final amountText = amountController.text.trim();

              if (upiId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter UPI ID')),
                );
                return;
              }

              if (amountText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter amount')),
                );
                return;
              }

              final amount = double.tryParse(amountText);
              if (amount == null || amount < 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Minimum withdrawal is ₹10')),
                );
                return;
              }

              if (amount > balance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Insufficient balance')),
                );
                return;
              }

              // Update UPI ID if changed
              if (upiId != user.upiId) {
                await userProvider.updateUpiId(upiId);
              }

              // Create withdrawal request
              await userProvider.createWithdrawalRequest(upiId, amount);

              if (context.mounted) {
                Navigator.of(context).pop();
                
                // Show interstitial ad
                await _adsService.showInterstitialAd();
                _adsService.loadInterstitialAd();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Withdrawal request submitted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    final balance = (user?.points ?? 0) / 1000.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.purple.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
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
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Balance Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Total Balance',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '₹${balance.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${user?.points ?? 0} Points',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Earnings Info
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              'Today\'s Earning',
                              '₹${(user?.todayEarning ?? 0).toStringAsFixed(2)}',
                              Icons.today,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              'Total Earnings',
                              '₹${(user?.totalEarnings ?? 0).toStringAsFixed(2)}',
                              Icons.account_balance_wallet,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Withdraw Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: balance >= 10 ? _showWithdrawDialog : null,
                          icon: const Icon(Icons.account_balance),
                          label: const Text(
                            'Withdraw to UPI',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      if (balance < 10)
                        const Text(
                          'Minimum withdrawal amount is ₹10',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      
                      const SizedBox(height: 30),
                      
                      // Info Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How to Earn More:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            InfoItem(text: '• Spin the wheel daily (5 spins/day)'),
                            InfoItem(text: '• Watch rewarded ads'),
                            InfoItem(text: '• Refer friends and earn ₹20 each'),
                            InfoItem(text: '• Get daily login bonus'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Banner Ad
          if (_isBannerAdLoaded && _bannerAd != null)
            Container(
              color: Colors.white,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final String text;

  const InfoItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }
}
