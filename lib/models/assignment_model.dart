import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Assignment {
  final String title;
  bool isCompleted;
  DateTime? dueDate;

  Assignment({
    required this.title,
    this.isCompleted = false,
    this.dueDate,
  });

  static final _db = FirebaseDatabase.instance.ref();
  static final _auth = FirebaseAuth.instance;

  static Future<List<Assignment>> fetchAssignment() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _db.child('assignments/$userId').get();
    final List<Assignment> assignments = [];

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(
        snapshot.value as Map,
      );

      data.forEach((key, value) {
        assignments.add(
          Assignment(
            title: value['title'],
            isCompleted: value['isCompleted'],
            dueDate: value['dueDate'] != null
                ? DateTime.parse(value['dueDate'])
                : null,
          ),
        );
      });
    }

    return assignments;
  }

  static Future<void> addAssignment(
    String title,
    DateTime? dueDate,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final newRef = _db.child('assignments/$userId').push();

    await newRef.set({
      'title': title,
      'isCompleted': false,
      'dueDate': dueDate?.toIso8601String(),
    });
  }

  // Update completion status in Firebase
  static Future<void> updateCompletionStatus(
    int index,
    List<Assignment> currentAssignments,
  ) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null ||
        index < 0 ||
        index >= currentAssignments.length) {
      return;
    }

    final snapshot =
        await _db.child('assignments/$userId').get();

    if (snapshot.exists) {
      final data =
          Map<String, dynamic>.from(snapshot.value as Map);

      final entry = data.entries.elementAt(index);

      final ref =
          _db.child('assignments/$userId/${entry.key}');

      final updatedStatus =
          !currentAssignments[index].isCompleted;

      await ref.update({
        'isCompleted': updatedStatus,
      });
    }
  }
}