part of 'edit_news_screen.dart';

extension _EditNewsScreenView on _EditNewsScreenState {
  Widget _buildScreen(BuildContext context) {
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
                          enableSearch: false,
                        items: [
                          DropdownMenuItem(
                            value: _EditNewsScreenState._imageSourceUrl,
                            child: Text(t('direct_url')),
                          ),
                          DropdownMenuItem(
                            value: _EditNewsScreenState._imageSourceUpload,
                            child: Text(t('upload_from_device')),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          _applyState(() {
                            _imageSource = value;
                            _imageUploadError = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_imageSource == _EditNewsScreenState._imageSourceUrl)
                  CustomTextField(
                    controller: _imageUrlController,
                    labelText: t('image_url'),
                    validator: (value) {
                      if (_imageSource !=
                          _EditNewsScreenState._imageSourceUrl) {
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
                            if (_imageSource !=
                                _EditNewsScreenState._imageSourceUpload) {
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
                        _imageSource == _EditNewsScreenState._imageSourceUpload
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
                      return CustomTextField(
                        labelText: t('category'),
                        hintText:
                            Localizations.localeOf(context).languageCode == 'ar'
                                ? 'جاري تجهيز التصنيفات...'
                                : 'Preparing categories...',
                        readOnly: true,
                      );
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
                              _applyState(() => _selectedCategoryId = value),
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
                      return CustomTextField(
                        labelText: t('location'),
                        hintText:
                            Localizations.localeOf(context).languageCode == 'ar'
                                ? 'جاري تجهيز المحافظات...'
                                : 'Preparing locations...',
                        readOnly: true,
                      );
                    }
                    return CustomDropdownField<String>(
                      value: _selectedLocationId,
                      labelText: t('location'),
                      items:
                          snapshot.data!
                              .map(
                                (location) => DropdownMenuItem(
                                  value: location.id,
                                  child: Text(location.name),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) =>
                              _applyState(() => _selectedLocationId = value),
                      validator:
                          (value) =>
                              value == null
                                  ? t('please_select_location')
                                  : null,
                    );
                  },
                ),
                CustomSwitchTile(
                  title: t('featured'),
                  value: _isFeatured,
                  onChanged: (value) => _applyState(() => _isFeatured = value),
                ),
                CustomSwitchTile(
                  title: t('hidden'),
                  value: _isHidden,
                  onChanged: (value) => _applyState(() => _isHidden = value),
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
