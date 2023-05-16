import 'package:flutter_riverpod/flutter_riverpod.dart';

class Position {
  // would it be better to add `currentIndex` to `filedata`? however, since
  // it changes frequently, I'm not sure if adding it to `filedata` would negatively impact performace
  final int clickedIndex;
  final int jumpTargetIndex;

  Position({this.clickedIndex = -1, this.jumpTargetIndex = -1});

  Position copy({int? clickedIndex, int? jumpTargetIndex}) {
    return Position(
      clickedIndex: clickedIndex ?? this.clickedIndex,
      jumpTargetIndex: jumpTargetIndex ?? this.jumpTargetIndex,
    );
  }
}

class PositionProvider extends Notifier<Position> {
  @override
  Position build() {
    state = Position();
    return state;
  }

  void clickIndex(int index) {
    state = state.copy(clickedIndex: index);
  }

  void jumpTo(int index) {
    state = state.copy(jumpTargetIndex: index);
  }
}

final positionProvider =
    NotifierProvider<PositionProvider, Position>(() => PositionProvider());
