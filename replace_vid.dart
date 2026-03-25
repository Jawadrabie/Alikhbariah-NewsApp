import 'dart:io';

void main() {
  File file = File('lib/dashboard/screens/videos/videos_screen.dart');
  String content = file.readAsStringSync();
  
  // Table 1
  content = content.replaceFirst(
'''                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),''',
'''                    : Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            dataRowMinHeight: 60,
                            dataRowMaxHeight: 70,
                            columnSpacing: 32,
                            horizontalMargin: 24,
                            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                            dividerThickness: 0.5,
                            headingRowColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            ),'''
  );

  content = content.replaceFirst(
'''                              .toList(),
                        ),
                      ),''',
'''                              .toList(),
                          ),
                        ),
                      ),'''
  );

  // Table 2
  content = content.replaceFirst(
'''                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),''',
'''                  : Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          dataRowMinHeight: 60,
                          dataRowMaxHeight: 70,
                          columnSpacing: 32,
                          horizontalMargin: 24,
                          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                          dividerThickness: 0.5,
                          headingRowColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          ),'''
  );
  
  // Note: the end of table 2 looks different?
  // It's the end of the file.
  content = content.replaceFirst(
'''                            .toList(),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}''',
'''                            .toList(),
                        ),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}'''
  );
  
  file.writeAsStringSync(content);
}
