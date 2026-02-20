import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../data/models/program_model.dart';
import '../../data/repositories/media_repository.dart';
import 'videos_screen.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  final MediaRepository _repository = MediaRepository();
  late Future<List<ProgramModel>> _programsFuture;

  @override
  void initState() {
    super.initState();
    _programsFuture = _repository.getPrograms();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.programs)),
      body: FutureBuilder<List<ProgramModel>>(
        future: _programsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(l10n.failedLoadPrograms(snapshot.error.toString())));
          }

          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return Center(child: Text(l10n.noProgramsNow));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.name, textDirection: TextDirection.rtl),
                subtitle: item.description == null || item.description!.isEmpty
                    ? null
                    : Text(item.description!, textDirection: TextDirection.rtl),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideosScreen(
                        programId: item.id,
                        programName: item.name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
