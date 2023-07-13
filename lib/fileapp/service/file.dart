// To handle large files, we will not read all content at once but return
// a maximum of 1000 lines at a time
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Stream<List<String>> readFileAsStream(String path) async* {
  const kMaxLine = 1000;
  final stream = File(path).openRead();
  final lines = stream.transform(utf8.decoder).transform(const LineSplitter());

  List<String> buffer = [];
  await for (final line in lines) {
    buffer.add(line);
    if (buffer.length >= kMaxLine) {
      yield buffer;
      buffer = [];
    }
  }
  if (buffer.isNotEmpty) {
    yield buffer;
  }
}

final _complete = Completer();
late String _dataDirectory;
Future<String> dataDirectory() async {
  ensureDataDirectory() async {
    final dir = await getApplicationSupportDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _dataDirectory = dir.toString();
    print("data directory; $_dataDirectory");
    _complete.complete(0);
  }

  // it seems like not correct..
  if (!_complete.isCompleted) {
    await ensureDataDirectory();
  }

  return _dataDirectory;
}
