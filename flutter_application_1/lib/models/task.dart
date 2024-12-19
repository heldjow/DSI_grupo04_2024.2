class Task {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String date;
  final String hour;
  final bool isComplete;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    required this.hour,
    this.isComplete = false, 
  });

  // Convert Task object to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'date': date,
      'hour': hour,
      'isComplete': isComplete,
    };
  }

  // Create Task object from Firestore JSON data
  factory Task.fromJson(String id, Map<String, dynamic> json) {
    return Task(
      id: id,
      userId: json['userId'],
      title: json['title'] as String,
      description: json['description'] as String,
      date: json['date'] as String,
      hour: json['hour'] as String,
      isComplete: json['isComplete'] as bool? ?? false,
    );
  }
}
