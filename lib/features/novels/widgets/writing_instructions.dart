import 'package:atlas_app/imports.dart';

void showWritingInstructionsSheet(BuildContext context) {
  openSheet(
    context: context,
    scrollControlled: true,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 16),
            const Text(
              '📚 تعليمات كتابة الفصل',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: arabicAccentFont,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 12),
            const Text(
              'اتبع هذه الإرشادات لتحسين تجربة القراءة والمشاركة داخل التطبيق:',
              style: TextStyle(fontSize: 16, fontFamily: arabicAccentFont),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
            _instruction(
              number: 1,
              text: 'اكتب النص بمحاذاة اليمين لتناسب القراءة باللغة العربية.',
            ),
            _instruction(
              number: 2,
              text: 'قسّم الفصل إلى فقرات قصيرة، وبين كل فقرة والتي تليها سطرين فارغين.',
              example: 'مثال:\nهذا أول جزء من الفصل.\n\n\nوهذا جزء آخر بعده مباشرة.',
            ),
            _instruction(
              number: 3,
              text: 'تجنب استخدام (...) أو (---) للفصل بين الأقسام.',
              example: '❌ لا تستخدم: \n...\n✅ استخدم: \n\n\n(سطرين فارغين)',
            ),
            _instruction(number: 4, text: 'كل فكرة أو حوار ضعه في فقرة منفصلة ليسهل قراءتها.'),
            _instruction(
              number: 5,
              text:
                  'عند اتباع هذه التعليمات، سيتمكن القارئ من مشاركة أجزاء معينة من الفصل بسهولة وأناقة.',
            ),
            const SizedBox(height: 24),
            CustomButton(text: "تم", onPressed: () => context.pop()),
          ],
        ),
      ),
    ),
  );
}

Widget _instruction({required int number, required String text, String? example}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            Text(
              '$number. ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textDirection: TextDirection.rtl,
            ),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16, fontFamily: arabicAccentFont),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
        if (example != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              example,
              style: const TextStyle(fontSize: 14, fontFamily: arabicPrimaryFont),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ],
    ),
  );
}
