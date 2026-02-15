import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

class AdsService {
  bool _initialized = false;
  Future<void>? _initFuture;

  bool get isEnabled => AdConfig.isEnabled;

  Future<void> ensureInitialized() {
    if (!isEnabled) return Future.value();

    _initFuture ??= () async {
      await MobileAds.instance.initialize();
      _initialized = true;
    }();

    return _initFuture!;
  }

  BannerAd createBannerAd({
    required AdSize size,
    BannerAdListener? listener,
  }) {
    if (!isEnabled) {
      throw StateError('AdsService.createBannerAd called when ads are disabled.');
    }
    if (!_initialized) {
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

