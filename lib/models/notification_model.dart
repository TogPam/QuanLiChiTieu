// models/notification_model.dart
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'transaction' | 'alert' | 'system'
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
      };

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        type: json['type'],
        createdAt: DateTime.parse(json['createdAt']),
        isRead: json['isRead'] ?? false,
      );
}
