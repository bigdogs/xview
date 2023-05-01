import 'dart:math';

import 'package:flutter/material.dart';
import 'package:xview/view/pages/filter_page.dart';
import 'package:xview/view/pages/main_page.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  double percent = 0.2;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrinat) {
      return Column(
        children: [
          Expanded(child: MainPage()),
          MouseRegion(
            cursor: SystemMouseCursors.resizeUpDown,
            child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) =>
                    _changeViewFilterHeight(details, constrinat.maxHeight),
                child: const Divider(height: 4)),
          ),
          SizedBox(height: percent * constrinat.maxHeight, child: FilterPage()),
        ],
      );
    });
  }

  void _changeViewFilterHeight(DragUpdateDetails details, double totalHeight) {
    double p = (percent * totalHeight - details.delta.dy) / totalHeight;
    p = p.clamp(0.1, 0.9);

    setState(() {
      percent = p;
    });
  }
}
