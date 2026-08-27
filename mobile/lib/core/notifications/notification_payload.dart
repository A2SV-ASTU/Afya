class NotificationPayload {
  final String id;
  final String type; // 'medication' | 'appointment'
  final String title;
  final String body;
  final Map<String, dynamic>? data;

  const NotificationPayload({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
  });

  factory NotificationPayload.fromJson(Map<String, dynamic> json) => NotificationPayload(
    id: json['id'] as String,
    type: json['type'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    data: json['data'] as Map<String, dynamic>?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'body': body,
    'data': data,
  };
}
