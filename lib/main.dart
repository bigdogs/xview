import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xview/utils/init.dart';
import 'package:xview/view/pages/home.dart';

void main() {
  beforeRunApp();
  runApp(ProviderScope(
      child: MaterialApp(
    theme: ThemeData(fontFamily: 'Segoe UI'),
    home: Scaffold(body: Home()),
  )));
}
