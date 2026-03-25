import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/models/category.dart';
import 'package:newsappjs/dashboard/models/location.dart';
import 'package:newsappjs/dashboard/models/news.dart';
import 'package:newsappjs/dashboard/services/category_service.dart';
import 'package:newsappjs/dashboard/services/location_service.dart';
import 'package:newsappjs/dashboard/services/news_service.dart';
import 'package:newsappjs/dashboard/services/storage_service.dart';
import 'package:newsappjs/dashboard/widgets/custom_form_fields.dart';
import 'package:newsappjs/dashboard/widgets/dashboard_button_content.dart';
import 'package:newsappjs/dashboard/widgets/dashboard_form_container.dart';

class EditNewsScreen extends StatefulWidget {
  final News? news;
  const EditNewsScreen({super.key, this.news});

  @override
  State<EditNewsScreen> createState() => _EditNewsScreenState();
}

class _EditNewsScreenState extends State<EditNewsScreen> {
  static const String _imageSourceUrl = 'url';
  static const String _imageSourceUpload = 'upload';

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _titleEnController;
  late final TextEditingController _contentController;
  late final TextEditingController _contentEnController;
  late final TextEditingController _imageUrlController;

  final CategoryService _categoryService = CategoryService();
  final LocationService _locationService = LocationService();
  final NewsService _newsService = NewsService();
  final StorageService _storageService = StorageService();

  late Future<List<Category>> _categoriesFuture;
  late Future<List<Location>> _locationsFuture;

  String? _selectedCategoryId;
  String? _selectedLocationId;
  String? _imageUploadError;
  String _imageSource = _imageSourceUrl;

  bool _isFeatured = false;
  bool _isHidden = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.news?.title);
    _titleEnController = TextEditingController(text: widget.news?.titleEn);
    _contentController = TextEditingController(text: widget.news?.content);
    _contentEnController = TextEditingController(text: widget.news?.contentEn);
    _imageUrlController = TextEditingController(text: widget.news?.imageUrl);
    _isFeatured = widget.news?.isFeatured ?? false;
    _isHidden = widget.news?.isHidden ?? false;
    _selectedCategoryId = widget.news?.categoryId;
    _selectedLocationId = widget.news?.locationId;
    _imageSource =
        (widget.news?.imageUrl != null && widget.news!.imageUrl.isNotEmpty)
            ? _imageSourceUrl
            : _imageSourceUpload;

    _categoriesFuture = _categoryService.getCategories(type: 'news');
    _locationsFuture = _locationService.getLocations();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleEnController.dispose();
    _contentController.dispose();
    _contentEnController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() {
      _imageUploadError = null;
    });

    try {
      final url = await _storageService.pickAndUploadImage(
        bucketName: 'news-images',
      );
      if (url != null) {
        setState(() {
          _imageUrlController.text = url;
          _imageUploadError = null;
        });
        return;
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('file_too_large')) {
        setState(() {
          _imageUploadError = DashboardI18n.t(context, 'image_too_large');
        });
      } else {
        setState(() {
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

  @override
  Widget build(BuildContext context) {
    String t(String key) => DashboardI18n.t(context, key);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.news == null ? t('add_news') : t('edit_news')),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.save),
            label: DashboardLoadingButtonChild(
              isLoading: _isLoading,
              label: t('save'),
              spinnerSize: 16,
            ),
            style: TextButton.styleFrom(foregroundColor: scheme.primary),
            onPressed: _isLoading ? null : _saveForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: DashboardFormContainer(
          maxWidth: null,
          center: false,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _titleController,
                  labelText: t('title_ar'),
                  validator:
                      (value) =>
                          value!.isEmpty ? t('please_enter_title') : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _titleEnController,
                  labelText: t('title_en'),
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? t('please_enter_title_en')
                              : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _contentController,
                  labelText: t('content_html_ar'),
                  hintText: t('content_hint'),
                  alignLabelWithHint: true,
                  minLines: 3,
                  maxLines: null,
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? t('please_enter_content')
                              : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _contentEnController,
                  labelText: t('content_html_en'),
                  hintText: t('content_hint_en'),
                  alignLabelWithHint: true,
                  minLines: 3,
                  maxLines: null,
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? t('please_enter_content_en')
                              : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomDropdownField<String>(
                        value: _imageSource,
                        labelText: t('image_source'),
                        items: [
                          DropdownMenuItem(
                            value: _imageSourceUrl,
                            child: Text(t('direct_url')),
                          ),
                          DropdownMenuItem(
                            value: _imageSourceUpload,
                            child: Text(t('upload_from_device')),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _imageSource = value;
                            _imageUploadError = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_imageSource == _imageSourceUrl)
                  CustomTextField(
                    controller: _imageUrlController,
                    labelText: t('image_url'),
                    validator: (value) {
                      if (_imageSource != _imageSourceUrl) {
                        return null;
                      }
                      return value == null || value.isEmpty
                          ? t('please_enter_image_url')
                          : null;
                    },
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _imageUrlController,
                          readOnly: true,
                          labelText: t('uploaded_image_url'),
                          hintText: t('upload_from_device'),
                          validator: (value) {
                            if (_imageSource != _imageSourceUpload) {
                              return null;
                            }
                            return value == null || value.isEmpty
                                ? t('please_upload_image')
                                : null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.upload_file, color: scheme.primary),
                        tooltip: t('upload_image'),
                        onPressed: _pickImage,
                      ),
                    ],
                  ),
                if (_imageUploadError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _imageUploadError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _imageSource == _imageSourceUpload
                            ? t('choose_image_then_save')
                            : t('provide_url_then_save'),
                      ),
                    ),
                  ],
                ),
                FutureBuilder<List<Category>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    return CustomDropdownField<String>(
                      value: _selectedCategoryId,
                      labelText: t('category'),
                      items:
                          snapshot.data!
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.name),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) =>
                              setState(() => _selectedCategoryId = value),
                      validator:
                          (value) =>
                              value == null
                                  ? t('please_select_category')
                                  : null,
                    );
                  },
                ),
                FutureBuilder<List<Location>>(
                  future: _locationsFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final searchController = TextEditingController();
                    return CustomDropdownField<String>(
                      value: _selectedLocationId,
                      labelText: t('location'),
                      items: snapshot.data!
                          .map(
                            (location) => DropdownMenuItem(
                              value: location.id,
                              child: Text(location.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedLocationId = value),
                      validator: (value) =>
                          value == null ? t('please_select_location') : null,
                      searchController: searchController,
                      searchHintText: t('search_location'),
                    );
                  },
                ),
                CustomSwitchTile(
                  title: t('featured'),
                  value: _isFeatured,
                  onChanged: (value) => setState(() => _isFeatured = value),
                ),
                CustomSwitchTile(
                  title: t('hidden'),
                  value: _isHidden,
                  onChanged: (value) => setState(() => _isHidden = value),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _saveForm,
                    icon: const Icon(Icons.save),
                    label: DashboardLoadingButtonChild(
                      isLoading: _isLoading,
                      label:
                          widget.news == null
                              ? t('create_news')
                              : t('save_changes'),
                      spinnerSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
