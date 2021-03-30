import 'package:flutter/cupertino.dart';
import 'package:tada_messenger/presentation/theme/app_theme.dart';

class NavigationBarBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NavigationBarBackButton({
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBarBackButton(
      color: AppTheme.of(context).primaryColor,
      onPressed: onPressed,
      previousPageTitle: '',
    );
  }
}
