part of 'programs_screen.dart';

extension _ProgramsScreenForm on _ProgramsScreenState {
  Future<void> _openForm({
    Category? current,
    required List<Category> programs,
  }) async {
    String t(String key) => DashboardI18n.t(context, key);

    final nameController = TextEditingController(text: current?.name ?? '');
    final nameEnController = TextEditingController(text: current?.nameEn ?? '');
    final orderController = TextEditingController(
      text: (current?.orderIndex ?? _nextOrderIndex(programs)).toString(),
    );
    String? coverImageUrl = current?.coverImageUrl;
    String? coverUploadError;
    bool uploadingCover = false;
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(current == null ? t('add_program') : t('edit_program')),
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
                                          if (url != null && url.isNotEmpty) {
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
                        if (coverImageUrl != null && coverImageUrl!.isNotEmpty)
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

                if (coverImageUrl == null || coverImageUrl!.trim().isEmpty) {
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
                  type: 'program',
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

  Future<void> _openEpisodeForm({required List<Category> programs}) async {
    String t(String key) => DashboardI18n.t(context, key);
    if (programs.isEmpty) {
      await DashboardDialogs.showError(context, t('no_programs_found'));
      return;
    }

    final titleController = TextEditingController();
    final titleEnController = TextEditingController();
    final urlController = TextEditingController();
    final orderController = TextEditingController(text: '1');
    String selectedProgramId = programs.first.id;
    bool isHidden = false;
    final formKey = GlobalKey<FormState>();

    Future<void> updateOrder(StateSetter setLocalState) async {
      final videos = await _videosService.getVideos(
        categoryId: selectedProgramId,
      );
      if (!mounted) return;
      setLocalState(() {
        orderController.text = _nextEpisodeOrderIndex(videos).toString();
      });
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t('add_episode')),
          content: StatefulBuilder(
            builder: (context, setLocalState) {
              return Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        controller: titleController,
                        labelText: t('title_ar'),
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
                        controller: titleEnController,
                        labelText: t('title_en'),
                        validator:
                            (value) => DashboardTextValidators.validateEnglish(
                              value: value,
                              required: false,
                              invalidLanguageMessage: t(
                                'english_field_rejects_arabic',
                              ),
                            ),
                      ),
                    CustomTextField(
                      controller: urlController,
                      labelText: t('youtube_url'),
                    ),
                    CustomDropdownField<String>(
                      value: selectedProgramId,
                      labelText: t('program_category_required'),
                      items:
                          programs
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item.id,
                                  child: Text(item.name),
                                ),
                              )
                              .toList(),
                      onChanged: (value) async {
                        if (value == null) return;
                        setLocalState(() => selectedProgramId = value);
                        await updateOrder(setLocalState);
                      },
                    ),
                    CustomTextField(
                      controller: orderController,
                      keyboardType: TextInputType.number,
                      labelText: t('order_index'),
                      showLabelAboveField: true,
                    ),
                    CustomSwitchTile(
                      value: isHidden,
                      onChanged:
                          (value) => setLocalState(() => isHidden = value),
                      title: t('hidden'),
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

                if (titleController.text.trim().isEmpty ||
                    urlController.text.trim().isEmpty) {
                  await DashboardDialogs.showError(
                    dialogContext,
                    t('please_fill_all_fields'),
                  );
                  return;
                }

                final item = VideoItem(
                  id: '',
                  title: titleController.text.trim(),
                  titleEn: titleEnController.text.trim(),
                  youtubeUrl: urlController.text.trim(),
                  programId: null,
                  categoryId: selectedProgramId,
                  thumbnailUrl: null,
                  orderIndex: int.tryParse(orderController.text.trim()) ?? 0,
                  publishedAt: DateTime.now(),
                  createdAt: DateTime.now(),
                  isHidden: isHidden,
                );

                try {
                  await _videosService.createVideo(item);
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  await DashboardDialogs.showError(
                    dialogContext,
                    '${t('error_saving_video')}: $e',
                  );
                  return;
                }

                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
              },
              child: Text(t('save')),
            ),
          ],
        );
      },
    );
  }
}
