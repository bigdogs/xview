import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// setting that need to keep to
class Setting {
  double percentOfFilterView;

  Setting({this.percentOfFilterView = 0.2});

  Setting copy({double? percentOfFilterView}) {
    return Setting(
      percentOfFilterView: percentOfFilterView ?? this.percentOfFilterView,
    );
  }
}
