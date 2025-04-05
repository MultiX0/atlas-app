import 'package:intl/intl.dart';

String appDateTimeFormat(DateTime date) {
  return DateFormat('MMM d, yyyy • h:mm a').format(date.toLocal());
}

String appDateFormat(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date.toLocal());
}
