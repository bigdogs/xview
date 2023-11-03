// To handle large files, we will not read all content at once but return
// a maximum of 1000 lines at a time
import 'dart:async';
import 'dart:convert';
import 'dart:io';


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


