import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileView extends ConsumerStatefulWidget {
  final String fileId;

  const FileView({super.key, required this.fileId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _FileViewState();
  }

  static String id(BuildContext context) {
    return (context.getElementForInheritedWidgetOfExactType<_FileId>()!.widget
            as _FileId)
        .id;
  }
}

class _FileViewState extends ConsumerState {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class _FileId extends InheritedWidget {
  final String id;

  const _FileId({required this.id, required super.child});

  @override
  bool updateShouldNotify(covariant _FileId oldWidget) {
    return id == oldWidget.id;
  }
}
