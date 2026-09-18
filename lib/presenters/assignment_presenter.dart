import '../models/assignment_model.dart';

class AssignmentPresenter {
  final List<Assignment> _assignments = [];

  List<Assignment> get assignments => _assignments;

  void addAssignment(String title, DateTime? dueDate) {
    _assignments.add(Assignment(title: title, dueDate: dueDate));
  }

  void toggleCompleted(int index) {
    _assignments[index].isCompleted = !_assignments[index].isCompleted;
  }
}