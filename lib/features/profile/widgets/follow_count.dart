import 'package:atlas_app/features/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FollowCount extends StatelessWidget {
  final int count;
  final String text;
  const FollowCount({Key? key, required this.count, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double fontSize = 18;

    return Row(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(color: AppColors.mutedSilver, fontSize: fontSize)),
      ],
    );
  }
}
