/// Modelo de una entrada del diario. Solo contiene datos (responsabilidad única).
class DiaryEntry {
  final int? id;
  final String title;
  final String content;
  final String? imagePath;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    this.imagePath,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  bool get hasLocation => latitude != null && longitude != null;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'image_path': imagePath,
    'latitude': latitude,
    'longitude': longitude,
    'created_at': createdAt.toIso8601String(),
  };

  factory DiaryEntry.fromMap(Map<String, dynamic> map) => DiaryEntry(
    id: map['id'] as int?,
    title: map['title'] as String,
    content: map['content'] as String,
    imagePath: map['image_path'] as String?,
    latitude: map['latitude'] as double?,
    longitude: map['longitude'] as double?,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}