import 'package:atlas_app/core/common/constants/key_names.dart';

class NovelInteraction {
  final String userId;
  final String novelId;
  final bool isFavoried;
  final int chapterReadCount;
  final int timeSpent;
  final bool shared;
  final DateTime createdAt;
  NovelInteraction({
    required this.userId,
    required this.novelId,
    required this.isFavoried,
    required this.chapterReadCount,
    required this.timeSpent,
    required this.shared,
    required this.createdAt,
  });

  NovelInteraction copyWith({
    String? userId,
    String? novelId,
    bool? isFavoried,
    int? chapterReadCount,
    int? timeSpent,
    bool? shared,
    DateTime? createdAt,
  }) {
    return NovelInteraction(
      userId: userId ?? this.userId,
      novelId: novelId ?? this.novelId,
      isFavoried: isFavoried ?? this.isFavoried,
      chapterReadCount: chapterReadCount ?? this.chapterReadCount,
      timeSpent: timeSpent ?? this.timeSpent,
      shared: shared ?? this.shared,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      KeyNames.userId: userId,
      KeyNames.novel_id: novelId,
      KeyNames.favorited: isFavoried,
      KeyNames.chapters_read: chapterReadCount,
      KeyNames.time_spent: timeSpent,
      KeyNames.shared: shared,
    };
  }

  factory NovelInteraction.fromMap(Map<String, dynamic> map) {
    return NovelInteraction(
      userId: map[KeyNames.userId] ?? "",
      novelId: map[KeyNames.novel_id] ?? "",
      isFavoried: map[KeyNames.favorited] ?? false,
      chapterReadCount: map[KeyNames.chapters_read] ?? 0,
      timeSpent: map[KeyNames.time_spent] ?? 0,
      shared: map[KeyNames.shared] ?? false,
      createdAt: DateTime.tryParse(map[KeyNames.created_at]) ?? DateTime.now(),
    );
  }
}
