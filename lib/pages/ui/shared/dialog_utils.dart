import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog(BuildContext context, String message) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(Icons.warning, color: Theme.of(context).colorScheme.primary),
      title: Text(
        'Bạn có chắc?',
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      content: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ActionButton(
                actionText: 'Không',
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
            ),
            Expanded(
              child: ActionButton(
                actionText: 'Có',
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Future<void> showErrorDialog(BuildContext context, String message) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(Icons.error, color: Colors.red),
      title: Text(
        'Có lỗi xảy ra',
        style: TextStyle(color: Colors.red),
      ),
      content: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
      ),
      actions: <Widget>[
        ActionButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        ),
      ],
    ),
  );
}

class ActionButton extends StatelessWidget {
  final String? actionText;
  final void Function()? onPressed;

  const ActionButton({
    super.key,
    this.actionText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary, padding: const EdgeInsets.symmetric(vertical: 14), // Điều chỉnh padding
      ),
      child: Text(
        actionText ?? 'Okay',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18, // Kích thước chữ
            ),
      ),
    );
  }
}
