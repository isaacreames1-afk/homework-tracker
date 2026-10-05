import '../models/assignment_model.dart';

class AssignmentPresenter {
  final List<Assignment> _assignments = [];

  List<Assignment> get assignments => _assignments;

  List<Assignment> searchAssignments(String query) {
    return _assignments
        .where((assignment) =>
            assignment.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
  // Load assignments from Firebase
  Future<void> loadAssignments() async {
    final fetched = await Assignment.fetchAssignment();

    _assignments
      ..clear()
      ..addAll(fetched);
  }

  // Add assignment to Firebase and local list
  Future<void> addAssignment(
    String title,
    DateTime? dueDate,
  ) async {
    await Assignment.addAssignment(title, dueDate);

    _assignments.add(
      Assignment(
        title: title,
        dueDate: dueDate,
      ),
    );
  }

  // Toggle completion status
  Future<void> toggleCompleted(int index) async {
    await Assignment.updateCompletionStatus(
      index,
      _assignments,
    );

    _assignments[index].isCompleted =
        !_assignments[index].isCompleted;
  }
}