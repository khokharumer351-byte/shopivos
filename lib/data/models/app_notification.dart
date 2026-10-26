import 'json_utils.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    this.link,
    this.readAt,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;

  final String kind;

  final String? link;
  final DateTime? readAt;
  final DateTime? createdAt;

  bool get isRead => readAt != null;

  factory AppNotification.fromMap(Map<String, dynamic> map) => AppNotification(
    id: map['id'] as String,
    title: (map['title'] ?? '') as String,
    body: (map['body'] ?? '') as String,
    kind: (map['kind'] ?? 'info') as String,
    link: map['link'] as String?,
    readAt: toDate(map['read_at']),
    createdAt: toDate(map['created_at']),
  );

  AppNotification markedRead() => AppNotification(
    id: id,
    title: title,
    body: body,
    kind: kind,
    link: link,
    readAt: readAt ?? DateTime.now(),
    createdAt: createdAt,
  );
}
