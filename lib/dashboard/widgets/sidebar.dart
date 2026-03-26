import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);
    final currentRoute = GoRouterState.of(context).uri.toString();
    final scheme = Theme.of(context).colorScheme;

    // Helper to check active route
    bool isActive(String route) {
      if (route == '/dashboard/home') {
        return currentRoute == route;
      }
      return currentRoute.startsWith(route);
    }

    return Container(
      width: 250,
      color: scheme.surfaceContainerHigh,
      child: Column(
        children: [
          _buildHeader(context, t),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(
                  context,
                  'home',
                  Icons.dashboard,
                  '/dashboard/home',
                  isActive('/dashboard/home'),
                ),
                _buildNavItem(
                  context,
                  'main_news',
                  Icons.article,
                  '/dashboard/main-news',
                  isActive('/dashboard/main-news'),
                ),
                _buildNavItem(
                  context,
                  'breaking_news',
                  Icons.new_releases,
                  '/dashboard/breaking-news',
                  isActive('/dashboard/breaking-news'),
                ),
                _buildNavItem(
                  context,
                  'live_stream',
                  Icons.live_tv,
                  '/dashboard/live-stream',
                  isActive('/dashboard/live-stream'),
                ),
                _buildNavItem(
                  context,
                  'videos',
                  Icons.video_library,
                  '/dashboard/videos',
                  isActive('/dashboard/videos'),
                ),
                _buildNavItem(
                  context,
                  'programs',
                  Icons.video_collection,
                  '/dashboard/programs',
                  isActive('/dashboard/programs'),
                ),
                _buildNavItem(
                  context,
                  'categories',
                  Icons.category,
                  '/dashboard/categories',
                  isActive('/dashboard/categories'),
                ),
                _buildNavItem(
                  context,
                  'locations',
                  Icons.location_on,
                  '/dashboard/locations',
                  isActive('/dashboard/locations'),
                ),
                Divider(color: scheme.outlineVariant, height: 32),
                _buildNavItem(
                  context,
                  'manual_notifications',
                  Icons.notifications_active,
                  '/dashboard/manual-notifications',
                  isActive('/dashboard/manual-notifications'),
                ),
                _buildNavItem(
                  context,
                  'user_reports',
                  Icons.campaign,
                  '/dashboard/user-reports',
                  isActive('/dashboard/user-reports'),
                ),
              ],
            ),
          ),
          Divider(color: scheme.outlineVariant, height: 1),
          _buildNavItem(
            context,
            'settings',
            Icons.settings,
            '/dashboard/settings',
            isActive('/dashboard/settings'),
          ),
          _buildLogoutItem(context, t),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String Function(String) t) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 150,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.webp',
            height: 60,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            t('dashboard_title'),
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String titleKey,
    IconData icon,
    String route,
    bool isSelected,
  ) {
    String t(String key) => DashboardI18n.t(context, key);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color:
            isSelected
                ? scheme.primary.withValues(alpha: 0.14)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(8),
          hoverColor: scheme.primary.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    t(titleKey),
                    style: TextStyle(
                      color:
                          isSelected ? scheme.primary : scheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context, String Function(String) t) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _logout(context),
          borderRadius: BorderRadius.circular(8),
          hoverColor: scheme.error.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.logout, size: 20, color: scheme.error),
                const SizedBox(width: 16),
                Text(
                  t('logout'),
                  style: TextStyle(
                    color: scheme.error,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
