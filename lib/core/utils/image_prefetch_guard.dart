import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

class ImagePrefetchGuard {
  ImagePrefetchGuard._();

  static const Duration _urlFailureCooldown = Duration(minutes: 20);
  static const Duration _hostFailureCooldown = Duration(minutes: 5);
  static const int _maxSessionRememberedUrls = 400;

  static final Map<String, DateTime> _urlBlockedUntil = <String, DateTime>{};
  static final Map<String, DateTime> _hostBlockedUntil = <String, DateTime>{};
  static final Set<String> _prefetchedInSession = <String>{};

  static Future<void> warmUrls(
    BuildContext context,
    Iterable<String?> urls, {
    int maxUrls = 6,
  }) async {
    _clearExpiredEntries();

    final effectiveMax = maxUrls.clamp(1, 16);
    final candidates =
        urls
            .whereType<String>()
            .map((url) => url.trim())
            .where((url) => url.isNotEmpty)
            .where(_canAttemptUrl)
            .where((url) => !_prefetchedInSession.contains(url))
            .take(effectiveMax)
            .toList();

    if (candidates.isEmpty) return;

    if (_prefetchedInSession.length > _maxSessionRememberedUrls) {
      _prefetchedInSession.clear();
    }

    for (final url in candidates) {
      _prefetchedInSession.add(url);

      try {
        await precacheImage(
          CachedNetworkImageProvider(url),
          context,
          onError: (error, _) => _registerFailure(url, error),
        );
      } catch (error) {
        _registerFailure(url, error);
      }
    }
  }

  static bool _canAttemptUrl(String url) {
    final now = DateTime.now();

    final blockedUrlUntil = _urlBlockedUntil[url];
    if (blockedUrlUntil != null && blockedUrlUntil.isAfter(now)) {
      return false;
    }

    final host = Uri.tryParse(url)?.host.toLowerCase();
    if (host == null || host.isEmpty) return true;

    final blockedHostUntil = _hostBlockedUntil[host];
    if (blockedHostUntil != null && blockedHostUntil.isAfter(now)) {
      return false;
    }

    return true;
  }

  static void _registerFailure(String url, Object error) {
    final now = DateTime.now();
    final message = error.toString().toLowerCase();

    _urlBlockedUntil[url] = now.add(_urlFailureCooldown);

    final host = Uri.tryParse(url)?.host.toLowerCase();
    if (host == null || host.isEmpty) return;

    if (message.contains('failed host lookup') ||
        message.contains('connection closed') ||
        message.contains('socketexception')) {
      _hostBlockedUntil[host] = now.add(_hostFailureCooldown);
    }
  }

  static void _clearExpiredEntries() {
    final now = DateTime.now();
    _urlBlockedUntil.removeWhere((_, blockedUntil) => !blockedUntil.isAfter(now));
    _hostBlockedUntil.removeWhere((_, blockedUntil) => !blockedUntil.isAfter(now));
  }
}
