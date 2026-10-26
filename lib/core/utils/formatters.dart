import '../config/app_config.dart';

String formatPrice(num value) {
  final amount = value.toDouble() * AppConfig.usdToPkr;
  final parts = amount.abs().toStringAsFixed(2).split('.');
  final digits = parts[0];
  final grouped = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(',');
    grouped.write(digits[i]);
  }
  final sign = amount < 0 ? '-' : '';
  return '$sign${AppConfig.currencySymbol}${grouped.toString()}.${parts[1]}';
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDate(DateTime? date) {
  if (date == null) return '—';
  return '${_months[date.month - 1]} ${date.day}, ${date.year}';
}

String orderRef(String id) {
  final clean = id.replaceAll('-', '');
  return '#${(clean.length > 8 ? clean.substring(0, 8) : clean).toUpperCase()}';
}

String capitalize(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
