import 'dart:async';
import 'dart:developer';

import 'package:atlas_app/core/common/utils/extract_slash_item_type.dart';
import 'package:atlas_app/core/common/widgets/mentions/mention_view.dart';
import 'package:atlas_app/core/common/widgets/mentions/models.dart';
import 'package:atlas_app/features/hashtags/db/hashtags_db.dart';
import 'package:atlas_app/features/posts/controller/posts_controller.dart';
import 'package:atlas_app/features/posts/providers/providers.dart';
import 'package:atlas_app/features/posts/widgets/user_data_widget.dart';
import 'package:atlas_app/features/profile/controller/profile_controller.dart';
import 'package:atlas_app/imports.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostFieldWidget extends ConsumerStatefulWidget {
  const PostFieldWidget({super.key});

  @override
  ConsumerState<PostFieldWidget> createState() => _PostFieldWidgetState();
}

class _PostFieldWidgetState extends ConsumerState<PostFieldWidget> {
  Timer? _mentionDebounce;
  Timer? _hashtagDebounce;
  Timer? _slashDebounce;

  List<Map<String, dynamic>> mentionSuggestions = [];
  List<Map<String, dynamic>> hashTagsSuggestions = [];
  List<Map<String, dynamic>> slashSuggestions = [];
  final List<Map<String, dynamic>> confirmedSlashMentions = [];
  final List<Map<String, dynamic>> confirmedMentions = [];
  final List<Map<String, dynamic>> confirmedHashtags = [];

  void onMentionSearchChanged(String query) {
    if (query.isEmpty) return;

    _mentionDebounce?.cancel();
    _mentionDebounce = Timer(const Duration(milliseconds: 200), () async {
      log("querying for mentions: $query");
      final users = await ref.read(profileControllerProvider.notifier).fetchUsersForMention(query);

      final newSuggestions =
          users
              .map(
                (u) => {
                  "id": u[KeyNames.id],
                  "display": u[KeyNames.username],
                  "photo": u[KeyNames.avatar],
                  'trigger': '@',
                },
              )
              .toList();

      // Merge confirmed mentions to the new suggestions
      for (var item in confirmedMentions) {
        if (!newSuggestions.any((e) => e['id'] == item['id'])) {
          newSuggestions.add(item);
        }
      }

      setState(() {
        mentionSuggestions = newSuggestions;
      });
    });
  }

  void onHashtagSearchChanged(String query) {
    if (query.isEmpty) return;

    _hashtagDebounce?.cancel();
    _hashtagDebounce = Timer(const Duration(milliseconds: 200), () async {
      log("querying for hashtags: $query");
      final hashTags = await ref.read(hashtagsDbProvider).searchHashTags(query);
      final newData =
          hashTags
              .map(
                (tag) => {
                  'id': tag.hashtag,
                  'display': tag.hashtag,
                  'count': tag.postCount,
                  'trigger': '#',
                },
              )
              .toList();

      // Merge confirmed hashtags to the new suggestions
      for (var item in confirmedHashtags) {
        if (!newData.any((e) => e['id'] == item['id'])) {
          newData.add(item as Map<String, Object>);
        }
      }

      setState(() {
        hashTagsSuggestions = newData;
      });
    });
  }

  // Handler for / slash commands
  void onSlashCommandSearchChanged(String query) {
    if (query.isEmpty) return;

    _slashDebounce?.cancel();
    _slashDebounce = Timer(const Duration(milliseconds: 200), () async {
      log("querying for slash commands: $query");
      final data = await ref.read(postsControllerProvider.notifier).slashMentionSearch(query);

      final newSuggestions =
          data.map((i) {
            return {
              'id': i['id'] ?? "",
              'display': i['title'] ?? "",
              'type': i['type'],
              'photo': i['image'] ?? "",
              'trigger': '/',
            };
          }).toList();

      // Preserve previously added slash mentions
      for (var item in confirmedSlashMentions) {
        if (!newSuggestions.any((e) => e['id'] == item['id'])) {
          newSuggestions.add(item);
        }
      }

      setState(() {
        slashSuggestions = newSuggestions;
      });
    });
  }

  void onMentionAdded(Map<String, dynamic> value) {
    if (value.containsKey('id') && value.containsKey('display')) {
      switch (value['trigger']) {
        case '/':
          if (!confirmedSlashMentions.any((item) => item['id'] == value['id'])) {
            confirmedSlashMentions.add(value);
          }
          break;
        case '@':
          if (!confirmedMentions.any((item) => item['id'] == value['id'])) {
            confirmedMentions.add(value);
          }
          break;
        case '#':
          if (!confirmedHashtags.any((item) => item['id'] == value['id'])) {
            confirmedHashtags.add(value);
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(userState).user!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          UserDataWidget(me: me),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 200),
            child: EnhancedFlutterMentions(
              onMarkupChanged: (val) {
                log(val);
                ref.read(postInputProvider.notifier).state = val.trim();
              },
              onMentionAdd: onMentionAdded,
              suggestionPosition: SuggestionPosition.Bottom,
              maxLines: 10,
              minLines: 6,
              cursorColor: AppColors.primary,
              style: const TextStyle(fontFamily: arabicPrimaryFont),
              triggerCallbacks: {
                '@': onMentionSearchChanged,
                '#': onHashtagSearchChanged,
                '/': onSlashCommandSearchChanged,
              },
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "بماذا تفكر؟",
                hintTextDirection: TextDirection.rtl,
                hintStyle: TextStyle(fontFamily: arabicAccentFont, fontSize: 18),
              ),
              mentions: [
                Mention(
                  disableMarkup: true,
                  suggestionBuilder:
                      (data) => Material(
                        color: AppColors.blackColor,
                        child: ListTile(
                          title: Text(data['display']),
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkAvifImageProvider(data['photo']),
                          ),
                        ),
                      ),
                  trigger: "@",
                  style: const TextStyle(color: AppColors.primary),
                  data:
                      mentionSuggestions
                          .map(
                            (u) => {
                              "id": u[KeyNames.id],
                              "display": u[KeyNames.username],
                              "photo": u[KeyNames.avatar],
                            },
                          )
                          .toList(),
                ),
                Mention(
                  trigger: "#",
                  disableMarkup: true,
                  style: const TextStyle(color: AppColors.primary),
                  data: hashTagsSuggestions,
                  matchAll: true,
                ),
                Mention(
                  trigger: "/",
                  disableMarkup: false,
                  markupBuilder: (trigger, id, display) {
                    final item = slashSuggestions.firstWhere(
                      (e) => e['id'] == id,
                      orElse: () => {"type": "novel", "display": display},
                    );
                    final type = item['type'] ?? 'novel';

                    // ✅ This now becomes a well-formed, bounded mention
                    return '/$type[$id]:$display/';
                  },
                  style: const TextStyle(color: AppColors.primary),
                  suggestionBuilder:
                      (data) => Material(
                        color: AppColors.blackColor,
                        child: ListTile(
                          title: Text(data['display'] ?? ""),
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(data['photo'] ?? ''),
                          ),
                          subtitle: Text(extractSlashMentionType(data['type'] ?? "")),
                        ),
                      ),
                  data: slashSuggestions,
                  matchAll: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mentionDebounce?.cancel();
    _hashtagDebounce?.cancel();
    _slashDebounce?.cancel();
    super.dispose();
  }
}
