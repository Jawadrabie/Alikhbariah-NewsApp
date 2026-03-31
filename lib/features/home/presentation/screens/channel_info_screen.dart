import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extensions.dart';

class ChannelInfoScreen extends StatelessWidget {
  const ChannelInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.channelSectionTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  primary.withAlpha(42),
                  primary.withAlpha(12),
                ],
              ),
              border: Border.all(color: primary.withAlpha(70)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withAlpha(36),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.channelSectionTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ChannelInfoCard(
            icon: Icons.badge_outlined,
            title: l10n.aboutUs,
            child: Text(
              l10n.aboutUsDescription,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(height: 12),
          _ChannelInfoCard(
            icon: Icons.settings_input_antenna_rounded,
            title: l10n.channelFrequencies,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.nilesat,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _FrequencyRow(label: l10n.frequencySd, value: '12303 H 27500'),
                const SizedBox(height: 8),
                _FrequencyRow(label: l10n.frequencyHd, value: '11938 V 27500'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ChannelInfoCard(
            icon: Icons.groups_rounded,
            title: l10n.developmentTeam,
            child: Column(
              children: [
                _DeveloperTile(
                  name: l10n.developerNameAbduljawad,
                  role: l10n.developerRole,
                  accent: const Color(0xFF0EA5E9),
                ),
                const SizedBox(height: 10),
                _DeveloperTile(
                  name: l10n.developerNameAsmaa,
                  role: l10n.developerRole,
                  accent: const Color(0xFF14B8A6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelInfoCard extends StatelessWidget {
  const _ChannelInfoCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.onSurface.withAlpha(26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _FrequencyRow extends StatelessWidget {
  const _FrequencyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: primary.withAlpha(30),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DeveloperTile extends StatelessWidget {
  const _DeveloperTile({
    required this.name,
    required this.role,
    required this.accent,
  });

  final String name;
  final String role;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: accent.withAlpha(18),
        border: Border.all(color: accent.withAlpha(64)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withAlpha(40),
            ),
            child: Icon(Icons.code_rounded, size: 17, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: accent.withAlpha(30),
            ),
            child: Text(
              role,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
