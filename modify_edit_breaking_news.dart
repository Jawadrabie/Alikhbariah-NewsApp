import 'dart:io';

void main() {
  File file = File('lib/dashboard/screens/breaking_news/edit_breaking_news_screen.dart');
  String content = file.readAsStringSync();
  content = content.replaceAll(
    'padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),',
    'padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),'
  );
  content = content.replaceAll(
    'crossAxisAlignment: CrossAxisAlignment.start,',
    'crossAxisAlignment: CrossAxisAlignment.stretch,'
  );
  file.writeAsStringSync(content);
}
