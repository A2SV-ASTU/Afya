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

  String? get doseId =>
      data?['dose_id'] as String? ?? (type == 'medication' ? id : null);

  String? get prescriptionItemId => data?['prescription_item_id'] as String?;

  factory NotificationPayload.fromJson(Map<String, dynamic> json) =>
      NotificationPayload(
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
