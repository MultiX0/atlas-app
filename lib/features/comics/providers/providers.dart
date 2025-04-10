import 'package:atlas_app/features/comics/models/comic_model.dart';
import 'package:atlas_app/features/reviews/models/comic_review_model.dart';
import 'package:atlas_app/imports.dart';

final selectedComicProvider = StateProvider<ComicModel?>((ref) => null);
final manhwaTabControllerProvider = StateProvider<TabController?>((ref) => null);
final selectedReview = StateProvider<ComicReviewModel?>((ref) => null);
