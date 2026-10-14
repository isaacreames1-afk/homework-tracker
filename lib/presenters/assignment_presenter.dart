
import '../models/assignment_model.dart';

class AssignmentPresenter {
  final List<Assignment> _assignments = [];

  List<Assignment> get assignments => _assignments;

  List<Assignment> searchAssignments(String query) {
    return _assignments
        .where(
          (assignment) => assignment.title
              .toLowerCase()
              .contains(query.toLowerCase()),
        )
        .toList();
  }

  // Load assignments from Firebase.
  Future<void> loadAssignments() async {
    final fetched = await Assignment.fetchAssignment();

    _assignments
      ..clear()
      ..addAll(fetched);
  }

  // Add an assignment to Firebase and the local list.
  Future<void> addAssignment(
    String title,
    DateTime? dueDate,
    String courseName,
  ) async {
    final id = await Assignment.addAssignment(
      title,
      courseName,
      dueDate,
    );

    if (id == null) return;

    _assignments.add(
      Assignment(
        id: id,
        title: title,
        courseName: courseName,
        dueDate: dueDate,
      ),
    );
  }

  // Toggle completion status.
  Future<void> toggleCompleted(int index) async {
    if (index < 0 || index >= _assignments.length) return;

    final assignment = _assignments[index];
    final newStatus = !assignment.isCompleted;

    if (assignment.id == null) {
      throw Exception('Assignment is missing its Firebase ID.');
    }

    await Assignment.updateCompletionStatus(
      assignment.id!,
      newStatus,
    );

    assignment.isCompleted = newStatus;
  }

  // Delete one assignment from Firebase and the local list.
  Future<void> deleteAssignment(Assignment assignment) async {
    final id = assignment.id;

    if (id == null) {
      throw Exception('Assignment is missing its Firebase ID.');
    }

    await Assignment.deleteAssignment(id);
    _assignments.remove(assignment);
  }

  // Delete multiple assignments.
  Future<void> deleteAssignments(
    List<Assignment> assignments,
  ) async {
    for (final assignment in assignments) {
      await deleteAssignment(assignment);
    }
  }

  int get totalAssignments => _assignments.length;

  int get completedAssignments =>
      _assignments.where((a) => a.isCompleted).length;

  double get completionRatio =>
      totalAssignments == 0 ? 0.0 : completedAssignments / totalAssignments;
}
