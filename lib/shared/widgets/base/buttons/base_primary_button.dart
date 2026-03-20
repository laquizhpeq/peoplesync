import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

class BasePrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;

  const BasePrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(onPressed: onPressed, child: child),
    );
  }
}

@Preview(name: 'BasePrimaryButton')
Widget basePrimaryButtonPreview() =>
    const BasePrimaryButton(onPressed: null, child: Text('BasePrimaryButton'));
