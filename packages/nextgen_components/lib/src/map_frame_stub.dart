import 'package:flutter/widgets.dart';

Widget mapFrame(
  String config,
  String label,
  ValueChanged<String> onEvent,
) => const Center(
  child: Text(
    'Map is currently available on Web only. Native platforms will be verified separately.',
  ),
);
