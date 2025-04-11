import 'dart:async';

import 'package:atlas_app/core/common/enum/post_type.dart';
import 'package:atlas_app/core/common/widgets/mentions/mention_view.dart';
import 'package:atlas_app/core/common/widgets/mentions/models.dart';
import 'package:atlas_app/features/auth/providers/user_state.dart';
import 'package:atlas_app/imports.dart';

class MakePostPage extends ConsumerStatefulWidget {
  const MakePostPage({super.key, required this.postType});

  final PostType postType;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MakePostPageState();
}

class _MakePostPageState extends ConsumerState<MakePostPage> {
  late TextEditingController _controller;
  String _val = '';
  List<Map<String, dynamic>> mentionSuggestions = [];

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(userState).user!;
    return Scaffold(
      appBar: AppBar(title: const Text("انشاء منشور"), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(me.fullName),
                    Text(
                      "@${me.username}",
                      style: TextStyle(color: AppColors.mutedSilver, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 15),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.primaryAccent,
                  backgroundImage: CachedNetworkAvifImageProvider(me.avatar),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16.0), child: buildFieldTrigger()),
          const Divider(color: AppColors.primaryAccent, height: 0.25),
        ],
      ),
    );
  }

  Timer? _debounce;

  void onMentionSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () async {
      // final users = await fetchUsersForMention(query);
      List<Map<String, dynamic>> users = [];

      setState(() {
        mentionSuggestions = users;
      });
    });
  }

  Widget buildFieldTrigger() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 200),
      child: FlutterMentions(
        suggestionPosition: SuggestionPosition.Bottom,
        maxLines: 10,
        minLines: 6,
        cursorColor: AppColors.primary,
        style: const TextStyle(fontFamily: arabicPrimaryFont),
        onChanged:
            (val) => setState(() {
              _val = val;
            }),
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
                // margin: EdgeInsets.symmetric(vertical: 5),
                color: AppColors.primaryAccent,
                child: Text(data['display']),
              );
            },
            trigger: "@",
            style: const TextStyle(color: Colors.purple),
            data: [
              {
                "id": "61as61fsa",
                "display": "fayeedP",
                "photo": "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
              },
              {
                "id": "61asasgasgsag6a",
                "display": "khaled",
                "photo": "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
              },
            ],
          ),
          Mention(
            trigger: "#",
            disableMarkup: true,
            style: const TextStyle(color: Colors.blue),
            data: [
              {"id": "reactjs", "display": "reactjs"},
              {"id": "javascript", "display": "javascript"},
            ],
            matchAll: true,
          ),
        ],
      ),
    );
  }
}
