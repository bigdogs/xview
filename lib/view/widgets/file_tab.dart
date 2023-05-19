import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:xview/utils/icons.dart';

class FileTab extends StatefulWidget {
  final String path;

  const FileTab({super.key, required this.path});

  @override
  State<StatefulWidget> createState() {
    return _FileTabState();
  }
}

class _FileTabState extends State<FileTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color.fromARGB(255, 210, 231, 255),
        height: 30,
        padding: const EdgeInsets.only(left: 2, right: 16),
        child: Row(children: [
          Container(
            width: 1,
            height: 30 * 0.6,
            color: const Color.fromARGB(255, 230, 230, 230),
          ),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                XIcons.close,
                size: 16,
              )),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                XIcons.file,
                size: 14,
                color: Color.fromARGB(255, 95, 114, 127),
              )),
          Text(
            basename(widget.path),
            style: const TextStyle(color: Color.fromARGB(255, 12, 118, 247)),
          ),
        ]));
  }
}
