// ignore_for_file: invalid_use_of_protected_member

part of 'edit_news_screen.dart';

extension _EditNewsScreenLogic on _EditNewsScreenState {
  Future<void> _pickImage() async {
    _applyState(() {
      _imageUploadError = null;
    });

    try {
      final url = await _storageService.pickAndUploadImage(
        bucketName: 'news-images',
      );
      if (!mounted) return;
      if (url != null) {
        _applyState(() {
          _imageUrlController.text = url;
          _imageUploadError = null;
        });
        return;
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('file_too_large')) {
        _applyState(() {
          _imageUploadError = DashboardI18n.t(context, 'image_too_large');
        });
      } else {
        _applyState(() {
          _imageUploadError = DashboardI18n.t(context, 'image_upload_failed');
        });
      }
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final news = News(
        id: widget.news?.id ?? '',
        title: _titleController.text.trim(),
        titleEn: _titleEnController.text.trim(),
        content: _contentController.text.trim(),
        contentEn: _contentEnController.text.trim(),
        imageUrl: _imageUrlController.text,
        categoryId: _selectedCategoryId!,
        locationId: _selectedLocationId!,
        createdAt: widget.news?.createdAt ?? DateTime.now(),
        isFeatured: _isFeatured,
        isHidden: _isHidden,
        sentNotification: widget.news?.sentNotification ?? true,
      );

      try {
        if (widget.news == null) {
          await _newsService.createNews(news);
        } else {
          await _newsService.updateNews(news);
        }
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          await DashboardDialogs.showError(
            context,
            '${DashboardI18n.t(context, 'error_saving_news')}: $e',
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
