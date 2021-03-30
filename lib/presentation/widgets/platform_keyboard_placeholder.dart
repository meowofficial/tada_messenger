import 'dart:math';

import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

enum PlatformKeyboardPlaceholderMode {
  smooth,
  sharp,
}

class PlatformKeyboardPlaceholder extends StatelessWidget {
  const PlatformKeyboardPlaceholder({
    this.backgroundColor = Colors.transparent,
    this.mode = PlatformKeyboardPlaceholderMode.smooth,
  });

  final Color backgroundColor;
  final PlatformKeyboardPlaceholderMode mode;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case PlatformKeyboardPlaceholderMode.smooth:
        return KeyboardAttachable(
          backgroundColor: backgroundColor,
        );
      case PlatformKeyboardPlaceholderMode.sharp:
        return Container(
          color: backgroundColor,
          height: max(0, MediaQuery.of(context).viewInsets.bottom),
        );
      default:
        return Container();
    }
  }
}
