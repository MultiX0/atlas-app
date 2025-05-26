import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class GeneralLoading extends StatelessWidget {
  const GeneralLoading({super.key, this.single = false});
  final bool single;

  @override
  Widget build(BuildContext context) {
    final List<double> heights = [
      200,
      250,
      180,
      300,
      220,
      280,
      160,
      240,
      190,
      270,
      210,
      320,
      170,
      260,
      230,
      290,
      150,
      340,
      200,
      310,
    ];

    if (single) {
      return Padding(
        padding: const EdgeInsets.all(18.0),
        child: _LoadingWidget(heights: heights, index: 0),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      itemCount: 20,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        return _LoadingWidget(heights: heights, index: index);
      },
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget({required this.heights, required this.index});

  final List<double> heights;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[400]!,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main image placeholder
            Container(height: heights[index % heights.length] - 60, color: Colors.grey[600]),
            const SizedBox(height: 8),
            // Title placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(height: 16, width: double.infinity, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            // Subtitle placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                height: 12,
                width: MediaQuery.of(context).size.width * 0.3,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
