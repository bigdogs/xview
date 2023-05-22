import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

const String kBoxFileView = "file_view";

// wait init complete
final _complete = Completer();

Future<void> initHiveBox() async {
  await Hive.initFlutter();
  FileViewBox._instance = await Hive.openBox(kBoxFileView);
  _complete.complete(0);
}

abstract class FileViewBox {
  // Although using global variable is not recommanded,
  // I'm currently unsure of how to improve this situation
  static late Box<Map> _instance;

  static Future<Box<Map>> _box() async {
    if (_complete.isCompleted) {
      return _instance;
    }
    await _complete.future;
    return _instance;
  }

  static Future<List<String>> allKeys() async =>
      _box().then((v) => List<String>.from(v.keys.toList()));

  static put(String fileId, Map value) async {
    await (await _box()).put(fileId, value);
  }

  static Future<Map?> get(String fileId) async =>
      _box().then((value) => value.get(fileId));

  static delete(String fileId) async {
    await (await _box()).delete(fileId);
  }
}
