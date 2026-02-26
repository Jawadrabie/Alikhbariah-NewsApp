import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../localization/l10n_extensions.dart';

String formatRelativeTime(BuildContext context, DateTime dateTime) {
  final l10n = context.l10n;
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return l10n.justNow;
  }

  if (difference.inHours < 1) {
    return l10n.minutesAgo(difference.inMinutes);
  }

  if (difference.inDays < 1) {
    return l10n.hoursAgo(difference.inHours);
  }

  if (difference.inDays < 7) {
    return l10n.daysAgo(difference.inDays);
  }

  if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return l10n.weeksAgo(weeks < 1 ? 1 : weeks);
  }

  final localeName = Localizations.localeOf(context).toString();
  return DateFormat('yyyy-MM-dd – HH:mm', localeName).format(dateTime);
}
