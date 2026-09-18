class Assignment {
  final String title;
  bool isCompleted;
  DateTime? dueDate; // Optional due date for the assignment

  Assignment({
    required this.title, 
    this.isCompleted = false,
    this.dueDate,
  });
}