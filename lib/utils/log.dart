// ignore_for_file: avoid_print

import 'package:async/async.dart';
import 'package:logging/logging.dart';

import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:xview/utils/util.dart';

class FileLogger {
  static final AsyncMemoizer<File> _file = AsyncMemoizer();
  static Future<void> writeLogToFile(String log) async {
    final f = await _file.runOnce(() async {
      final logFile = File(path.join(await dataDirectory(), "xview.log"));
      // delete pervious file if it is exist
      if (await logFile.exists()) {
        await logFile.delete();
      }
      return logFile;
    });

    // Must be sync, otherwise writing data will be overlapped (don't know why)
    f.writeAsStringSync('$log\n', mode: FileMode.append);
  }
}

final log = Logger("xview")
  ..level = Level.INFO
  ..onRecord.listen((record) {
    final s = '[${record.level.name}] ${record.time}: ${record.message}';
    print(s);
    Future.sync(() => FileLogger.writeLogToFile(s));
  });

final textlistLog = Logger("textlist")
  ..level = Level.ALL
  ..onRecord.listen((record) {
    // print('[textlist] ${record.time}: ${record.message}');
  });
