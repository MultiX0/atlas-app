import 'dart:developer';

import 'package:atlas_app/core/services/gal_service.dart';
import 'package:atlas_app/imports.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:gallery_image_viewer/gallery_image_viewer.dart';
import 'package:go_router/go_router.dart';

// Defined here so we don't repeat ourselves
const _defaultBackgroundColor = Colors.black;
const _defaultCloseButtonColor = Colors.white;
const _defaultCloseButtonTooltip = 'Close';

/// Shows the given [imageProvider] in a full-screen [Dialog].
/// Setting [immersive] to false will prevent the top and bottom bars from being hidden.
/// The optional [onViewerDismissed] callback function is called when the dialog is closed.
/// The optional [useSafeArea] boolean defaults to false and is passed to [showDialog].
/// The optional [swipeDismissible] boolean defaults to false allows swipe-down-to-dismiss.
/// The [backgroundColor] defaults to black, but can be set to any other color.
/// The [closeButtonTooltip] text is displayed when the user long-presses on the
/// close button and is used for accessibility.
/// The [closeButtonColor] defaults to white, but can be set to any other color.
Future<Dialog?> showImageViewer(
  BuildContext context,
  ImageProvider imageProvider, {
  bool immersive = true,
  void Function()? onViewerDismissed,
  bool useSafeArea = false,
  bool swipeDismissible = false,
  Color backgroundColor = _defaultBackgroundColor,
  String closeButtonTooltip = _defaultCloseButtonTooltip,
  Color closeButtonColor = _defaultCloseButtonColor,
}) {
  return showImageViewerPager(
    context,
    SingleImageProvider(imageProvider),
    immersive: immersive,
    onViewerDismissed: onViewerDismissed != null ? (_) => onViewerDismissed() : null,
    useSafeArea: useSafeArea,
    swipeDismissible: swipeDismissible,
    backgroundColor: backgroundColor,
    closeButtonTooltip: closeButtonTooltip,
    closeButtonColor: closeButtonColor,
  );
}

/// Shows the images provided by the [imageProvider] in a full-screen PageView [Dialog].
/// Setting [immersive] to false will prevent the top and bottom bars from being hidden.
/// The optional [onPageChanged] callback function is called with the index of
/// the image when the user has swiped to another image.
/// The optional [onViewerDismissed] callback function is called with the index of
/// the image that is displayed when the dialog is closed.
/// The optional [useSafeArea] boolean defaults to false and is passed to [showDialog].
/// The optional [swipeDismissible] boolean defaults to false allows swipe-down-to-dismiss.
/// The [backgroundColor] defaults to black, but can be set to any other color.
/// The [closeButtonTooltip] text is displayed when the user long-presses on the
/// close button and is used for accessibility.
/// The [closeButtonColor] defaults to white, but can be set to any other color.
Future<Dialog?> showImageViewerPager(
  BuildContext context,
  EasyImageProvider imageProvider, {
  bool immersive = true,
  void Function(int)? onPageChanged,
  void Function(int)? onViewerDismissed,
  bool useSafeArea = false,
  bool swipeDismissible = false,
  Color backgroundColor = _defaultBackgroundColor,
  String closeButtonTooltip = _defaultCloseButtonTooltip,
  Color closeButtonColor = _defaultCloseButtonColor,
}) {
  if (immersive) {
    // Hide top and bottom bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  return showDialog<Dialog>(
    context: context,
    useSafeArea: useSafeArea,
    builder: (context) {
      return EasyImageViewerDismissibleDialog(
        imageProvider,
        immersive: immersive,
        onPageChanged: onPageChanged,
        onViewerDismissed: onViewerDismissed,
        useSafeArea: useSafeArea,
        swipeDismissible: swipeDismissible,
        backgroundColor: backgroundColor,
        closeButtonColor: closeButtonColor,
        closeButtonTooltip: closeButtonTooltip,
      );
    },
  );
}

/// An internal widget that is used to hold a state to activate/deactivate the ability to
/// swipe-to-dismiss. This needs to be tied to the zoom scale of the current image, since
/// the user needs to be able to pan around on a zoomed-in image without triggering the
/// swipe-to-dismiss gesture.
class EasyImageViewerDismissibleDialog extends StatefulWidget {
  final EasyImageProvider imageProvider;
  final bool immersive;
  final void Function(int)? onPageChanged;
  final void Function(int)? onViewerDismissed;
  final bool useSafeArea;
  final bool swipeDismissible;
  final Color backgroundColor;
  final String closeButtonTooltip;
  final Color closeButtonColor;

