import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/models/category.dart';
import 'package:newsappjs/dashboard/models/location.dart';
import 'package:newsappjs/dashboard/models/news.dart';
import 'package:newsappjs/dashboard/services/category_service.dart';
import 'package:newsappjs/dashboard/services/location_service.dart';
import 'package:newsappjs/dashboard/services/news_service.dart';
import 'package:uuid/uuid.dart';

class EditNewsScreen extends StatefulWidget {
  final News? news;
  const EditNewsScreen({super.key, this.news});

  @override
  State<EditNewsScreen> createState() => _EditNewsScreenState();
}

class _EditNewsScreenState extends State<EditNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _summaryController;
  late final TextEditingController _contentController;
  late final TextEditingController _imageUrlController;

  final CategoryService _categoryService = CategoryService();
  final LocationService _locationService = LocationService();
  final NewsService _newsService = NewsService();

  late Future<List<Category>> _categoriesFuture;
  late Future<List<Location>> _locationsFuture;

  String? _selectedCategoryId;
  String? _selectedLocationId;

  bool _isFeatured = false;
  bool _isHidden = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.news?.title);
    _summaryController = TextEditingController(text: widget.news?.summary);
    _contentController = TextEditingController(text: widget.news?.content);
    _imageUrlController = TextEditingController(text: widget.news?.imageUrl);
    _isFeatured = widget.news?.isFeatured ?? false;
    _isHidden = widget.news?.isHidden ?? false;
    _selectedCategoryId = widget.news?.categoryId;
    _selectedLocationId = widget.news?.locationId;

    _categoriesFuture = _categoryService.getCategories();
    _locationsFuture = _locationService.getLocations();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final news = News(
        id: widget.news?.id ?? const Uuid().v4(),
        title: _titleController.text,
        summary: _summaryController.text,
        content: _contentController.text,
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
        // Handle error
      } finally {
        if(mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.news == null ? 'Add News' : 'Edit News'),
        actions: [
          if (_isLoading)
            const CircularProgressIndicator()
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveForm,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a title' : null,
                ),
                TextFormField(
                  controller: _summaryController,
                  decoration: const InputDecoration(labelText: 'Summary'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a summary' : null,
                ),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 5,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter content' : null,
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter an image URL' : null,
                ),
                FutureBuilder<List<Category>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    return DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      items: snapshot.data!
                          .map((category) => DropdownMenuItem(
                                value: category.id,
                                child: Text(category.name),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCategoryId = value),
                      decoration: const InputDecoration(labelText: 'Category'),
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    );
                  },
                ),
                FutureBuilder<List<Location>>(
                  future: _locationsFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    return DropdownButtonFormField<String>(
                      value: _selectedLocationId,
                      items: snapshot.data!
                          .map((location) => DropdownMenuItem(
                                value: location.id,
                                child: Text(location.name),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedLocationId = value),
                      decoration: const InputDecoration(labelText: 'Location'),
                      validator: (value) =>
                          value == null ? 'Please select a location' : null,
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('Featured'),
                  value: _isFeatured,
                  onChanged: (value) => setState(() => _isFeatured = value),
                ),
                SwitchListTile(
                  title: const Text('Hidden'),
                  value: _isHidden,
                  onChanged: (value) => setState(() => _isHidden = value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
