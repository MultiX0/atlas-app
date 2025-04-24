import 'package:atlas_app/imports.dart';

class AssistantChatPage extends ConsumerWidget {
  const AssistantChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // appBar: AppBar(centerTitle: true, title: const Text("المساعد الشخصي")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(64.0),
          child: Image.asset('assets/images/atlas_ai.png'),
        ),
      ),
    );
  }
}
