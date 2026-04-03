import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/core/dashboard_text_validators.dart';
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

part 'edit_news_screen_logic.dart';
part 'edit_news_screen_view.dart';

class EditNewsScreen extends StatefulWidget {
  const EditNewsScreen({super.key, this.news});

  final News? news;

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
  String _imageSource = _imageSourceUpload;
  bool _isUploadingImage = false;

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
    _imageSource = _imageSourceUpload;

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

  void _applyState(VoidCallback update) {
    if (!mounted) return;
    setState(update);
  }

  @override
  Widget build(BuildContext context) => _buildScreen(context);
}
