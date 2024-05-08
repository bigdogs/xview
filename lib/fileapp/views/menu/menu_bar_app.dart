import 'package:flutter/material.dart';
import 'package:xview/fileapp/views/menu/menu_bar.dart';

class MenuBarApp extends StatefulWidget {
  final Widget child;
  final MenuAction action;

  const MenuBarApp({super.key, required this.child, required this.action});

  @override
  State<MenuBarApp> createState() => _MenuBarAppState();
}

class _MenuBarAppState extends State<MenuBarApp> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: MenuBar(
                children: <Widget>[
                  _buildMenuFile(context),
                  _buildMenuView(context),
                  _buildMenuEncoding(context),
                ],
              ),
            ),
          ],
        ),
        Expanded(child: widget.child),
      ],
    );
  }

  SubmenuButton _buildMenuFile(BuildContext context) {
    return SubmenuButton(
      menuChildren: <Widget>[
        MenuItemButton(
          // style: ButtonStyle(
          //     minimumSize: MaterialStateProperty.all(Size.fromWidth(200))),
          onPressed: () => widget.action.openFileDialog(),
          child: SizedBox(width: 20, child: MenuAcceleratorLabel('&Open...')),
        ),
        MenuItemButton(
          // style: ButtonStyle(
          //     minimumSize: MaterialStateProperty.all(Size.fromWidth(200))),
          onPressed: () => widget.action.openFileDialog(),
          child: SizedBox(width: 300, child: MenuAcceleratorLabel('&Open...')),
        )
      ],
      child: const MenuAcceleratorLabel('&File'),
    );
  }

  SubmenuButton _buildMenuView(BuildContext context) {
    return const SubmenuButton(
        menuChildren: [], child: MenuAcceleratorLabel('&View'));
  }

  SubmenuButton _buildMenuEncoding(BuildContext context) {
    return const SubmenuButton(
        menuChildren: [], child: MenuAcceleratorLabel('&Encoding'));
  }
}
