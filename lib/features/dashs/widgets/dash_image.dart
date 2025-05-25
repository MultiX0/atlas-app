import 'dart:async';
import 'package:atlas_app/imports.dart';
import 'package:shimmer/shimmer.dart';

class SimpleDynamicImage extends StatelessWidget {
  final String imageUrl;
  final String imageId;

  static final Map<String, Size> _cache = {};
  static final Map<String, Future<Size>> _pendingRequests = {};

  const SimpleDynamicImage({super.key, required this.imageUrl, required this.imageId});

  Future<Size> _getImageDimensions() async {
    // Return cached result if available
    if (_cache.containsKey(imageId)) {
      return _cache[imageId]!;
    }

    // Return pending request if already in progress
    if (_pendingRequests.containsKey(imageId)) {
      return _pendingRequests[imageId]!;
    }

    // Create new request
    final completer = Completer<Size>();
    _pendingRequests[imageId] = completer.future;

    try {
      final image = Image(image: CachedNetworkImageProvider(imageUrl));
      late ImageStreamListener listener;

      listener = ImageStreamListener(
        (ImageInfo info, bool _) {
          if (!completer.isCompleted) {
            final size = Size(info.image.width.toDouble(), info.image.height.toDouble());
            _cache[imageId] = size;
            completer.complete(size);
          }
          // Remove listener to prevent memory leaks
          image.image.resolve(const ImageConfiguration()).removeListener(listener);
        },
        onError: (exception, stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(exception, stackTrace);
          }
        },
      );

      image.image.resolve(const ImageConfiguration()).addListener(listener);
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }

    // Clean up pending request when completed
    completer.future.whenComplete(() {
      _pendingRequests.remove(imageId);
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: ValueKey(imageId),
      borderRadius: BorderRadius.circular(15),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .75),
        child: FutureBuilder<Size>(
          future: _getImageDimensions(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final size = snapshot.data!;
              return AspectRatio(
                aspectRatio: size.width / size.height,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[800]!,
                        highlightColor: Colors.grey[400]!,
                        child: Container(color: Colors.grey[600]),
                      ),
                  errorWidget:
                      (context, url, error) =>
                          Container(color: Colors.grey[600], child: const Icon(Icons.broken_image)),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                height: 200,
                color: Colors.grey[600],
                child: const Center(child: Icon(Icons.broken_image, size: 48)),
              );
            }

            return Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[400]!,
              child: Container(color: Colors.grey[600]),
            );
          },
        ),
      ),
    );
  }
}
