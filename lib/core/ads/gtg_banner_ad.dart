import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'ads_service.dart';

class GtgBannerAd extends StatefulWidget {
  const GtgBannerAd({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 14),
  });

  final EdgeInsets padding;

  @override
  State<GtgBannerAd> createState() => _GtgBannerAdState();
}

class _GtgBannerAdState extends State<GtgBannerAd> {
  final AdsService _service = AdsService();

  BannerAd? _ad;
  AdSize? _adSize;
  int? _loadedForWidth;
  bool _loading = false;
  bool _failed = false;

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  Future<void> _loadForWidth(int width) async {
    if (!mounted) return;
    if (_loading) return;
    if (_loadedForWidth == width && _ad != null && _adSize != null) return;

    if (!AdConfig.isEnabled) return;

    _loading = true;
    _failed = false;
    _loadedForWidth = width;

    try {
      await _service.ensureInitialized();

      final anchoredSize =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
      if (!mounted) return;
      if (anchoredSize == null) {
        setState(() {
          _failed = true;
          _loading = false;
        });
        return;
      }

      _ad?.dispose();
      _ad = null;
      _adSize = anchoredSize;

      final ad = _service.createBannerAd(
        size: anchoredSize,
        listener: BannerAdListener(
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (!mounted) return;
            setState(() {
              _ad = null;
              _adSize = null;
              _failed = true;
              _loading = false;
            });
          },
          onAdLoaded: (ad) {
            if (!mounted) {
              ad.dispose();
              return;
            }
            setState(() {
              _ad = ad as BannerAd;
              _failed = false;
              _loading = false;
            });
          },
        ),
      );

      ad.load();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _ad = null;
        _adSize = null;
        _failed = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AdConfig.isEnabled) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        if (!maxWidth.isFinite || maxWidth <= 0) {
          return const SizedBox.shrink();
        }

        final resolvedPadding = widget.padding.resolve(
          Directionality.of(context),
        );
        final availableWidth = (maxWidth - resolvedPadding.horizontal).floor();
        if (availableWidth <= 0) {
          return const SizedBox.shrink();
        }

        if (_loadedForWidth != availableWidth && !_loading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _loadForWidth(availableWidth);
          });
        }

        if (_ad == null || _adSize == null || _failed) {
          return const SizedBox.shrink();
        }

        final adWidth = _adSize!.width.toDouble();
        final boundedAdWidth = adWidth > availableWidth
            ? availableWidth.toDouble()
            : adWidth;

        return SafeArea(
          top: false,
          child: Padding(
            padding: widget.padding,
            child: Center(
              child: SizedBox(
                width: boundedAdWidth,
                height: _adSize!.height.toDouble(),
                child: AdWidget(ad: _ad!),
              ),
            ),
          ),
        );
      },
    );
  }
}
