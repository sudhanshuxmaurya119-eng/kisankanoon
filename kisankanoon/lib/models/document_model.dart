class DocumentModel {
  final String id;
  final String title;
  final String type;
  final String imagePath;
  final String summary;
  final DateTime createdAt;

  DocumentModel({
    required this.id,
    required this.title,
    required this.type,
    required this.imagePath,
    this.summary = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type,
    'imagePath': imagePath,
    'summary': summary,
    'createdAt': createdAt.toIso8601String(),
  };

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    type: json['type'] ?? '',
    imagePath: json['imagePath'] ?? '',
    summary: json['summary'] ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
  );
}
