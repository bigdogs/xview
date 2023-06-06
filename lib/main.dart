import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/views/pages/app.dart';
import 'package:xview/utils/util.dart';

void main() async {
  await preInitialize();

  const fontSize = 12.0;
  runApp(ProviderScope(
      child: MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'SF-Mono',
      textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: fontSize, height: 1.4),
          titleMedium: TextStyle(fontSize: fontSize)),
    ),
    home: const Scaffold(body: FileApp()),
  )));
}
