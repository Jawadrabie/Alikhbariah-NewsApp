import 'dart:io';

void wrapTable(String path) {
  File file = File(path);
  if (!file.existsSync()) return;
  String content = file.readAsStringSync();
  
  content = content.replaceFirst(
'''                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        dataRowMinHeight: 60,
                        dataRowMaxHeight: 70,
                        headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                        headingRowColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                        ),''',
'''                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: DataTable(
                          dataRowMinHeight: 60,
                          dataRowMaxHeight: 70,
                          dividerThickness: 0.5,
                          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                          headingRowColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          ),'''
  );

  file.writeAsStringSync(content);
}

void main() {
  wrapTable('lib/dashboard/screens/programs/programs_screen.dart');
  wrapTable('lib/dashboard/screens/videos/videos_screen.dart');
}
