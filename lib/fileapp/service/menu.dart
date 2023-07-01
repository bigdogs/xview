import 'package:xview/utils/log.dart';

class ViewMenuItem {
  final String label;
  final Function()? onTap;
  const ViewMenuItem({required this.label, this.onTap});
}

class ViewerMenuGroup {
  final String? label;
  final List<ViewMenuItem> items;
  const ViewerMenuGroup({required this.items, this.label});
}

class ViewerMenu {
  final List<ViewerMenuGroup> groups;
  final String? label;
  const ViewerMenu({required this.groups, this.label});
}

class ViewerMenuBar {
  final List<ViewerMenu> menus;
  const ViewerMenuBar({required this.menus});
}

// we don't need multiple menu tree
ViewerMenuBar systemMenuBar() {
  return ViewerMenuBar(menus: [
    ViewerMenu(label: 'Flutter API Sample', groups: [
      ViewerMenuGroup(items: [
        ViewMenuItem(
          label: 'About',
          onTap: () {
            log.info('About clicked');
          },
        )
      ]),
    ])
  ]);
}
