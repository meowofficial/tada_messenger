import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tada_messenger/presentation/theme/app_theme.dart';
import 'package:tada_messenger/presentation/widgets/platform_divider.dart';

class MenuGroupHeader extends StatelessWidget {
  const MenuGroupHeader({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 6,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTheme.of(context).textTheme.menuGroupTitle,
      ),
    );
  }
}

class MenuGroupFooter extends StatelessWidget {
  const MenuGroupFooter({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 7.5,
      ),
      child: Text(
        title,
        style: AppTheme.of(context).textTheme.menuGroupTitle,
      ),
    );
  }
}

class MenuGroup extends StatelessWidget {
  MenuGroup({
    required this.items,
    this.header,
    this.footer,
  });

  final List<Widget> items;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final dividedItems = <Widget>[
      PlatformDivider(),
    ];

    for (int i = 0; i < items.length; i++) {
      dividedItems.add(items[i]);
      dividedItems.add(PlatformDivider());
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) header!,
          if (items.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: dividedItems,
            ),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}
