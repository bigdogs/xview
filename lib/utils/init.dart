// init process before `runApp`
import 'package:logging/logging.dart';

void beforeRunApp() {
  // log
  hierarchicalLoggingEnabled = true;
}
