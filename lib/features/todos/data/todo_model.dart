class TodoModel {
  final String? id;
  final String title;
  final String description;
  final DateTime deadline;
  final bool isCompleted;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoModel({
    this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.isCompleted = false,
    required this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert from Supabase JSON
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      deadline: DateTime.parse(json['deadline']),
      isCompleted: json['is_completed'] ?? false,
      userId: json['user_id'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert to Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'is_completed': isCompleted,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'TodoModel(id: $id, title: $title, deadline: $deadline, isCompleted: $isCompleted)';
  }
}
