part of 'categories_screen.dart';

extension _CategoriesScreenForm on _CategoriesScreenState {
  Future<void> _openForm({
    Category? current,
    required List<Category> categories,
    String? presetType,
  }) async {
    String t(String key) => DashboardI18n.t(context, key);
    final nameController = TextEditingController(text: current?.name ?? '');
    final nameEnController = TextEditingController(text: current?.nameEn ?? '');
    final initialType = current?.type ?? _normalizeCategoryType(presetType);
    final orderController = TextEditingController(
      text:
          (current?.orderIndex ??
                  _nextOrderIndexForType(categories, initialType))
              .toString(),
    );
    String selectedType = initialType;
    String? coverImageUrl = current?.coverImageUrl;
    String? coverUploadError;
    bool uploadingCover = false;
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(current == null ? t('add_category') : t('edit_category')),
          content: StatefulBuilder(
            builder: (context, setLocalState) {
              final scheme = Theme.of(context).colorScheme;

              return Form(
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
                    CustomDropdownField<String>(
                      value: selectedType,
                      labelText: t('category_type'),
                      enableSearch: false,
                      items: [
                        DropdownMenuItem(
                          value: 'news',
                          child: Text(t('category_type_news')),
                        ),
                        DropdownMenuItem(
                          value: 'video',
                          child: Text(t('category_type_video')),
                        ),
                        DropdownMenuItem(
                          value: 'program',
                          child: Text(t('category_type_program')),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setLocalState(() {
                          selectedType = value;
                          if (current == null) {
                            orderController.text =
                                _nextOrderIndexForType(
                                  categories,
                                  selectedType,
                                ).toString();
                          }
                        });
                      },
                    ),
                    if (selectedType == 'video' ||
                        selectedType == 'program') ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.tonalIcon(
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                backgroundColor: scheme.onSurface.withValues(
                                  alpha: 0.04,
                                ),
                                foregroundColor: scheme.onSurface,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed:
                                  uploadingCover
                                      ? null
                                      : () async {
                                        setLocalState(() {
                                          uploadingCover = true;
                                          coverUploadError = null;
                                        });

                                        try {
                                          final url = await _storageService
                                              .pickAndUploadImage(
                                                bucketName: 'news-images',
                                                folder: 'category-covers',
                                              );
                                          if (!context.mounted) return;
                                          setLocalState(() {
                                            if (url != null &&
                                                url.isNotEmpty) {
                                              coverImageUrl = url;
                                            }
                                            uploadingCover = false;
                                          });
                                        } catch (e) {
                                          if (!context.mounted) return;
                                          setLocalState(() {
                                            uploadingCover = false;
                                            if (e.toString().contains(
                                              'file_too_large',
                                            )) {
                                              coverUploadError = t(
                                                'image_too_large',
                                              );
                                            } else {
                                              coverUploadError = t(
                                                'image_upload_failed',
                                              );
                                            }
                                          });
                                        }
                                      },
                              icon:
                                  uploadingCover
                                      ? SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                scheme.primary,
                                              ),
                                        ),
                                      )
                                      : Icon(
                                        Icons.image_outlined,
                                        color: scheme.primary,
                                      ),
                              label: Text(t('upload_cover_image')),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (coverImageUrl != null &&
                              coverImageUrl!.isNotEmpty)
                            IconButton(
                              tooltip: t('delete'),
                              onPressed: () {
                                setLocalState(() => coverImageUrl = null);
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                        ],
                      ),
                      if (coverImageUrl != null && coverImageUrl!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              t('uploaded_image_url'),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: scheme.onSurface.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SelectableText(
                                coverImageUrl!,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      if (coverUploadError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              coverUploadError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                    ],
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: orderController,
                        keyboardType: TextInputType.number,
                        labelText: t('order_index'),
                        showLabelAboveField: true,
                      ),
                    ],
                  ),
                ),
              );
            },
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

                if ((selectedType == 'video' || selectedType == 'program') &&
                    (coverImageUrl == null || coverImageUrl!.trim().isEmpty)) {
                  await DashboardDialogs.showError(
                    dialogContext,
                    t('please_upload_cover_image'),
                  );
                  return;
                }

                final item = Category(
                  id: current?.id ?? '',
                  name: nameController.text.trim(),
                  nameEn: nameEnController.text.trim(),
                  slug: current?.slug,
                  coverImageUrl: coverImageUrl,
                  orderIndex: int.tryParse(orderController.text.trim()) ?? 0,
                  type: selectedType,
                );

                try {
                  if (current == null) {
                    await _service.createCategory(item);
                  } else {
                    await _service.updateCategory(item);
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
