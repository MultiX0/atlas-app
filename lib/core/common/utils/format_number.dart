String formatNumber(int n) {
  if (n <= 9999) {
    return n.toString();
  } else if (n < 1000000) {
    double value = n / 1000;
    String formatted = value.toStringAsFixed(1);
    if (formatted.endsWith('.0')) {
      formatted = formatted.substring(0, formatted.length - 2);
    }
    return '${formatted}k';
  } else if (n < 1000000000) {
    double value = n / 1000000;
    String formatted = value.toStringAsFixed(1);
    if (formatted.endsWith('.0')) {
      formatted = formatted.substring(0, formatted.length - 2);
    }
    return '${formatted}m';
  } else {
    double value = n / 1000000000;
    String formatted = value.toStringAsFixed(1);
    if (formatted.endsWith('.0')) {
      formatted = formatted.substring(0, formatted.length - 2);
    }
    return '${formatted}b';
  }
}
