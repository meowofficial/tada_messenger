import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tada_messenger/presentation/theme/app_theme.dart';

class MaterialAlertDialog extends StatelessWidget {
  MaterialAlertDialog({
    required this.actions,
    this.title,
    this.content,
  });

  final String? title;
  final String? content;
  final List<MaterialAlertDialogAction> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        child: Container(
          color: AppTheme.of(context).materialAlertDialogBackgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 16,
                  bottom: 8,
                  left: 20,
                  right: 20,
                ),
                child: Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: AppTheme.of(context).textTheme.materialAlertDialogTitle,
                          textAlign: TextAlign.left,
                        ),
                      if (title != null && content != null)
                        SizedBox(
                          height: 8,
                        ),
                      if (content != null)
                        Text(
                          content!,
                          style: AppTheme.of(context).textTheme.materialAlertDialogContent,
                          textAlign: TextAlign.left,
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions.map((action) {
                    return CupertinoButton(
                      padding: EdgeInsets.all(10),
                      minSize: 0,
                      child: Text(
                        action.title.toUpperCase(),
                        style: AppTheme.of(context).textTheme.materialAlertDialogActionTitle,
                      ),
                      onPressed: action.onPressed,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MaterialAlertDialogAction {
  MaterialAlertDialogAction({
    required this.title,
    required this.onPressed,
  });

  final String title;
  final VoidCallback onPressed;
}
