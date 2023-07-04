import 'package:flutter/material.dart';
import 'package:xview/utils/consts.dart';

class MenuBarApp extends StatefulWidget {
  final Widget child;

  const MenuBarApp({super.key, required this.child});

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
}

SubmenuButton _buildMenuFile(BuildContext context) {
  return SubmenuButton(
    menuChildren: <Widget>[
      MenuItemButton(
        onPressed: () {
          showAboutDialog(
            context: context,
            applicationName: 'MenuBar Sample',
            applicationVersion: '1.0.0',
          );
        },
        child: const MenuAcceleratorLabel('&Abouthahahahahahahhahhhhhhh'),
      ),
      MenuItemButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Saved!'),
            ),
          );
        },
        child: const MenuAcceleratorLabel('&Save'),
      ),
      MenuItemButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quit!'),
            ),
          );
        },
        child: const MenuAcceleratorLabel('&Quit'),
      ),
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
