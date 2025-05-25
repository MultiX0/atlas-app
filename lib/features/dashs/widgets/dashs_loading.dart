import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MasonryShimmerLoading extends StatelessWidget {
  const MasonryShimmerLoading({super.key});

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

    return MasonryGridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      itemCount: 20,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[400]!,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(height: heights[index % heights.length], color: Colors.grey[600]),
          ),
        );
      },
    );
  }
}

// class MasonryShimmerLoadingDetailed extends StatelessWidget {
//   const MasonryShimmerLoadingDetailed({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final List<double> heights = [
//       200,
//       250,
//       180,
//       300,
//       220,
//       280,
//       160,
//       240,
//       190,
//       270,
//       210,
//       320,
//       170,
//       260,
//       230,
//       290,
//       150,
//       340,
//       200,
//       310,
//     ];

//     return MasonryGridView.builder(
//       padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//       itemCount: 20,
//       mainAxisSpacing: 10,
//       crossAxisSpacing: 10,
//       gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
//       itemBuilder: (context, index) {
//         return Shimmer.fromColors(
//           baseColor: Colors.grey[800]!,
//           highlightColor: Colors.grey[400]!,
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(15),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Main image placeholder
//                 Container(height: heights[index % heights.length] - 60, color: Colors.grey[600]),
//                 const SizedBox(height: 8),
//                 // Title placeholder
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   child: Container(height: 16, width: double.infinity, color: Colors.grey[600]),
//                 ),
//                 const SizedBox(height: 4),
//                 // Subtitle placeholder
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   child: Container(
//                     height: 12,
//                     width: MediaQuery.of(context).size.width * 0.3,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
