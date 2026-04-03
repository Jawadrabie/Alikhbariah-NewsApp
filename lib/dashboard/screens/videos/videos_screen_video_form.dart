part of 'videos_screen.dart';

extension _VideosScreenVideoForm on _VideosScreenState {
  Future<void> _openForm({
    VideoItem? current,
    List<VideoItem>? scopedItems,
    String? defaultCategoryType,
  }) async {
    String t(String key) => DashboardI18n.t(context, key);
    final titleController = TextEditingController(text: current?.title ?? '');
    final titleEnController = TextEditingController(
      text: current?.titleEn ?? '',
    );
    final urlController = TextEditingController(
      text: current?.youtubeUrl ?? '',
    );

    final isProgramScoped = widget.programId != null;
    final isRootVideosSection =
        widget.programId == null && widget.categoryId == null;
    final lockCategorySelection = widget.categoryId != null || isProgramScoped;
    final shouldShowCategoryTypeSelector =
        !lockCategorySelection &&
        !isRootVideosSection &&
        defaultCategoryType == null;
    String selectedCategoryType =
        defaultCategoryType ?? (isProgramScoped ? 'program' : 'video');

    if (isRootVideosSection) {
      selectedCategoryType = 'video';
    }

    final videoCategories =
        (isProgramScoped || selectedCategoryType == 'program')
            ? <Category>[]
            : await _categoryService.getCategories(type: 'video');
    final programCategories =
        (isProgramScoped || selectedCategoryType == 'video')
            ? <Category>[]
            : await _categoryService.getCategories(type: 'program');

    if (!mounted) return;
    String? selectedCategoryId = widget.categoryId ?? current?.categoryId;

    List<Category> categoriesForType(String type) {
      return type == 'program' ? programCategories : videoCategories;
    }

    if (!lockCategorySelection &&
        selectedCategoryId != null &&
        !isRootVideosSection) {
      final inProgram = programCategories.any(
        (c) => c.id == selectedCategoryId,
      );
      selectedCategoryType = inProgram ? 'program' : 'video';
    }

    if (!lockCategorySelection && selectedCategoryId == null) {
      final available = categoriesForType(selectedCategoryType);
      if (available.length == 1) {
        selectedCategoryId = available.first.id;
      }
    }

    final initialOrderIndex =
        current?.orderIndex ??
        (scopedItems != null
            ? _nextVideoOrderIndex(scopedItems)
            : await _nextVideoOrderIndexForScope(
              programId: widget.programId,
              categoryId: widget.categoryId ?? selectedCategoryId,
            ));
    if (!mounted) return;

    final orderController = TextEditingController(
      text: initialOrderIndex.toString(),
    );
    bool isHidden = current?.isHidden ?? false;
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            current == null
                ? (isProgramScoped ? t('add_episode') : t('add_video'))
                : (isProgramScoped ? t('edit_episode') : t('edit_video')),
          ),
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
                              required: true,
                              requiredMessage: t('please_fill_all_fields'),
                              invalidLanguageMessage: t(
                                'english_field_rejects_arabic',
                              ),
                            ),
                      ),
                    CustomTextField(
                      controller: urlController,
                      labelText: t('youtube_url'),
                    ),
                    if (shouldShowCategoryTypeSelector)
                      CustomDropdownField<String>(
                        value: selectedCategoryType,
                        labelText: t('category_type'),
                        enableSearch: false,
                        items: [
                          DropdownMenuItem(
                            value: 'video',
                            child: Text(t('category_type_video')),
                          ),
                          DropdownMenuItem(
                            value: 'program',
                            child: Text(t('category_type_program')),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value == null) return;
                          setLocalState(() {
                            selectedCategoryType = value;
                            selectedCategoryId = null;
                          });

                          if (current != null) return;
                          final nextIndex = await _nextVideoOrderIndexForScope(
                            categoryId: null,
                          );
                          if (!context.mounted) return;
                          setLocalState(() {
                            orderController.text = nextIndex.toString();
                          });
                        },
                      ),
                    if (!lockCategorySelection)
                      CustomDropdownField<String>(
                        value: selectedCategoryId,
                        labelText: t(
                          selectedCategoryType == 'program'
                              ? 'program_category_required'
                              : 'video_category_required',
                        ),
                        items: [
                          ...categoriesForType(selectedCategoryType).map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          ),
                        ],
                        onChanged:
                            lockCategorySelection
                                ? null
                                : (value) async {
                                  setLocalState(
                                    () => selectedCategoryId = value,
                                  );
                                  if (current != null) return;
                                  final nextIndex =
                                      await _nextVideoOrderIndexForScope(
                                        programId: widget.programId,
                                        categoryId: value,
                                      );
                                  if (!context.mounted) return;
                                  setLocalState(() {
                                    orderController.text = nextIndex.toString();
                                  });
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
              onPressed:
                  isSaving ? null : () => Navigator.of(dialogContext).pop(),
              child: Text(t('cancel')),
            ),
            FilledButton(
              onPressed:
                  isSaving
                      ? null
                      : () async {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                if (!lockCategorySelection &&
                    (selectedCategoryId == null ||
                        selectedCategoryId!.isEmpty)) {
                  await DashboardDialogs.showError(
                    dialogContext,
                    t(
                      selectedCategoryType == 'program'
                          ? 'please_select_program_category'
                          : 'please_select_video_category',
                    ),
                  );
                  return;
                }

                setLocalState(() => isSaving = true);

                final item = VideoItem(
                  id: current?.id ?? '',
                  title: titleController.text.trim(),
                  titleEn: titleEnController.text.trim(),
                  youtubeUrl: urlController.text.trim(),
                  programId: widget.programId ?? current?.programId,
                  categoryId: selectedCategoryId,
                  thumbnailUrl: current?.thumbnailUrl,
                  orderIndex: int.tryParse(orderController.text.trim()) ?? 0,
                  publishedAt: current?.publishedAt,
                  createdAt: current?.createdAt ?? DateTime.now(),
                  isHidden: isHidden,
                );

                try {
                  if (current == null) {
                    await _service.createVideo(item);
                  } else {
                    await _service.updateVideo(item);
                  }
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  setLocalState(() => isSaving = false);
                  await DashboardDialogs.showError(
                    dialogContext,
                    '${t('error_saving_video')}: $e',
                  );
                  return;
                }

                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                _reload();
              },
              child: DashboardLoadingButtonChild(
                isLoading: isSaving,
                label: t('save'),
              ),
            ),
          ],
        );
      },
    );
  }
}
