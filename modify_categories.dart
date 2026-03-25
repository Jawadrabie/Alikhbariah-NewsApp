import 'dart:io';

void main() {
  File file = File('lib/dashboard/screens/categories/categories_screen.dart');
  String content = file.readAsStringSync();
  
  content = content.replaceFirst(
'''      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          dataRowMinHeight: 60,
          dataRowMaxHeight: 70,
          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
          headingRowColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
          ),''',
'''      return SingleChildScrollView(
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
            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
            headingRowColor: WidgetStatePropertyAll(
              Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ),'''
  );

  // If the old one was still present
  content = content.replaceFirst(
'''      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ),''',
'''      return SingleChildScrollView(
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
