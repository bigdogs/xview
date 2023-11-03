
import 'package:hive_flutter/hive_flutter.dart';
import 'package:xview/utils/util.dart';

const String kBoxFileView = "file_view";

abstract class FileViewBox {
  static late Box<Map> _box;

  static ensureBox() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(kBoxFileView, path: await dataDirectory());
  }

  static List<String> allKeys() => _box.keys.whereType<String>().toList();

  static put(String fileId, Map value) async {
    await _box.put(fileId, value);
  }

  static Map? get(String fileId) => _box.get(fileId);

  static delete(String fileId) async {
    await _box.delete(fileId);
  }
}
