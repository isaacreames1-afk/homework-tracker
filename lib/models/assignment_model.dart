
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Assignment {
  final String? id;
  final String title;
  bool isCompleted;
  final DateTime? dueDate;
  final String courseName;

  Assignment({
    this.id,
    required this.title,
    required this.courseName,
    this.isCompleted = false,
    this.dueDate,
  });

  static final _db = FirebaseDatabase.instance.ref();
  static final _auth = FirebaseAuth.instance;

  // Load assignments from Firebase.
  static Future<List<Assignment>> fetchAssignment() async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) return [];

    final snapshot = await _db.child('assignments/$userId').get();
    final List<Assignment> assignments = [];

    if (snapshot.exists && snapshot.value is Map) {
      final data = Map<String, dynamic>.from(
        snapshot.value as Map,
      );

      data.forEach((key, value) {
        final item = Map<String, dynamic>.from(value as Map);

        assignments.add(
          Assignment(
            id: key,
            title: item['title'] ?? '',
            courseName: item['courseName'] ?? 'Unknown Course',
            isCompleted: item['isCompleted'] ?? false,
            dueDate: item['dueDate'] != null
                ? DateTime.tryParse(item['dueDate'].toString())
                : null,
          ),
        );
      });
    }

    return assignments;
  }

  // Add an assignment to Firebase.
  static Future<String?> addAssignment(
    String title,
    String courseName,
    DateTime? dueDate,
  ) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception('You must be logged in to add an assignment.');
    }

    final newRef = _db.child('assignments/$userId').push();

    await newRef.set({
      'title': title,
      'courseName': courseName,
      'isCompleted': false,
      'dueDate': dueDate?.toIso8601String(),
    });

    return newRef.key;
  }

  // Update completion status using the Firebase key.
  static Future<void> updateCompletionStatus(
    String id,
    bool isCompleted,
  ) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception('You must be logged in.');
    }

    await _db
        .child('assignments/$userId/$id')
        .update({'isCompleted': isCompleted});
  }

  // Delete an assignment from Firebase using its key.
  static Future<void> deleteAssignment(String id) async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      throw Exception('You must be logged in.');
    }

    await _db.child('assignments/$userId/$id').remove();
  }
}
