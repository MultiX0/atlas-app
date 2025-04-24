import 'package:atlas_app/core/common/constants/fonts_constants.dart';
import 'package:flutter/material.dart';
import 'package:atlas_app/features/comics/widgets/rating_bar_display.dart';

class SingleRatingItem extends StatelessWidget {
  const SingleRatingItem({
    super.key,
    required this.label,
    required this.rating,
    this.color,
    this.labelStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
  });

  final String label;
  final double rating;
  final Color? color;
  final TextStyle? labelStyle;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                labelStyle ??
                const TextStyle(
                  fontFamily: arabicAccentFont,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
          ),
          RatingBarDisplay(rating: rating, color: color),
        ],
      ),
    );
  }
}
