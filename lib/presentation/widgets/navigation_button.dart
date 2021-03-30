import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  NavigationButton({
    required this.text,
    required this.textStyle,
    required this.onPressed,
  });

  final String text;
  final TextStyle textStyle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Text(
        text,
        style: textStyle,
        maxLines: 1,
      ),
      onPressed: onPressed,
    );
  }
}
