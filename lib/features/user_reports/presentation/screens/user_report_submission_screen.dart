import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../data/services/user_report_attachment_service.dart';
import '../../data/services/user_report_submission_service.dart';

class UserReportSubmissionScreen extends StatefulWidget {
  const UserReportSubmissionScreen({super.key});

  @override
  State<UserReportSubmissionScreen> createState() =>
      _UserReportSubmissionScreenState();
}

class _UserReportSubmissionScreenState
    extends State<UserReportSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final _service = UserReportSubmissionService();
  final _attachmentService = UserReportAttachmentService();

  bool _isSubmitting = false;
  bool _isUploadingAttachment = false;
  String? _attachmentUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final l10n = context.l10n;
    try {
      await _service.submitReport(
        name: _nameController.text,
        phone: _phoneController.text,
        message: _messageController.text,
        attachmentUrl: _attachmentUrl,
      );

      if (!mounted) return;

      _formKey.currentState?.reset();
      _nameController.clear();
      _phoneController.clear();
      _messageController.clear();
      setState(() => _attachmentUrl = null);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.reportSentSuccessfully)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.reportSendFailed}: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _pickAttachment() async {
    final l10n = context.l10n;
    setState(() => _isUploadingAttachment = true);
    try {
      final uploadedUrl = await _attachmentService.pickAndUploadAttachment();
      if (!mounted) return;
      if (uploadedUrl == null) {
        setState(() => _isUploadingAttachment = false);
        return;
      }

      setState(() {
        _attachmentUrl = uploadedUrl;
        _isUploadingAttachment = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.reportAttachmentUploaded)));
    } catch (e) {
      if (!mounted) return;
      final key =
          e.toString().contains('attachment_too_large')
              ? l10n.reportAttachmentTooLarge
              : l10n.reportAttachmentUploadFailed;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(key)));
      setState(() => _isUploadingAttachment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.userReports)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.userReportsDrawerSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.reportName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.reportPhone,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _messageController,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.reportMessageRequired;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: l10n.reportMessage,
                    hintText: l10n.reportMessageHint,
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed:
                      (_isSubmitting || _isUploadingAttachment)
                          ? null
                          : _pickAttachment,
                  icon:
                      _isUploadingAttachment
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.attach_file_rounded),
                  label: Text(l10n.reportAttachImage),
                ),
                if (_attachmentUrl != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.reportAttachmentReady,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        IconButton(
                          onPressed:
                              _isSubmitting
                                  ? null
                                  : () => setState(() => _attachmentUrl = null),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon:
                      _isSubmitting
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.send_rounded),
                  label: Text(l10n.sendReport),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
