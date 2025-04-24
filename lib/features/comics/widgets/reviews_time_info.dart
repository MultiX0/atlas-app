import 'package:atlas_app/core/common/constants/fonts_constants.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewTimeInfo extends StatelessWidget {
  const ReviewTimeInfo({
    super.key,
    required this.createdAt,
    this.updatedAt,
    this.textStyle = const TextStyle(fontSize: 12, fontFamily: arabicAccentFont),
  });

  final DateTime createdAt;
  final DateTime? updatedAt;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final date = timeago.format(createdAt, locale: 'ar');
    final text = updatedAt == null ? date : "$date (محدث)";
    return Text(text, style: textStyle);
  }
}
