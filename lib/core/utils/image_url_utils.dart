Uri? _parseUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null) return null;
  if (!uri.hasScheme || uri.host.isEmpty) return null;
  return uri;
}

String _fallbackSeedFromUrl(Uri uri) {
  final path = uri.pathSegments.where((segment) => segment.isNotEmpty).join('-');
  if (path.isNotEmpty) {
    return Uri.encodeComponent(path);
  }

  return Uri.encodeComponent(uri.host);
}

String _buildStableFallbackUrl(Uri source, int width) {
  final safeWidth = width.clamp(320, 1600);
  final safeHeight = (safeWidth * 2 / 3).round();
  final seed = _fallbackSeedFromUrl(source);
  return 'https://picsum.photos/seed/$seed/$safeWidth/$safeHeight';
}

String? normalizeRemoteImageUrl(
  String? url, {
  int width = 1200,
  int quality = 80,
}) {
  if (url == null) return null;

  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;

  final uri = _parseUrl(trimmed);
  if (uri == null) return trimmed;

  final host = uri.host.toLowerCase();
  if (!host.contains('images.unsplash.com')) {
    return trimmed;
  }

  // Unsplash IDs in seeded/demo data may expire and return 404.
  // Use a deterministic, cache-friendly fallback source to keep UX stable.
  final useStableFallback = uri.path.contains('/photo-') || uri.path.contains('photo-');
  if (useStableFallback) {
    return _buildStableFallbackUrl(uri, width);
  }

  final current = Map<String, String>.from(uri.queryParameters);
  current.putIfAbsent('auto', () => 'format');
  current.putIfAbsent('fit', () => 'crop');
  current.putIfAbsent('w', () => '$width');
  current.putIfAbsent('q', () => '$quality');
  return uri.replace(queryParameters: current).toString();
}
