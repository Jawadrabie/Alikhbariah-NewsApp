import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:newsappjs/features/news/presentation/screens/news_details_screen.dart';
import 'package:newsappjs/features/home/data/models/news_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeepLinkService {
  static final DeepLinkService instance = DeepLinkService._internal();
  DeepLinkService._internal();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  void initialize() {
    _appLinks = AppLinks();

    // Check initial link if app was in cold state
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleLink(uri);
      }
    });

    // Handle link when app is in warm state (foreground/background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleLink(uri);
    });
  }

  void _handleLink(Uri uri) async {
    // Example: alikhbariah://news/123
    if (uri.scheme == 'alikhbariah' && uri.host == 'news') {
      final pathSegments = uri.pathSegments;
      // if URI is alikhbariah://news/123, pathSegments might contain '123' or might be just the host? 
      // Actually, if host="news" then path is usually "/123", so pathSegments = ["123"].
      
      final idString = pathSegments.isNotEmpty ? pathSegments.first : null;
      if (idString == null) return;
      
      final newsId = int.tryParse(idString);
      if (newsId == null) return;

      // Fetch news from Supabase and navigate
      try {
        final response = await Supabase.instance.client
            .from('news')
            .select()
            .eq('id', newsId)
            .maybeSingle();

        if (response != null) {
          final news = NewsModel.fromJson(response);
          // Navigate to details natively
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => NewsDetailsScreen(news: news),
            ),
          );
        }
      } catch (e) {
        debugPrint('Deep link fetch Error: $e');
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
