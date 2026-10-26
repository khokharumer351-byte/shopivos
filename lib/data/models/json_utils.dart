double toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

List<String> toStringList(dynamic value) =>
    value is List ? value.whereType<String>().toList() : const <String>[];

DateTime? toDate(dynamic value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;
