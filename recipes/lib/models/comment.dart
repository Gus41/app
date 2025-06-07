import 'package:uuid/uuid.dart';

class Comment {
  final String id;
  final String userId;
  final String username;
  final String text;
  final DateTime timestamp;

  static final _uuid = Uuid();

  Comment({
    String? id,
    required this.userId,
    required this.username,
    required this.text,
    required this.timestamp,
  }) : id = id ?? _uuid.v4();

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'],
        userId: json['userId'],
        username: json['username'],
        text: json['text'],
        timestamp: DateTime.parse(json['timestamp']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'username': username,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };
}
