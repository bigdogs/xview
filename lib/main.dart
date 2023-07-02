import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/fileapp/views/menu/menu_bar.dart';
import 'package:xview/fileapp/views/pages/app.dart';
import 'package:xview/utils/util.dart';

void main() async {
  await preInitialize();

  /*
    final ButtonStyle bs = ButtonStyle(
        textStyle: MaterialStatePropertyAll(TextStyle(fontSize: 16)));
  */
  const fontSize = 12.0;
  runApp(ProviderScope(
      child: MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'SF-Mono',
      dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle:
              MenuStyle(backgroundColor: MaterialStatePropertyAll(Colors.red))),
      menuButtonTheme: const MenuButtonThemeData(
        style: ButtonStyle(
            textStyle: MaterialStatePropertyAll(TextStyle(fontSize: 10)),
            backgroundColor: MaterialStatePropertyAll(Colors.green)),
      ),
      menuBarTheme: const MenuBarThemeData(
          style: MenuStyle(
              elevation: MaterialStatePropertyAll(10),
              backgroundColor: MaterialStatePropertyAll(Colors.yellow),
              fixedSize: MaterialStatePropertyAll(Size.fromHeight(32)))),
      textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: fontSize, height: 1.4),
          titleMedium: TextStyle(fontSize: fontSize)),
    ),
    home: const Scaffold(body: CustomMenuBar(child: FileApp())),
  )));
}
