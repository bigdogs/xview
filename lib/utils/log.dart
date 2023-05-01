import 'package:logging/logging.dart';

final log = Logger("vix")
  ..level = Level.ALL
  ..onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
