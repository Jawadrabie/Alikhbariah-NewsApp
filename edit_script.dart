import 'dart:io';

void main() {
  final file = File(
    'lib/dashboard/screens/breaking_news/edit_breaking_news_screen.dart',
  );
  var content = file.readAsStringSync();

  if (!content.contains('dashboard_form_container.dart')) {
    content = content.replaceFirst(
      "import 'package:newsappjs/dashboard/widgets/custom_form_fields.dart';",
      "import 'package:newsappjs/dashboard/widgets/custom_form_fields.dart';\n"
          "import 'package:newsappjs/dashboard/widgets/dashboard_form_container.dart';",
    );
  }

  content = content.replaceFirst(
    "      body: Padding(\n        padding: const EdgeInsets.all(16.0),\n        child: Form(",
    "      body: SingleChildScrollView(\n"
        "        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),\n"
        "        child: DashboardFormContainer(\n"
        "          child: Form(",
  );

  content = content.replaceFirst(
    '''            child: SingleChildScrollView(
              child: Column(
                children: [''',
    '''            child: Column(
              children: [''',
  );

  file.writeAsStringSync(content);
}
