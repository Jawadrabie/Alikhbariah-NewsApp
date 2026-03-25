import 'dart:io';

void replaceDatatable(String path) {
  var file = File(path);
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  content = content.replaceAll(
    'child: DataTable(\n          headingRowColor: WidgetStatePropertyAll(\n            Theme.of(context).colorScheme.surfaceContainerHighest,\n          ),',
    'child: DataTable(\n          dataRowMinHeight: 60,\n          dataRowMaxHeight: 70,\n          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),\n          headingRowColor: WidgetStatePropertyAll(\n            Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),\n          ),'
  );
  content = content.replaceAll(
    'child: DataTable(\r\n          headingRowColor: WidgetStatePropertyAll(\r\n            Theme.of(context).colorScheme.surfaceContainerHighest,\r\n          ),',
    'child: DataTable(\n          dataRowMinHeight: 60,\n          dataRowMaxHeight: 70,\n          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),\n          headingRowColor: WidgetStatePropertyAll(\n            Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),\n          ),'
  );
  file.writeAsStringSync(content);
}

void main() {
  replaceDatatable('lib/dashboard/screens/categories/categories_screen.dart');
}
