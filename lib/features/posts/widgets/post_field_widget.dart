import 'dart:async';
import 'dart:developer';

import 'package:atlas_app/core/common/utils/extract_slash_item_type.dart';
import 'package:atlas_app/core/common/widgets/mentions/mention_view.dart';
import 'package:atlas_app/core/common/widgets/mentions/models.dart';
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
  // Separate timers for each trigger type
  Timer? _mentionDebounce;
  Timer? _hashtagDebounce;
  Timer? _slashDebounce;

  // Separate suggestion lists
  List<Map<String, dynamic>> mentionSuggestions = [];
  List<Map<String, dynamic>> hashTagsSuggestions = [
    {"id": "reactjs", "display": "reactjs"},
    {"id": "javascript", "display": "javascript"},
  ];

  // Slash command suggestions with types
  List<Map<String, dynamic>> slashSuggestions = [];

  // Handler for @ mentions
  void onMentionSearchChanged(String query) {
    if (query.isEmpty) return;

    if (_mentionDebounce?.isActive ?? false) _mentionDebounce!.cancel();
    _mentionDebounce = Timer(const Duration(milliseconds: 200), () async {
      log("querying for mentions: $query");
      final users = await ref.read(profileControllerProvider.notifier).fetchUsersForMention(query);
      setState(() {
        mentionSuggestions = users;
      });
    });
  }

  // Handler for # hashtags
  void onHashtagSearchChanged(String query) {
    if (query.isEmpty) return;

    if (_hashtagDebounce?.isActive ?? false) _hashtagDebounce!.cancel();
    _hashtagDebounce = Timer(const Duration(milliseconds: 200), () async {
      log("querying for hashtags: $query");
      // Here you would typically fetch hashtags from API
      // For demo, we're using static data
      setState(() {
        hashTagsSuggestions =
            [
              {"id": "reactjs", "display": "reactjs"},
              {"id": "javascript", "display": "javascript"},
              {"id": "flutter", "display": "flutter"},
              {"id": "dart", "display": "dart"},
            ].where((tag) => tag["display"].toString().contains(query)).toList();
      });
    });
  }

  // Handler for / slash commands
  void onSlashCommandSearchChanged(String query) {
    if (query.isEmpty) return;

    if (_slashDebounce?.isActive ?? false) _slashDebounce!.cancel();
    _slashDebounce = Timer(const Duration(milliseconds: 200), () async {
      log("querying for slash commands: $query");
      final data = await ref.read(postsControllerProvider.notifier).slashMentionSearch(query);
      final _suggestions =
          data
              .map(
                (i) => {
                  'id': i['id'] ?? "",
                  'display': i['title'] ?? "",
                  'type': i['type'],
                  'photo': i['image'] ?? "",
                },
              )
              .toList();
      setState(() {
        slashSuggestions = _suggestions;
      });
    });
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
              suggestionPosition: SuggestionPosition.Bottom,
              maxLines: 10,
              minLines: 6,
              cursorColor: AppColors.primary,
              style: const TextStyle(fontFamily: arabicPrimaryFont),

              // Trigger-specific callbacks
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
                  suggestionBuilder: (data) {
                    return Material(
                      color: AppColors.blackColor,
                      child: ListTile(
                        title: Text(data['display']),
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkAvifImageProvider(data['photo']),
                        ),
                      ),
                    );
                  },
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
                      orElse: () => {"type": "novel", "display": display}, // Default to novel type
                    );
                    final type = item['type'] ?? 'novel';

                    return '/$type[$id]:$display';
                  },
                  style: const TextStyle(color: AppColors.primary),
                  suggestionBuilder: (data) {
                    return Material(
                      color: AppColors.blackColor,
                      child: ListTile(
                        title: Text(data['display']),
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(data['photo']),
                        ),
                        subtitle: Text(extractSlashMentionType(data['type'])),
                      ),
                    );
                  },
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