  /// Refer to [showImageViewerPager] for the arguments
  const EasyImageViewerDismissibleDialog(
    this.imageProvider, {
    Key? key,
    this.immersive = true,
    this.onPageChanged,
    this.onViewerDismissed,
    this.useSafeArea = false,
    this.swipeDismissible = false,
    required this.backgroundColor,
    required this.closeButtonTooltip,
    required this.closeButtonColor,
  }) : super(key: key);

  @override
  State<EasyImageViewerDismissibleDialog> createState() => _EasyImageViewerDismissibleDialogState();
}

class _EasyImageViewerDismissibleDialogState extends State<EasyImageViewerDismissibleDialog> {
  /// This is used to either activate or deactivate the ability to swipe-to-dismissed, based on
  /// whether the current image is zoomed in (scale > 0) or not.
  DismissDirection _dismissDirection = DismissDirection.down;
  void Function()? _internalPageChangeListener;
  late final PageController _pageController;

  /// This is needed because of https://github.com/thesmythgroup/gallery_image_viewer/issues/27
  /// When no global key was used, the state was re-created on the initial zoom, which
  /// caused the new state to have _pagingEnabled set to true, which in turn broke
  /// paning on the zoomed-in image.
  final _popScopeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.imageProvider.initialIndex);
    if (widget.onPageChanged != null) {
      _internalPageChangeListener = () {
        widget.onPageChanged!(_pageController.page?.round() ?? 0);
      };
      _pageController.addListener(_internalPageChangeListener!);
    }
  }

  @override
  void dispose() {
    if (_internalPageChangeListener != null) {
      _pageController.removeListener(_internalPageChangeListener!);
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final popScopeAwareDialog = WillPopScope(
      onWillPop: () async {
        _handleDismissal();
        return true;
      },
      key: _popScopeKey,
      child: Dialog(
        backgroundColor: widget.backgroundColor,
        insetPadding: const EdgeInsets.all(0),
        // We set the shape here to ensure no rounded corners allow any of the
        // underlying view to show. We want the whole background to be covered.
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            EasyImageViewPager(
              easyImageProvider: widget.imageProvider,
              pageController: _pageController,
              onScaleChanged: (scale) {
                setState(() {
                  _dismissDirection = scale <= 1.0 ? DismissDirection.down : DismissDirection.none;
                });
              },
            ),
            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                icon: const Icon(Icons.close),
                color: widget.closeButtonColor,
                tooltip: widget.closeButtonTooltip,
                onPressed: () {
                  context.pop();
                  _handleDismissal();
                },
              ),
            ),
            Positioned(
              top: 5,
              left: 5,
              child: IconButton(
                icon: const Icon(TablerIcons.download),
                color: widget.closeButtonColor,
                tooltip: widget.closeButtonTooltip,
                onPressed: () async {
                  final provider = widget.imageProvider.imageBuilder(
                    context,
                    _pageController.page?.round() ?? 0,
                  );
                  String url = '';
                  if (provider is CachedNetworkAvifImageProvider) {
                    url = provider.url;
                  }
                  if (provider is CachedNetworkImageProvider) {
                    url = provider.url;
                  }
                  if (provider is NetworkImage) {
                    url = provider.url;
                  }
                  await downloadImage(url);
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.swipeDismissible) {
      return Dismissible(
        direction: _dismissDirection,
        resizeDuration: null,
        confirmDismiss: (dir) async {
          return true;
        },
        onDismissed: (_) {
          context.pop();

          _handleDismissal();
        },
        key: const Key('dismissible_gallery_image_viewer_dialog'),
        child: popScopeAwareDialog,
      );
    } else {
      return popScopeAwareDialog;
    }
  }

  // Internal function to be called whenever the dialog
  // is dismissed, whether through the Android back button,
  // through the "x" close button, or through swipe-to-dismiss.
  void _handleDismissal() {
    if (widget.onViewerDismissed != null) {
      widget.onViewerDismissed!(_pageController.page?.round() ?? 0);
    }

    if (widget.immersive) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    if (_internalPageChangeListener != null) {
      _pageController.removeListener(_internalPageChangeListener!);
    }
  }
}

class GalleryImageView extends StatelessWidget {
  /// The image to display
  final List<ImageProvider> listImage;

  /// The gallery width
  final double width;

  /// The gallery height
  final double height;

  /// The image BoxDecoration
  final BoxDecoration? imageDecoration;

  /// The image BoxFit
  final BoxFit boxFit;

  /// The Gallery type
  final int galleryType;

  /// The Gallery short image is maximum 4 images.
  final bool shortImage;

  /// Font size
  final double fontSize;

  /// Text color
  final Color textColor;

  const GalleryImageView({
    super.key,
    required this.listImage,
    this.boxFit = BoxFit.cover,
    this.imageDecoration,
    this.width = 100,
    this.height = 100,
    this.galleryType = 0,
    this.shortImage = true,
    this.fontSize = 32,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint("listImage length ::: ${listImage.length}");

    /// The gallery type was not sent, check listImage.length to call _uiImage.
    /// The gallery type was sent, call _uiImage on the gallery type sent.
    if (galleryType == 0) {
      if (listImage.length >= 2 && listImage.length < 5) {
        return SizedBox(width: width, height: height, child: _uiImage2(context));
      } else if (listImage.length >= 5) {
        return SizedBox(width: width, height: height, child: _uiImage3(context));
      } else {
        return SizedBox(width: width, height: height, child: _uiImage1(context));
      }
    } else if (galleryType == 2) {
      return SizedBox(width: width, height: height, child: _uiImage2(context));
    } else if (galleryType == 3) {
      return SizedBox(width: width, height: height, child: _uiImage3(context));
    } else {
      return SizedBox(width: width, height: height, child: _uiImage1(context));
    }
  }

  /// Left - Right
  Widget _uiImage1(BuildContext context) {
    if (shortImage && listImage.length >= 5) {
      int imgMore = listImage.length - 4;
      return Row(
        children: [
          for (int i = 0; i < 4; i++)
            Expanded(
              child: Container(
                decoration: imageDecoration,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: listImage[i], fit: boxFit),
                  ),
                  width: double.infinity,
                  height: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        MultiImageProvider multiImageProvider = MultiImageProvider(
                          listImage,
                          initialIndex: i,
                        );
                        showImageViewerPager(
                          context,

                          multiImageProvider,
                          useSafeArea: true,
                          backgroundColor: Colors.black.withValues(alpha: .85),
                        );
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          i == 3 ? "+$imgMore" : "",
                          style: TextStyle(
                            color: textColor,
                            fontSize: fontSize,
                            shadows: textShadow,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0; i < listImage.length; i++)
          Expanded(
            child: Container(
              decoration: imageDecoration,
              child: Container(
                decoration: BoxDecoration(image: DecorationImage(image: listImage[i], fit: boxFit)),
                width: double.infinity,
                height: double.infinity,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      MultiImageProvider multiImageProvider = MultiImageProvider(
                        listImage,
                        initialIndex: i,
                      );
                      showImageViewerPager(
                        context,

                        multiImageProvider,
                        useSafeArea: true,
                        backgroundColor: Colors.black.withValues(alpha: .85),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Left - Right(Top - Bottom)
  Widget _uiImage2(BuildContext context) {
    if (shortImage && listImage.length >= 5) {
      int imgMore = listImage.length - 4;
      return Row(
        children: [
          Expanded(
            child: Container(
              decoration: imageDecoration,
              child: Container(
                decoration: BoxDecoration(image: DecorationImage(image: listImage[0], fit: boxFit)),
                width: double.infinity,
                height: double.infinity,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      MultiImageProvider multiImageProvider = MultiImageProvider(
                        listImage,
                        initialIndex: 0,
                      );
                      showImageViewerPager(
                        context,
                        multiImageProvider,
                        useSafeArea: true,
                        backgroundColor: Colors.black.withValues(alpha: .85),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                for (int i = 1; i < 4; i++)
                  Expanded(
                    child: Container(
                      decoration: imageDecoration,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(image: listImage[i], fit: boxFit),
                        ),
                        width: double.infinity,
                        height: double.infinity,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              MultiImageProvider multiImageProvider = MultiImageProvider(
                                listImage,
                                initialIndex: i,
                              );
                              showImageViewerPager(
                                context,

                                multiImageProvider,
                                useSafeArea: true,
                                backgroundColor: Colors.black.withValues(alpha: .85),
                              );
                            },
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                i == 3 ? "+$imgMore" : "",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: fontSize,
                                  shadows: textShadow,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: imageDecoration,
            child: Container(
              decoration: BoxDecoration(image: DecorationImage(image: listImage[0], fit: boxFit)),
              width: double.infinity,
              height: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    MultiImageProvider multiImageProvider = MultiImageProvider(
                      listImage,
                      initialIndex: 0,
                    );
                    showImageViewerPager(
                      context,
                      multiImageProvider,
                      useSafeArea: true,
                      backgroundColor: Colors.black.withValues(alpha: .85),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              for (var i = 1; i < listImage.length; i++)
                Expanded(
                  child: Container(
                    decoration: imageDecoration,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(image: listImage[i], fit: boxFit),
                      ),
                      width: double.infinity,
                      height: double.infinity,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            MultiImageProvider multiImageProvider = MultiImageProvider(
                              listImage,
                              initialIndex: i,
                            );
                            showImageViewerPager(
                              context,
                              multiImageProvider,

                              useSafeArea: true,
                              backgroundColor: Colors.black.withValues(alpha: .85),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Left - Right(Top - Bottom)
  Widget _uiImage3(BuildContext context) {
    if (shortImage && listImage.length >= 5) {
      int imgMore = listImage.length - 4;
      return Column(
        children: [
          Expanded(
            child: Container(
              decoration: imageDecoration,
              child: Container(
                decoration: BoxDecoration(image: DecorationImage(image: listImage[0], fit: boxFit)),
                width: double.infinity,
                height: double.infinity,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      MultiImageProvider multiImageProvider = MultiImageProvider(
                        listImage,
                        initialIndex: 0,
                      );
                      showImageViewerPager(
                        context,

                        multiImageProvider,
                        backgroundColor: Colors.black.withValues(alpha: .85),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                for (int i = 1; i < 4; i++)
                  Expanded(
                    child: Container(
                      decoration: imageDecoration,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(image: listImage[i], fit: boxFit),
                        ),
                        width: double.infinity,
                        height: double.infinity,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              MultiImageProvider multiImageProvider = MultiImageProvider(
                                listImage,
                                initialIndex: i,
                              );
                              showImageViewerPager(
                                context,
                                multiImageProvider,
                                backgroundColor: Colors.black.withValues(alpha: .85),
                              );
                            },
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                i == 3 ? "+$imgMore" : "",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: fontSize,
                                  shadows: textShadow,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: imageDecoration,
            child: Container(
              decoration: BoxDecoration(image: DecorationImage(image: listImage[0], fit: boxFit)),
              width: double.infinity,
              height: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    MultiImageProvider multiImageProvider = MultiImageProvider(
                      listImage,
                      initialIndex: 0,
                    );
                    showImageViewerPager(
                      context,
                      multiImageProvider,
                      backgroundColor: Colors.black.withValues(alpha: .85),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              for (var i = 1; i < listImage.length; i++)
                Expanded(
                  child: Container(
                    decoration: imageDecoration,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(image: listImage[i], fit: boxFit),
                      ),
                      width: double.infinity,
                      height: double.infinity,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            MultiImageProvider multiImageProvider = MultiImageProvider(
                              listImage,
                              initialIndex: i,
                            );
                            showImageViewerPager(
                              context,
                              multiImageProvider,
                              backgroundColor: Colors.black.withValues(alpha: .85),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

const textShadow = <Shadow>[
  Shadow(offset: Offset(-2.0, 0.0), blurRadius: 4.0, color: Colors.black54),
  Shadow(offset: Offset(0.0, 2.0), blurRadius: 4.0, color: Colors.black54),
  Shadow(offset: Offset(2.0, 0.0), blurRadius: 4.0, color: Colors.black54),
  Shadow(offset: Offset(0.0, -2.0), blurRadius: 4.0, color: Colors.black54),
];
