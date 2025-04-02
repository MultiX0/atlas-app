import 'package:intl/intl.dart';

String appDateFormat(DateTime date) {
  return DateFormat('MMM d, yyyy • h:mm a').format(date.toLocal());
}
