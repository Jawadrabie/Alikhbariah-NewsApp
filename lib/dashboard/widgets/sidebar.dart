import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Drawer(
      elevation: 0,
      child: Column(
        children: [
          const DrawerHeader(
            child: Center(
              child: Text(
                'Alikhbariah Dashboard',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Main News'),
            selected: currentRoute == '/dashboard/main-news',
            onTap: () => context.go('/dashboard/main-news'),
          ),
          ListTile(
            leading: const Icon(Icons.new_releases),
            title: const Text('Breaking News'),
            selected: currentRoute == '/dashboard/breaking-news',
            onTap: () => context.go('/dashboard/breaking-news'),
          ),
          ListTile(
            leading: const Icon(Icons.linear_scale),
            title: const Text('Ticker News'),
            selected: currentRoute == '/dashboard/ticker-news',
            onTap: () => context.go('/dashboard/ticker-news'),
          ),
          ListTile(
            leading: const Icon(Icons.live_tv),
            title: const Text('Live Stream'),
            selected: currentRoute == '/dashboard/live-stream',
            onTap: () => context.go('/dashboard/live-stream'),
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('Videos'),
            selected: currentRoute == '/dashboard/videos',
            onTap: () => context.go('/dashboard/videos'),
          ),
          ListTile(
            leading: const Icon(Icons.video_collection),
            title: const Text('Programs'),
            selected: currentRoute == '/dashboard/programs',
            onTap: () => context.go('/dashboard/programs'),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            selected: currentRoute == '/dashboard/categories',
            onTap: () => context.go('/dashboard/categories'),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Locations'),
            selected: currentRoute == '/dashboard/locations',
            onTap: () => context.go('/dashboard/locations'),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            selected: currentRoute == '/dashboard/settings',
            onTap: () => context.go('/dashboard/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
