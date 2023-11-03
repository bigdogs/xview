// init process before `runApp`

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xview/fileapp/service/hive.dart';
import 'package:xview/utils/log.dart';
import 'package:async/async.dart';

preInitialize() async {
  WidgetsFlutterBinding.ensureInitialized();

  // https://github.com/leanflutter/window_manager/issues/335
  await WindowManager.instance.ensureInitialized();
  WindowManager.instance.setMinimumSize(const Size(480, 320));

  // log
  hierarchicalLoggingEnabled = true;
  // 
  await FileViewBox.ensureBox();
}

String defaultFontFamily() {
  if (Platform.isWindows) {
    return 'MicrosoftYaHei';
  } else {
    return 'SF-Mono';
  }
}

// macos should be `12`, I don't know how to make it `const`
const double defaultFontSize = 13;

late List<String> startArgs;

final AsyncMemoizer<String> _dataDirectory = AsyncMemoizer<String>();
Future<String> dataDirectory() async {
  return _dataDirectory.runOnce(
    () async {
      final dir = await getApplicationSupportDirectory();
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      log.info("data directory: ${dir.path}");

      return dir.path;
    },
  );
}
