class DashboardTextValidators {
  static final RegExp _arabicLetters = RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
  );
  static final RegExp _latinLetters = RegExp(r'[A-Za-z]');

  static String? validateArabic({
    required String? value,
    required String invalidLanguageMessage,
    String? requiredMessage,
    bool required = false,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      if (!required) {
        return null;
      }
      return requiredMessage ?? '';
    }

    final normalized = _normalizeForLanguageCheck(text);
    if (_latinLetters.hasMatch(normalized)) {
      return invalidLanguageMessage;
    }

    return null;
  }

  static String? validateEnglish({
    required String? value,
    required String invalidLanguageMessage,
    String? requiredMessage,
    bool required = false,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      if (!required) {
        return null;
      }
      return requiredMessage ?? '';
    }

    final normalized = _normalizeForLanguageCheck(text);
    if (_arabicLetters.hasMatch(normalized)) {
      return invalidLanguageMessage;
    }

    return null;
  }

  static String _normalizeForLanguageCheck(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'&[A-Za-z0-9#]+;'), ' ');
  }
}
