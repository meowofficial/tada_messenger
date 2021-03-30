import 'package:flutter/material.dart';
import 'package:tada_messenger/presentation/theme/app_theme.dart';

class PlatformDivider extends StatelessWidget {
  PlatformDivider()
      : indentColor = Colors.transparent,
        indent = 0,
        endIndent = 0;

  PlatformDivider.withIndent({
    this.indentColor = Colors.transparent,
    this.indent = 0,
    this.endIndent = 0,
  });

  final Color indentColor;
  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    final dividerThickness = MediaQuery.of(context).devicePixelRatio < 2
        ? 0.0
        : 1 / MediaQuery.of(context).devicePixelRatio;
    return Container(
      width: double.infinity,
      color: indentColor,
      child: Padding(
        padding: EdgeInsets.only(
          left: indent,
          right: endIndent,
        ),
        child: Container(
          color: AppTheme.of(context).dividerColor,
          height: dividerThickness,
          child: Divider(
            color: AppTheme.of(context).dividerColor,
            height: 0,
            thickness: dividerThickness,
          ),
        ),
      ),
    );
  }
}
