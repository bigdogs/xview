import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/views/menu/menu_bar.dart';
import 'package:xview/fileapp/views/pages/app.dart';
import 'package:xview/utils/util.dart';

void main(List<String> args) async {
  await preInitialize();
  startArgs = args;

  runApp(ProviderScope(
      child: MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: defaultFontFamily(),
      menuButtonTheme: const MenuButtonThemeData(
          style: ButtonStyle(
              textStyle: MaterialStatePropertyAll(TextStyle(fontSize: 12)),
              padding: MaterialStatePropertyAll(
                  EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4)),
              minimumSize: MaterialStatePropertyAll(Size(12, 32)))),
      menuBarTheme: const MenuBarThemeData(
          style: MenuStyle(
        shape: MaterialStatePropertyAll(RoundedRectangleBorder()),
        elevation: MaterialStatePropertyAll(0),
        backgroundColor: MaterialStatePropertyAll(Colors.white),
        fixedSize: MaterialStatePropertyAll(Size.infinite),
        side: MaterialStatePropertyAll(BorderSide.none),
        padding: MaterialStatePropertyAll(EdgeInsets.zero),
      )),
      textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: defaultFontSize, height: 1.4),
          titleMedium: TextStyle(fontSize: defaultFontSize)),
    ),
    home: const Scaffold(body: CustomMenuBar(child: FileApp())),
  )));
}
