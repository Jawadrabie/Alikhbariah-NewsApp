import 'dart:io';

void replaceTable(String path) {
  File file = File(path);
  if (!file.existsSync()) return;
  String content = file.readAsStringSync();
  
  // Replace the opening of DataTable
  final pattern = RegExp(r'child:\s*DataTable\(');
  if (content.contains(pattern)) {
    content = content.replaceAll(pattern, '''child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: DataTable(
          dataRowMinHeight: 60,
          dataRowMaxHeight: 70,
          columnSpacing: 32,
          horizontalMargin: 24,
          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),''');
    
    // Now we must close the container at the end.
    // The problem is finding the end of the DataTable. 
    // They usually end with .toList(),\n      ),\n    );
    content = content.replaceAll(
      '.toList(),\n            ),', 
      '.toList(),\n            ),\n          ),'
    );
    content = content.replaceAll(
      '.toList(),\n          ),', 
      '.toList(),\n          ),\n        ),'
    );
    content = content.replaceAll(
      '.toList(),\n                      ),', 
      '.toList(),\n                      ),\n                    ),'
    );
    
    // Let's also fix the header color to be more transparent
    content = content.replaceAll(
      'Theme.of(context).colorScheme.surfaceContainerHighest,',
      'Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),'
    );
  }

  file.writeAsStringSync(content);
}

void main() {
  replaceTable('lib/dashboard/screens/categories/categories_screen.dart');
  replaceTable('lib/dashboard/screens/programs/programs_screen.dart');
  replaceTable('lib/dashboard/screens/videos/videos_screen.dart');
}
