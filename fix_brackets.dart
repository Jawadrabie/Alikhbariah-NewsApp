import 'dart:io';

void fixFile(String path) {
  File file = File(path);
  if (!file.existsSync()) return;
  String content = file.readAsStringSync();
  content = content.replaceAll('], // rows', '],\n                        ), // DataTable\n                      ), // Container');
  
  content = content.replaceAll(
    ''',
          rows: categories
              .map(
                (c) => DataRow(''',
    ''',
            rows: categories
                .map(
                  (c) => DataRow('''
  );
  content = content.replaceAll(
    '''),
                ],
              ),
            );
          },
        ),
      );
    }''',
    '''),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }'''
  );

  file.writeAsStringSync(content);
}

void main() {
  // fixFile('lib/dashboard/screens/categories/categories_screen.dart');
  // fixFile('lib/dashboard/screens/programs/programs_screen.dart');
}
