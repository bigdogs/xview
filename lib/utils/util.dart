// init process before `runApp`

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xview/fileapp/service/hive.dart';

const kAppName = 'xview';

preInitialize() async {
  WidgetsFlutterBinding.ensureInitialized();

  // https://github.com/leanflutter/window_manager/issues/335
  await WindowManager.instance.ensureInitialized();
  WindowManager.instance.setMinimumSize(const Size(480, 320));

  // log
  hierarchicalLoggingEnabled = true;
  // local storage
  initHiveBox();
}
