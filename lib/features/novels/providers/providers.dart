import 'package:atlas_app/features/novels/models/chapter_draft_model.dart';
import 'package:atlas_app/features/novels/models/novel_model.dart';
import 'package:atlas_app/imports.dart';

final selectedNovelProvider = StateProvider<NovelModel?>((ref) => null);
final selectedDraft = StateProvider<ChapterDraftModel?>((ref) => null);
