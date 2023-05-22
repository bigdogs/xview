import 'package:flutter_riverpod/flutter_riverpod.dart';

class Position {
  final int clickedIndex;
  final int jumpTargetIndex;
  final int jumpCount;

  Position(
      {this.clickedIndex = -1, this.jumpTargetIndex = -1, this.jumpCount = 0});

  Position copy({int? clickedIndex, int? jumpTargetIndex, int? jumpCount}) {
    return Position(
        clickedIndex: clickedIndex ?? this.clickedIndex,
        jumpTargetIndex: jumpTargetIndex ?? this.jumpTargetIndex,
        jumpCount: jumpCount ?? this.jumpCount);
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
    state = state.copy(jumpTargetIndex: index, jumpCount: state.jumpCount + 1);
  }
}

final positionProvider =
    NotifierProvider<PositionProvider, Position>(() => PositionProvider());
