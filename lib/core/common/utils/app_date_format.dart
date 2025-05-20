import 'package:intl/intl.dart';

String appDateTimeFormat(DateTime date) {
  return DateFormat('MMM d, yyyy • h:mm a', 'ar').format(date.toLocal());
}

String appDateFormat(DateTime date) {
  return DateFormat('MMM d, yyyy', 'ar').format(date.toLocal());
}
