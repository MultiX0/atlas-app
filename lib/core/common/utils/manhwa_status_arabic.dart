String arabicStatus(String status) {
  final normlizedStatus = status.toUpperCase();
  if (normlizedStatus == 'RELEASING') {
    return 'قيد الانتاج';
  }

  if (normlizedStatus == 'FINISHED') {
    return 'مكتمل';
  }
  return status;
}
