import 'package:flutter/material.dart';

/// Renders "N. Title" with a hanging indent: wrapped lines align under the
/// title text instead of orphaning the number on its own line.
class NumberedTitle extends StatelessWidget {
  final int number;
  final String text;
  final TextStyle? style;

  const NumberedTitle({super.key, required this.number, required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 26, child: Text('$number.', style: style)),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}
