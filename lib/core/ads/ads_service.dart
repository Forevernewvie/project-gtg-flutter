import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'ad_privacy_manager.dart';

class AdsService {
  AdsService({AdPrivacyManager? privacyManager})
    : _privacyManager = privacyManager ?? AdPrivacyManager.instance;

  final AdPrivacyManager _privacyManager;

  bool get isEnabled => AdConfig.isEnabled;

  Future<bool> ensureInitialized() {
    if (!isEnabled) return Future<bool>.value(false);
    return _privacyManager.ensureAdsCanLoad();
  }

  BannerAd createBannerAd({required AdSize size, BannerAdListener? listener}) {
    if (!isEnabled) {
      throw StateError(
        'AdsService.createBannerAd called when ads are disabled.',
      );
    }
    if (!_privacyManager.isMobileAdsInitialized) {
      throw StateError(
        'AdsService.createBannerAd called before ensureInitialized().',
      );
    }

    return BannerAd(
      adUnitId: AdConfig.bannerUnitId,
      size: size,
      request: const AdRequest(),
      listener: listener ?? const BannerAdListener(),
    );
  }
}
