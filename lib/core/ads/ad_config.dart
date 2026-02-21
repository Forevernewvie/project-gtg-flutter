import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

import '../env.dart';

abstract final class AdConfig {
  // Banner only (MVP). Real IDs must be injected at build time for release.
  static const String testBannerUnitIdAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testBannerUnitIdIos =
      'ca-app-pub-3940256099942544/2934735716';

  static const bool adsEnabled = bool.fromEnvironment(
    'ADS_ENABLED',
    defaultValue: false,
  );

  static const String bannerUnitIdAndroid = String.fromEnvironment(
    'ADMOB_BANNER_AD_UNIT_ID_ANDROID',
    defaultValue: testBannerUnitIdAndroid,
  );

  static const String bannerUnitIdIos = String.fromEnvironment(
    'ADMOB_BANNER_AD_UNIT_ID_IOS',
    defaultValue: testBannerUnitIdIos,
  );

  static bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// We only ship ads on Android for the Play Store MVP.
  static bool get isEnabled {
    if (!adsEnabled) return false;
    if (Env.useFakes) return false; // no SDK init during tests/smoke.
    if (!isSupportedPlatform) return false;
    if (!Platform.isAndroid) return false;
    return true;
  }

  static String get bannerUnitId {
    if (Platform.isIOS) return bannerUnitIdIos;
    return bannerUnitIdAndroid;
  }
}
