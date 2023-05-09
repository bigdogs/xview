import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/utils/init.dart';
import 'package:xview/view/pages/home.dart';

void main() {
  beforeRunApp();

  const fontSize = 12.0;
  runApp(ProviderScope(
      child: MaterialApp(
    theme: ThemeData(
      fontFamily: 'SF-Mono',
      textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: fontSize, height: 1.4),
          titleMedium: TextStyle(fontSize: fontSize)),
    ),
    home: Scaffold(body: Home()),
  )));
}
