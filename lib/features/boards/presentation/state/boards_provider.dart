import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/board.dart';
import '../domain/tile.dart';


/*
holds the current list of boards in memory

provides methods to change that list (add/delete/rename)

later: loads/saves boards from storage

*/

final boardsProvider =
    NotifierProvider<BoardsNotifier, List<Board>>(BoardsNotifier.new);

class BoardsNotifier extends Notifier<List<Board>>{
  @override
  List<Board> build(){
    return const [
    Board(
      id: 'home',
      name: 'Home',
      tiles: [
        Tile(id: 't1', label: 'Hello'),
        Tile(id: 't2', label: 'Help'),
        Tile(id: 't3', label: 'Drink'),
        Tile(id: 't4', label: 'Bathroom'),
      ],
    ),
];
  }



  void addBoard(String name){
    final newBoard = Board(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );

    state = [...state, newBoard];
  }



  void addTile({
  required String boardId,
  required String label,
}) {
  final newTile = Tile(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    label: label,
  );

  state = [
    for (final board in state)
      if (board.id == boardId)
        board.copyWith(tiles: [...board.tiles, newTile])
      else
        board,
  ];
}




}

