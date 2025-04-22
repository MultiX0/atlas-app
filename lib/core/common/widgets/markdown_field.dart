import 'dart:async';
import 'dart:developer';

import 'package:atlas_app/core/common/utils/extract_slash_item_type.dart';
import 'package:atlas_app/core/common/widgets/mentions/mention_view.dart';
import 'package:atlas_app/core/common/widgets/mentions/models.dart';
import 'package:atlas_app/features/hashtags/db/hashtags_db.dart';
import 'package:atlas_app/features/posts/controller/posts_controller.dart';
import 'package:atlas_app/features/posts/widgets/user_data_widget.dart';
import 'package:atlas_app/features/profile/controller/profile_controller.dart';
import 'package:atlas_app/imports.dart';

class ReusablePostFieldWidget extends ConsumerStatefulWidget {
  const ReusablePostFieldWidget({
    super.key,
    this.defaultText,
    this.minLines = 6,
    this.maxLines = 8,
    this.hintText = "بماذا تفكر؟",
    this.showUserData = true,
    required this.onMarkupChanged,
    this.adaptiveSuggestions = true,
  });

  final String? defaultText;
  final int minLines;
  final int maxLines;
  final String hintText;
  final bool showUserData;
  final Function(String) onMarkupChanged;
  final bool adaptiveSuggestions;

  @override
  ConsumerState<ReusablePostFieldWidget> createState() => ReusablePostFieldWidgetState();
}

class ReusablePostFieldWidgetState extends ConsumerState<ReusablePostFieldWidget> {
  Timer? _mentionDebounce;
  Timer? _hashtagDebounce;
  Timer? _slashDebounce;

  List<Map<String, dynamic>> mentionSuggestions = [];
  List<Map<String, dynamic>> hashTagsSuggestions = [];
  List<Map<String, dynamic>> slashSuggestions = [];
  final List<Map<String, dynamic>> confirmedSlashMentions = [];
  final List<Map<String, dynamic>> confirmedMentions = [];
  final List<Map<String, dynamic>> confirmedHashtags = [];

  // GlobalKey to access EnhancedFlutterMentionsState
  final GlobalKey<EnhancedFlutterMentionsState> _mentionsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  // Method to clear the text
  void clearText() {
    log('ReusablePostFieldWidget: Clearing text');
    _mentionsKey.currentState?.clearText();
    setState(() {
      confirmedMentions.clear();
      confirmedHashtags.clear();
      confirmedSlashMentions.clear();
      mentionSuggestions.clear();
      hashTagsSuggestions.clear();
      slashSuggestions.clear();
    });
    widget.onMarkupChanged('');
  }

  void onMentionSearchChanged(String query) {
    _mentionDebounce?.cancel();
    _mentionDebounce = Timer(const Duration(milliseconds: 150), () async {
      log("querying for mentions: $query");
      final users = await ref.read(profileControllerProvider.notifier).fetchUsersForMention(query);
      log("Users fetched: $users");
      final newSuggestions =
          users
              .map(
                (u) => {
                  "id": u[KeyNames.id] ?? "",
                  "display": u[KeyNames.fullName] ?? "Unknown",
                  "username": u[KeyNames.username] ?? "Unknown",
                  "photo": u[KeyNames.avatar] ?? "",
                  'trigger': '@',
                },
              )
              .toList();

      for (var item in confirmedMentions) {
        if (!newSuggestions.any((e) => e['id'] == item['id'])) {
          newSuggestions.add(item);
        }
      }

      setState(() {
        mentionSuggestions = newSuggestions;
        log("Mention suggestions updated: $mentionSuggestions");
      });
    });
  }

  void onHashtagSearchChanged(String query) {
    _hashtagDebounce?.cancel();
    _hashtagDebounce = Timer(const Duration(milliseconds: 150), () async {
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

  void onSlashCommandSearchChanged(String query) {
    _slashDebounce?.cancel();
    _slashDebounce = Timer(const Duration(milliseconds: 150), () async {
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
          if (widget.showUserData) UserDataWidget(me: me),
          EnhancedFlutterMentions(
            key: _mentionsKey, // Assign GlobalKey
            defaultText: widget.defaultText,
            onMarkupChanged: widget.onMarkupChanged,
            onMentionAdd: onMentionAdded,
            suggestionPosition: SuggestionPosition.Top,
            suggestionListHeight: 200,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            cursorColor: AppColors.primary,
            style: const TextStyle(fontFamily: arabicPrimaryFont),
            triggerCallbacks: {
              '@': onMentionSearchChanged,
              '#': onHashtagSearchChanged,
              '/': onSlashCommandSearchChanged,
            },
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: widget.hintText,
              hintTextDirection: TextDirection.rtl,
              hintStyle: const TextStyle(fontFamily: arabicAccentFont, fontSize: 18),
            ),
            mentions: [
              Mention(
                disableMarkup: true,
                suggestionBuilder:
                    (data) => Material(
                      color: AppColors.blackColor,
                      child: ListTile(
                        title: Text(data['display'] ?? "No Name"),
                        subtitle: Text("@${data['username'] ?? "No Username"}"),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.blackColor,
                          backgroundImage:
                              data['photo']?.isNotEmpty == true
                                  ? CachedNetworkAvifImageProvider(data['photo'])
                                  : null,
                          child:
                              data['photo']?.isNotEmpty != true ? const Icon(Icons.person) : null,
                        ),
                      ),
                    ),
                trigger: "@",
                style: const TextStyle(color: AppColors.primary),
                data: mentionSuggestions,
              ),
              Mention(
                trigger: "#",
                disableMarkup: true,
                style: const TextStyle(color: AppColors.primary),
                data: hashTagsSuggestions,
                matchAll: true,
                suggestionBuilder:
                    (data) => Material(
                      color: AppColors.blackColor,
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 23,
                          backgroundColor: AppColors.scaffoldForeground,
                          child: Icon(LucideIcons.hash, color: AppColors.whiteColor),
                        ),
                        title: Text(data['display']),
                        subtitle: Text(
                          "${data["count"]} منشور",
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
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
                  return '/$type[$id]:$display/';
                },
                style: const TextStyle(color: AppColors.primary),
                suggestionBuilder:
                    (data) => Material(
                      color: AppColors.blackColor,
                      child: ListTile(
                        title: Text(data['display'] ?? ""),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryAccent,
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
          // Temporary button to test clearing
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
