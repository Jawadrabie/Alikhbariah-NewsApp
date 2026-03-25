import 'dart:io';

void main() {
  File file = File('lib/dashboard/screens/main_news/edit_news_screen.dart');
  String content = file.readAsStringSync();
  
  if (!content.contains('dashboard_form_container.dart')) {
    content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:newsappjs/dashboard/widgets/dashboard_form_container.dart';");
  }

  // Replace start of body
  content = content.replaceAll(
'''      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Fixed fields at top
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [''',
'''      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: DashboardFormContainer(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: ['''
  );

  // Replace end of body
  content = content.replaceAll(
'''                        ], // Column children
                      ), // Column
                    ), // SingleChildScrollView
                  ), // Expanded''',
'''                        // Column children'''
  );

  content = content.replaceAll(
'''            ), // Form
          ), // Padding
        ), // ConstrainedBox
      ), // Center''',
'''            ), // Form
        ), // DashboardFormContainer
      ), // SingleChildScrollView'''
  );

  file.writeAsStringSync(content);
}
