import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SizableButton extends StatelessWidget {
  SizableButton({
    required this.child,
    required this.color,
    required this.onPressed,
    required this.borderRadius,
    this.height,
    this.width,
  });

  final Color color;
  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        child: Opacity(
          opacity: onPressed == null ? 0.3 : 1.0,
          child: Material(
            child: Ink(
              width: width,
              height: height,
              child: Container(
                color: color,
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: child,
                ),
              ),
            ),
          ),
        ),
        onPressed: onPressed,
        pressedOpacity: 0.3,
      ),
    );
  }
}
