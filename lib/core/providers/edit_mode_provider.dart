import 'package:flutter_riverpod/flutter_riverpod.dart';

final editModeProvider =
    NotifierProvider<EditModeNotifier, bool>(EditModeNotifier.new);

class EditModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void set(bool value) => state = value;
}