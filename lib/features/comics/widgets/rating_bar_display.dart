import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Assuming this is the package used

/// A reusable, non-interactive rating bar widget that displays a rating with customizable stars.
class RatingBarDisplay extends StatelessWidget {
  const RatingBarDisplay({
    super.key,
    required this.rating,
    this.color,
    this.itemSize = 18.0,
    this.itemCount = 5,
    this.icon = Icons.star,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 2.0),
  });

  /// The rating value (e.g., 3.5 for 3.5 stars).
  final double rating;

  /// The color of the stars. Defaults to [ThemeData.primaryColor] if not provided.
  final Color? color;

  /// The size of each star icon. Defaults to 18.0.
  final double itemSize;

  /// The total number of stars. Defaults to 5.
  final int itemCount;

  /// The icon to use for the rating (e.g., star, heart). Defaults to [Icons.star].
  final IconData icon;

  /// Padding between stars. Defaults to 2.0 pixels horizontally.
  final EdgeInsets itemPadding;

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Theme.of(context).primaryColor; // Fallback to theme's primary color
    return RatingBarIndicator(
      direction: Axis.horizontal,
      itemCount: itemCount,
      rating: rating,
      itemSize: itemSize,
      itemPadding: itemPadding,
      itemBuilder: (context, _) => Icon(icon, color: starColor),
      physics: const NeverScrollableScrollPhysics(),
    );
  }
}
