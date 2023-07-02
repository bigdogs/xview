import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuBarMacos extends StatefulWidget {
  final Widget child;

  const MenuBarMacos({super.key, required this.child});

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
            onSelected: () {
              () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(allowMultiple: true);

                if (result != null) {
                  List<String?> files =
                      result.paths.map((path) => path).toList();
                  print('use choose files: $files');
                } else {
                  // User canceled the picker
                  print('file picker.. user cancel that...');
                }
              }();
            },
          ),
        ]),
      ],
      child: widget.child,
    );
  }
}
