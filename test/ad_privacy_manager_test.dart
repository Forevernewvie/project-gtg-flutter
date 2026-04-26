import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:project_gtg/core/ads/ad_privacy_manager.dart';

class _FakeAdPrivacyClient implements AdPrivacyClient {
  bool canRequestAdsResult;
  bool showFormSucceeds;
  PrivacyOptionsRequirementStatus privacyOptionsStatus;
  int requestUpdateCalls = 0;
  int loadAndShowCalls = 0;
  int showPrivacyOptionsCalls = 0;

  _FakeAdPrivacyClient({
    required this.canRequestAdsResult,
    this.showFormSucceeds = true,
    this.privacyOptionsStatus = PrivacyOptionsRequirementStatus.notRequired,
  });

  @override
  Future<bool> canRequestAds() async => canRequestAdsResult;

  @override
  Future<PrivacyOptionsRequirementStatus>
  getPrivacyOptionsRequirementStatus() async {
    return privacyOptionsStatus;
  }

  @override
  Future<void> loadAndShowConsentFormIfRequired(
    OnConsentFormDismissedListener onConsentFormDismissedListener,
  ) async {
    loadAndShowCalls++;
    onConsentFormDismissedListener(null);
  }

  @override
  void requestConsentInfoUpdate(
    ConsentRequestParameters params,
    OnConsentInfoUpdateSuccessListener successListener,
    OnConsentInfoUpdateFailureListener failureListener,
  ) {
    requestUpdateCalls++;
    successListener();
  }

  @override
  Future<void> showPrivacyOptionsForm(
    OnConsentFormDismissedListener onConsentFormDismissedListener,
  ) async {
    showPrivacyOptionsCalls++;
    onConsentFormDismissedListener(
      showFormSucceeds ? null : FormError(errorCode: 0, message: 'x'),
    );
  }
}

void main() {
  test(
    'prepareForAppLaunch initializes ads only when consent allows it',
    () async {
      var mobileAdsInitCalls = 0;
      final client = _FakeAdPrivacyClient(
        canRequestAdsResult: true,
        privacyOptionsStatus: PrivacyOptionsRequirementStatus.required,
      );
      final manager = AdPrivacyManager(
        client: client,
        initializeMobileAds: () async {
          mobileAdsInitCalls++;
          return InitializationStatus(<String, AdapterStatus>{});
        },
        isAdsEnabled: () => true,
      );

      final canLoadAds = await manager.prepareForAppLaunch();

      expect(canLoadAds, isTrue);
      expect(manager.isMobileAdsInitialized, isTrue);
      expect(mobileAdsInitCalls, 1);
      expect(client.requestUpdateCalls, 1);
      expect(client.loadAndShowCalls, 1);
      expect(manager.privacyOptionsRequiredListenable.value, isTrue);
    },
  );

  test(
    'prepareForAppLaunch keeps privacy options hidden for non-EEA style consent state',
    () async {
      var mobileAdsInitCalls = 0;
      final client = _FakeAdPrivacyClient(
        canRequestAdsResult: true,
        privacyOptionsStatus: PrivacyOptionsRequirementStatus.notRequired,
      );
      final manager = AdPrivacyManager(
        client: client,
        initializeMobileAds: () async {
          mobileAdsInitCalls++;
          return InitializationStatus(<String, AdapterStatus>{});
        },
        isAdsEnabled: () => true,
      );

      final canLoadAds = await manager.prepareForAppLaunch();

      expect(canLoadAds, isTrue);
      expect(manager.isMobileAdsInitialized, isTrue);
      expect(mobileAdsInitCalls, 1);
      expect(manager.privacyOptionsRequiredListenable.value, isFalse);
    },
  );

  test(
    'prepareForAppLaunch skips ads initialization when consent is unavailable',
    () async {
      var mobileAdsInitCalls = 0;
      final client = _FakeAdPrivacyClient(canRequestAdsResult: false);
      final manager = AdPrivacyManager(
        client: client,
        initializeMobileAds: () async {
          mobileAdsInitCalls++;
          return InitializationStatus(<String, AdapterStatus>{});
        },
        isAdsEnabled: () => true,
      );

      final canLoadAds = await manager.prepareForAppLaunch();

      expect(canLoadAds, isFalse);
      expect(manager.isMobileAdsInitialized, isFalse);
      expect(mobileAdsInitCalls, 0);
    },
  );

  test(
    'showPrivacyOptionsForm reports success and keeps requirement updated',
    () async {
      final client = _FakeAdPrivacyClient(
        canRequestAdsResult: true,
        privacyOptionsStatus: PrivacyOptionsRequirementStatus.required,
      );
      final manager = AdPrivacyManager(
        client: client,
        initializeMobileAds: () async =>
            InitializationStatus(<String, AdapterStatus>{}),
        isAdsEnabled: () => true,
      );
      await manager.prepareForAppLaunch();

      final opened = await manager.showPrivacyOptionsForm();

      expect(opened, isTrue);
      expect(client.showPrivacyOptionsCalls, 1);
      expect(manager.privacyOptionsRequiredListenable.value, isTrue);
    },
  );
}
