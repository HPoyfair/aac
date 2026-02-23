import 'package:go_router/go_router.dart';

import '../features/boards/presentation/pages/boards_list_page.dart';
import '../features/boards/presentation/pages/board_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BoardsListPage(),
    ),
    GoRoute(
      path: '/board/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BoardPage(boardId: id);
      },
    ),
  ],
);