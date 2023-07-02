import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:xview/fileapp/views/menu/menu_bar_app.dart';
import 'package:xview/fileapp/views/menu/menu_bar_macos.dart';

// an MenuBar adaptor for macos and windows
class CustomMenuBar extends StatelessWidget {
  final Widget child;

  const CustomMenuBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    Widget w = child;

    if (Platform.isMacOS) {
      w = MenuBarMacos(child: w);
    }

    w = MenuBarApp(child: w);
    return w;
  }
}
