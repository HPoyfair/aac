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
        onPressed: () {
          ref.read(boardsProvider.notifier).addBoard('New Board');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}