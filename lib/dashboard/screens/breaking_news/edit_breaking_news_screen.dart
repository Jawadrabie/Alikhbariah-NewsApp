import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsappjs/dashboard/models/breaking_news.dart';
import 'package:newsappjs/dashboard/services/breaking_news_service.dart';
import 'package:uuid/uuid.dart';

class EditBreakingNewsScreen extends StatefulWidget {
  final BreakingNews? breakingNews;
  const EditBreakingNewsScreen({super.key, this.breakingNews});

  @override
  State<EditBreakingNewsScreen> createState() => _EditBreakingNewsScreenState();
}

class _EditBreakingNewsScreenState extends State<EditBreakingNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  bool _sendNotification = true;
  bool _isLoading = false;

  final BreakingNewsService _breakingNewsService = BreakingNewsService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.breakingNews?.title);
    _contentController =
        TextEditingController(text: widget.breakingNews?.content);
    if (widget.breakingNews != null) {
      _startTime = widget.breakingNews!.startTime;
      _endTime = widget.breakingNews!.endTime;
      _sendNotification = widget.breakingNews!.sendNotification;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime({required bool isStart}) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _startTime : _endTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate == null) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(isStart ? _startTime : _endTime),
    );
    if (selectedTime == null) return;
    if (!mounted) return;

    setState(() {
      if (isStart) {
        _startTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      } else {
        _endTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      }
    });
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final breakingNews = BreakingNews(
        id: widget.breakingNews?.id ?? const Uuid().v4(),
        title: _titleController.text,
        content: _contentController.text,
        createdAt: widget.breakingNews?.createdAt ?? DateTime.now(),
        startTime: _startTime,
        endTime: _endTime,
        sendNotification: _sendNotification,
      );

      try {
        if (widget.breakingNews == null) {
          await _breakingNewsService.createBreakingNews(breakingNews);
        } else {
          await _breakingNewsService.updateBreakingNews(breakingNews);
        }
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        // Handle error
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.breakingNews == null
            ? 'Add Breaking News'
            : 'Edit Breaking News'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
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
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter content' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text('Start Time: ${_startTime.toString()}'),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectDateTime(isStart: true),
                      child: const Text('Select'),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text('End Time: ${_endTime.toString()}'),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectDateTime(isStart: false),
                      child: const Text('Select'),
                    )
                  ],
                ),
                SwitchListTile(
                  title: const Text('Send Notification'),
                  value: _sendNotification,
                  onChanged: (value) =>
                      setState(() => _sendNotification = value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
