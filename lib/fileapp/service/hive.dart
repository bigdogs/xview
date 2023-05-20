import 'package:hive_flutter/hive_flutter.dart';

const String kBoxFileView = "file_view";

Future<void> initHiveBox() async {
  await Hive.initFlutter();
}

abstract class FileViewBox {
  // Although using global variable is not recommanded,
  // I'm currently unsure of how to improve this situation
  static Box<Map>? _instance;

  static Future<Box<Map>> _box() async {
    if (_instance != null) {
      return Future.value(_instance);
    }
    _instance = await Hive.openBox(kBoxFileView);
    return Future.value(_instance);
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
