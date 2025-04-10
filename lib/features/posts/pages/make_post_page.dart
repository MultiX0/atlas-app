import 'package:atlas_app/core/common/enum/post_type.dart';
import 'package:atlas_app/imports.dart';

class MakePostPage extends ConsumerStatefulWidget {
  const MakePostPage({super.key, required this.postType});

  final PostType postType;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MakePostPageState();
}

class _MakePostPageState extends ConsumerState<MakePostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar());
  }
}
