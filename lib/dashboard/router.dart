import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/auth/login_screen.dart';
import 'package:newsappjs/dashboard/models/news.dart';
import 'package:newsappjs/dashboard/models/breaking_news.dart';
import 'package:newsappjs/dashboard/screens/breaking_news/breaking_news_screen.dart';
import 'package:newsappjs/dashboard/screens/breaking_news/edit_breaking_news_screen.dart';
import 'package:newsappjs/dashboard/screens/categories/categories_screen.dart';
import 'package:newsappjs/dashboard/screens/dashboard_screen.dart';
import 'package:newsappjs/dashboard/screens/home/dashboard_home_screen.dart';
import 'package:newsappjs/dashboard/screens/live_stream/live_stream_screen.dart';
import 'package:newsappjs/dashboard/screens/locations/locations_screen.dart';
import 'package:newsappjs/dashboard/screens/main_news/edit_news_screen.dart';
import 'package:newsappjs/dashboard/screens/main_news/main_news_screen.dart';
import 'package:newsappjs/dashboard/screens/manual_notifications/manual_notifications_screen.dart';
import 'package:newsappjs/dashboard/screens/programs/programs_screen.dart';
import 'package:newsappjs/dashboard/screens/settings/settings_screen.dart';
import 'package:newsappjs/dashboard/screens/user_reports/user_reports_screen.dart';
import 'package:newsappjs/dashboard/screens/videos/videos_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRouter {
  static final _supabase = Supabase.instance.client;
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const DashboardLoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return DashboardScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            redirect: (context, state) => '/dashboard/home',
          ),
          GoRoute(
            path: '/dashboard/home',
            builder: (context, state) => const DashboardHomeScreen(),
          ),
          GoRoute(
            path: '/dashboard/main-news',
            builder: (context, state) => const MainNewsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const EditNewsScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                  final news = state.extra as News?;
                  return EditNewsScreen(news: news);
                },
              ),
            ]
          ),
          GoRoute(
            path: '/dashboard/breaking-news',
            builder: (context, state) => const BreakingNewsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const EditBreakingNewsScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                  final breakingNews = state.extra as BreakingNews?;
                  return EditBreakingNewsScreen(breakingNews: breakingNews);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/dashboard/live-stream',
            builder: (context, state) => const LiveStreamScreen(),
          ),
          GoRoute(
            path: '/dashboard/videos',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>?;

              String? asString(dynamic v) {
                if (v == null) return null;
                return v.toString();
              }

              return VideosScreen(
                programId: asString(data?['programId']),
                programName: asString(data?['programName']),
                categoryId: asString(data?['categoryId']),
                categoryName: asString(data?['categoryName']),
              );
            },
          ),
          GoRoute(
            path: '/dashboard/programs',
            builder: (context, state) => const ProgramsScreen(),
          ),
          GoRoute(
            path: '/dashboard/categories',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>?;
              final presetType = data?['presetCategoryType'] as String?;
              return CategoriesScreen(
                autoOpenCreateForm: data?['autoOpenCreateForm'] == true,
                presetCategoryType: presetType,
              );
            },
          ),
          GoRoute(
            path: '/dashboard/locations',
            builder: (context, state) => const LocationsScreen(),
          ),
          GoRoute(
            path: '/dashboard/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/dashboard/manual-notifications',
            builder: (context, state) => const ManualNotificationsScreen(),
          ),
          GoRoute(
            path: '/dashboard/user-reports',
            builder: (context, state) => const UserReportsScreen(),
          ),
        ],
        redirect: (context, state) {
          if (_supabase.auth.currentUser == null) {
            return '/login';
          }
          return null;
        },
      ),
    ],
    redirect: (context, state) {
      final loggedIn = _supabase.auth.currentUser != null;
      if (loggedIn && state.matchedLocation == '/login') {
        return '/dashboard';
      }
      return null;
    },
  );

  static bool isDashboardRoute(String? route) {
    if (!kIsWeb) return false;
    return route?.startsWith('/login') == true ||
        route?.startsWith('/dashboard') == true;
  }
}
