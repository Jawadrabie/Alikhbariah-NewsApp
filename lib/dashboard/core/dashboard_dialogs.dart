import 'package:flutter/material.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';

class DashboardDialogs {
  static Future<void> showError(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String t(String key) => DashboardI18n.t(dialogContext, key);
        return AlertDialog(
          title: Text(t('error')),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t('cancel')),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showSuccess(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String t(String key) => DashboardI18n.t(dialogContext, key);
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(t('success')),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t('ok')),
            ),
          ],
        );
      },
    );
  }
}
