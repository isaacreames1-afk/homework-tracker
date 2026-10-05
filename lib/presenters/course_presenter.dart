import '../models/course_model.dart';

class CoursePresenter {
  final List<Course> _courses = [];

  List<Course> get courses => _courses;

  // Search Courses
  List<Course> searchCourses(String query) {
    return _courses
        .where((course) =>
            course.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Load courses from Firebase
  Future<void> loadCourses() async {
    final fetched = await Course.fetchCourses();

    _courses
      ..clear()
      ..addAll(fetched);
  }

  // Add course to Firebase and local list
  Future<void> addCourse(
    String name, {
    String? description,
  }) async {
    await Course.addCourse(
      name,
      description,
    );

    _courses.add(
      Course(
        name: name,
        description: description,
      ),
    );
  }
}