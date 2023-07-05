import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xview/fileapp/views/menu/menu_bar.dart';

class MenuBarMacos extends StatefulWidget {
  final Widget child;
  final MenuAction action;

  const MenuBarMacos({super.key, required this.child, required this.action});

  @override
  State<MenuBarMacos> createState() => _MenuBarMacosState();
}

class _MenuBarMacosState extends State<MenuBarMacos> {
  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: <PlatformMenuItem>[
        PlatformMenu(
          label: '',
          menus: <PlatformMenuItem>[
            if (PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.quit))
              const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.quit),
          ],
        ),
        PlatformMenu(label: 'File', menus: [
          PlatformMenuItem(
            label: 'Open...',
            shortcut:
                const SingleActivator(LogicalKeyboardKey.keyO, meta: true),
            onSelected: () => widget.action.openFileDialog(),
          ),
        ]),
      ],
      child: widget.child,
    );
  }
}
