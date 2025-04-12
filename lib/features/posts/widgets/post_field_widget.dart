import 'dart:async';
import 'dart:developer';

import 'package:atlas_app/core/common/utils/extract_key_words.dart';
import 'package:atlas_app/features/posts/providers/providers.dart';
import 'package:atlas_app/features/posts/widgets/user_data_widget.dart';
import 'package:atlas_app/features/profile/controller/profile_controller.dart';
import 'package:atlas_app/imports.dart';

class PostFieldWidget extends ConsumerStatefulWidget {
  const PostFieldWidget({super.key});

  @override
  ConsumerState<PostFieldWidget> createState() => _PostFieldWidgetState();
}

class _PostFieldWidgetState extends ConsumerState<PostFieldWidget> {
  Timer? _debounce;
  List<Map<String, dynamic>> mentionSuggestions = [];
  List<Map<String, dynamic>> hashTagsSuggestions = [];
  List<Map<String, dynamic>> comicsSuggestions = [];
  List<Map<String, dynamic>> charactersSuggestions = [];
  List<Map<String, dynamic>> novelSuggestions = [];

  List<String> mentions = [];
  List<String> hashtags = [];
  List<String> comics = [];
  List<String> characters = [];
  List<String> novels = [];
  String? originalPost;
  String? comicReview;

  void onMentionSearchChanged(String query) {
    if (query.isEmpty) return;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () async {
      log("querying");
      final users = await ref.read(profileControllerProvider.notifier).fetchUsersForMention(query);
      log(users.toString());
      setState(() {
        mentionSuggestions = users;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final postType = ref.watch(postTypeProvider);
    final me = ref.watch(userState).user!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          UserDataWidget(me: me),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 200),
            child: FlutterMentions(
              suggestionPosition:
                  postType == PostType.normal ? SuggestionPosition.Bottom : SuggestionPosition.Top,
              maxLines: 10,
              minLines: 6,
              cursorColor: AppColors.primary,
              style: const TextStyle(fontFamily: arabicPrimaryFont),
              onChanged: (val) {
                ref.read(postInputProvider.notifier).state = val.trim();
                final mentionQuery = extractMentionKeyword(val) ?? "";
                log("mention query: $mentionQuery");
                onMentionSearchChanged(mentionQuery);
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
                    return Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.primaryAccent,
                      child: Text(data['display']),
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
                  style: const TextStyle(color: Colors.blue),
                  data: [
                    {"id": "reactjs", "display": "reactjs"},
                    {
                      "id": "javascript",
                      "display": "javascript",
                      'photo': 'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg',
                    },
                  ],
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
    _debounce?.cancel();
    super.dispose();
  }
}
