import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  bool _isRewardedAdReady = false;
  bool _isInterstitialAdReady = false;

  // Test Ad Unit IDs - Replace with your actual Ad Unit IDs in production
  String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    }
    return '';
  }

  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
    }
    return '';
  }

  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
    }
    return '';
  }

  // Initialize Mobile Ads SDK
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // Load Rewarded Ad
  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd(); // Load next ad
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  // Show Rewarded Ad
  Future<bool> showRewardedAd() async {
    if (!_isRewardedAdReady || _rewardedAd == null) {
      await loadRewardedAd();
      return false;
    }

    bool rewarded = false;
    
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewarded = true;
      },
    );

    _isRewardedAdReady = false;
    _rewardedAd = null;
    
    return rewarded;
  }

  bool get isRewardedAdReady => _isRewardedAdReady;

  // Load Interstitial Ad
  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Load next ad
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  // Show Interstitial Ad
  Future<void> showInterstitialAd() async {
    if (!_isInterstitialAdReady || _interstitialAd == null) {
      return;
    }

    await _interstitialAd!.show();
    _isInterstitialAdReady = false;
    _interstitialAd = null;
  }

  bool get isInterstitialAdReady => _isInterstitialAdReady;

  // Create Banner Ad
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('BannerAd loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          print('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
  }
}
