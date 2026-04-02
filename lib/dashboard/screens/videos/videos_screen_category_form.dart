part of 'videos_screen.dart';

extension _VideosScreenCategoryForm on _VideosScreenState {
  Future<void> _openCategoryForm({Category? current}) async {
    String t(String key) => DashboardI18n.t(context, key);
    final nameController = TextEditingController(text: current?.name ?? '');
    final nameEnController = TextEditingController(text: current?.nameEn ?? '');
    final orderController = TextEditingController(
      text: (current?.orderIndex ?? 0).toString(),
    );
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(current == null ? t('add_category') : t('edit_category')),
          content: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameController,
                    labelText: t('name_ar'),
                    validator:
                        (value) => DashboardTextValidators.validateArabic(
                          value: value,
                          required: true,
                          requiredMessage: t('please_fill_all_fields'),
                          invalidLanguageMessage: t(
                            'arabic_field_rejects_english',
                          ),
                        ),
                  ),
                  CustomTextField(
                    controller: nameEnController,
                    labelText: t('name_en'),
                    validator:
                        (value) => DashboardTextValidators.validateEnglish(
                          value: value,
                          required: true,
                          requiredMessage: t('please_fill_all_fields'),
                          invalidLanguageMessage: t(
                            'english_field_rejects_arabic',
                          ),
                        ),
                  ),
                  CustomTextField(
                    controller: orderController,
                    keyboardType: TextInputType.number,
                    labelText: t('order_index'),
                    showLabelAboveField: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t('cancel')),
            ),
            FilledButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                final item = Category(
                  id: current?.id ?? '',
                  name: nameController.text.trim(),
                  nameEn: nameEnController.text.trim(),
                  slug: current?.slug,
                  coverImageUrl: current?.coverImageUrl,
                  orderIndex: int.tryParse(orderController.text.trim()) ?? 0,
                  type: widget.programId != null ? 'program' : 'video',
                );

                try {
                  if (current == null) {
                    await _categoryService.createCategory(item);
                  } else {
                    await _categoryService.updateCategory(item);
                  }
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  await DashboardDialogs.showError(
                    dialogContext,
                    '${t('error_saving_category')}: $e',
                  );
                  return;
                }

                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                _reload();
              },
              child: Text(t('save')),
            ),
          ],
        );
      },
    );
  }
}
