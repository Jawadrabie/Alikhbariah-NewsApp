import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/core/dashboard_dialogs.dart';
import 'package:newsappjs/dashboard/core/dashboard_i18n.dart';
import 'package:newsappjs/dashboard/core/dashboard_text_validators.dart';
import 'package:newsappjs/dashboard/models/category.dart';
import 'package:newsappjs/dashboard/models/video_item.dart';
import 'package:newsappjs/dashboard/services/category_service.dart';
import 'package:newsappjs/dashboard/services/videos_service.dart';
import 'package:newsappjs/dashboard/widgets/dashboard_button_content.dart';
import 'package:newsappjs/dashboard/widgets/custom_form_fields.dart';
import 'package:newsappjs/dashboard/widgets/section_ui.dart';

part 'videos_screen_category_form.dart';
part 'videos_screen_logic.dart';
part 'videos_screen_video_form.dart';
part 'videos_screen_view.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({
    super.key,
    this.programId,
    this.programName,
    this.categoryId,
    this.categoryName,
    this.openAddForm = false,
    this.defaultCategoryType,
  });

  final String? programId;
  final String? programName;
  final String? categoryId;
  final String? categoryName;
  final bool openAddForm;
  final String? defaultCategoryType;

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final VideosService _service = VideosService();
  final CategoryService _categoryService = CategoryService();
  late Future<List<VideoItem>> _future;
  late Future<List<Category>> _categoriesWithCountsFuture;
  String? _selectedCategoryId;
  bool _didAutoOpenAddForm = false;

  void setLocalState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _categoriesWithCountsFuture = _loadCategoriesWithCounts();
    _reload();
    if (widget.openAddForm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _didAutoOpenAddForm) return;
        _didAutoOpenAddForm = true;
        _openForm();
      });
    }
  }

  @override
  Widget build(BuildContext context) => _buildScreen(context);
}
