// ignore_for_file: avoid_print

import 'package:logging/logging.dart';

final log = Logger("xview")
  ..level = Level.INFO
  ..onRecord.listen((record) {
    print('[${record.level.name}] ${record.time}: ${record.message}');
  });

final textlistLog = Logger("textlist")
  ..level = Level.ALL
  ..onRecord.listen((record) {
    // print('[textlist] ${record.time}: ${record.message}');
  });
