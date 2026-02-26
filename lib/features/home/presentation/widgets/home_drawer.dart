import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:newsappjs/core/settings/app_settings_controller.dart';

import '../../../../core/localization/l10n_extensions.dart';

import '../../../media/presentation/screens/live_stream_screen.dart';
import '../../../media/presentation/screens/programs_screen.dart';
import '../../../media/presentation/screens/videos_screen.dart';
import '../../../news/presentation/screens/saved_news_screen.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  late final Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _openScreen(Widget screen) async {
    Navigator.of(context).pop();
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _chooseLanguage() async {
    final l10n = context.l10n;
    final current = AppSettingsController.instance.locale.languageCode;

    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.languageArabic),
                trailing: current == 'ar' ? const Icon(Icons.check_rounded) : null,
                onTap: () => Navigator.of(context).pop('ar'),
              ),
              ListTile(
                title: Text(l10n.languageEnglish),
                trailing: current == 'en' ? const Icon(Icons.check_rounded) : null,
                onTap: () => Navigator.of(context).pop('en'),
              ),
              ListTile(
                title: Text(l10n.cancel),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null) return;
    await AppSettingsController.instance.setLocale(Locale(selected));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeName = Localizations.localeOf(context).toString();
    final date = intl.DateFormat.yMd(localeName).format(_now);
    final time = intl.DateFormat.Hms(localeName).format(_now);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primary.withAlpha(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      'assets/images/logo.webp',
                      height: 34,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.appTitle,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(l10n.dateLabel(date)),
                  Text(l10n.timeLabel(time)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.live_tv_rounded),
              title: Text(l10n.liveStream),
              onTap: () => _openScreen(const LiveStreamScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_none_rounded),
              title: Text(l10n.notifications),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.notificationsComingSoon)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_outline_rounded),
              title: Text(l10n.savedNews),
              onTap: () => _openScreen(const SavedNewsScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: Text(l10n.videos),
              onTap: () => _openScreen(const VideosScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.ondemand_video_outlined),
              title: Text(l10n.programs),
              onTap: () => _openScreen(const ProgramsScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.newspaper_rounded),
              title: Text(l10n.latestNews),
              onTap: () => Navigator.of(context).pop(),
            ),
            const Divider(height: 28),
            SwitchListTile.adaptive(
              value: AppSettingsController.instance.isDarkMode,
              onChanged: (value) async {
                await AppSettingsController.instance.setDarkMode(value);
              },
              title: Text(l10n.darkMode),
              secondary: const Icon(Icons.dark_mode_outlined),
            ),
            ListTile(
              leading: const Icon(Icons.language_rounded),
              title: Text(l10n.language),
              onTap: _chooseLanguage,
            ),
          ],
        ),
      ),
    );
  }
}
