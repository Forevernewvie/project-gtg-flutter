import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

abstract interface class AdPrivacyClient {
  void requestConsentInfoUpdate(
    ConsentRequestParameters params,
    OnConsentInfoUpdateSuccessListener successListener,
    OnConsentInfoUpdateFailureListener failureListener,
  );

  Future<void> loadAndShowConsentFormIfRequired(
    OnConsentFormDismissedListener onConsentFormDismissedListener,
  );

  Future<bool> canRequestAds();

  Future<PrivacyOptionsRequirementStatus> getPrivacyOptionsRequirementStatus();

  Future<void> showPrivacyOptionsForm(
    OnConsentFormDismissedListener onConsentFormDismissedListener,
  );
}

final class GoogleMobileAdsPrivacyClient implements AdPrivacyClient {
  const GoogleMobileAdsPrivacyClient();

  @override
  void requestConsentInfoUpdate(
    ConsentRequestParameters params,
    OnConsentInfoUpdateSuccessListener successListener,
    OnConsentInfoUpdateFailureListener failureListener,
  ) {
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      successListener,
      failureListener,
    );
  }

  @override
  Future<void> loadAndShowConsentFormIfRequired(
    OnConsentFormDismissedListener onConsentFormDismissedListener,
  ) {
    return ConsentForm.loadAndShowConsentFormIfRequired(
      onConsentFormDismissedListener,
    );
  }

  @override
  Future<bool> canRequestAds() => ConsentInformation.instance.canRequestAds();

  @override
  Future<PrivacyOptionsRequirementStatus> getPrivacyOptionsRequirementStatus() {
    return ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
  }

  @override
  Future<void> showPrivacyOptionsForm(
    OnConsentFormDismissedListener onConsentFormDismissedListener,
  ) {
    return ConsentForm.showPrivacyOptionsForm(onConsentFormDismissedListener);
  }
}

class AdPrivacyManager {
  AdPrivacyManager({
    AdPrivacyClient? client,
    Future<InitializationStatus> Function()? initializeMobileAds,
    bool Function()? isAdsEnabled,
  }) : _client = client ?? const GoogleMobileAdsPrivacyClient(),
       _initializeMobileAds =
           initializeMobileAds ?? (() => MobileAds.instance.initialize()),
       _isAdsEnabled = isAdsEnabled ?? (() => AdConfig.isEnabled);

  static final AdPrivacyManager instance = AdPrivacyManager();

  final AdPrivacyClient _client;
  final Future<InitializationStatus> Function() _initializeMobileAds;
  final bool Function() _isAdsEnabled;

  final ValueNotifier<bool> _privacyOptionsRequired = ValueNotifier<bool>(
    false,
  );
  Future<bool>? _prepareFuture;
  Future<void>? _mobileAdsInitFuture;
  bool _mobileAdsInitialized = false;

  ValueListenable<bool> get privacyOptionsRequiredListenable =>
      _privacyOptionsRequired;

  bool get isMobileAdsInitialized => _mobileAdsInitialized;

  Future<bool> prepareForAppLaunch() {
    if (!_isAdsEnabled()) {
      _privacyOptionsRequired.value = false;
      return Future<bool>.value(false);
    }

    _prepareFuture ??= _prepareInternal();
    return _prepareFuture!;
  }

  Future<bool> ensureAdsCanLoad() => prepareForAppLaunch();

  Future<bool> showPrivacyOptionsForm() async {
    if (!_isAdsEnabled()) {
      _privacyOptionsRequired.value = false;
      return false;
    }

    final completer = Completer<bool>();
    await _client.showPrivacyOptionsForm((formError) {
      completer.complete(formError == null);
    });
    await _refreshPrivacyOptionsRequirement();
    return completer.future;
  }

  Future<bool> _prepareInternal() async {
    final updateSucceeded = await _requestConsentInfoUpdate();
    if (updateSucceeded) {
      await _loadAndShowConsentFormIfRequired();
    }

    await _refreshPrivacyOptionsRequirement();

    final canRequestAds = await _client.canRequestAds();
    if (canRequestAds) {
      await _ensureMobileAdsInitialized();
    }
    return canRequestAds;
  }

  Future<bool> _requestConsentInfoUpdate() {
    final completer = Completer<bool>();
    _client.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => completer.complete(true),
      (_) => completer.complete(false),
    );
    return completer.future;
  }

  Future<void> _loadAndShowConsentFormIfRequired() async {
    final completer = Completer<void>();
    await _client.loadAndShowConsentFormIfRequired((_) {
      completer.complete();
    });
    await completer.future;
  }

  Future<void> _ensureMobileAdsInitialized() {
    _mobileAdsInitFuture ??= () async {
      await _initializeMobileAds();
      _mobileAdsInitialized = true;
    }();
    return _mobileAdsInitFuture!;
  }

  Future<void> _refreshPrivacyOptionsRequirement() async {
    try {
      final status = await _client.getPrivacyOptionsRequirementStatus();
      _privacyOptionsRequired.value =
          status == PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      _privacyOptionsRequired.value = false;
    }
  }
}
