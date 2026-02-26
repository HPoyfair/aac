import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/boards_provider.dart';
import 'package:go_router/go_router.dart';


//creates new boards and shows all current boards.
/*
draw the screen (AppBar, ListView, buttons)

respond to taps

show whatever data it’s given
*/

class BoardsListPage extends ConsumerWidget {
  const BoardsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boards = ref.watch(boardsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Boards')),
      body: ListView.builder(
        itemCount: boards.length,
        itemBuilder: (context, index) {
          final board = boards[index];
          return ListTile(
        title: Text(board.name),
        onTap: () {
          context.go('/board/${board.id}');
  },
);
        },
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () async {
    final nameController = TextEditingController();

    // Default layout
    int selectedRows = 3;
    int selectedColumns = 3;

    final presets = const [
      (3, 3),
      (4, 4),
      (5, 5),
      (3, 5),
      (5, 3),
    ];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('New Board'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Board name',
                      hintText: 'e.g., Food',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Layout',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: '${selectedRows}x$selectedColumns',
                    items: [
                      for (final (r, c) in presets)
                        DropdownMenuItem(
                          value: '${r}x$c',
                          child: Text('${r} × $c'),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      final parts = value.split('x');
                      setState(() {
                        selectedRows = int.parse(parts[0]);
                        selectedColumns = int.parse(parts[1]);
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    Navigator.of(context).pop({
                      'name': name,
                      'rows': selectedRows,
                      'columns': selectedColumns,
                    });
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    ref.read(boardsProvider.notifier).addBoard(
      name: result['name'] as String,
      rows: result['rows'] as int,
      columns: result['columns'] as int,
    );
  },
  child: const Icon(Icons.add),
),
    );
  }
}