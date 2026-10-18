
import 'package:flutter/material.dart';
import '../presenters/course_presenter.dart';
import '../widgets/add_fab.dart';
import '../theme/app_gradients.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final CoursePresenter presenter = CoursePresenter();

  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      await presenter.loadCourses();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load courses: $e'),
        ),
      );
    }
  }

  void _showAddCourseDialog() {
    String name = '';
    String? description;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                ),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (name.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a course name.'),
                    ),
                  );
                  return;
                }

                try {
                  await presenter.addCourse(
                    name.trim(),
                    description: description?.trim().isEmpty == true
                        ? null
                        : description?.trim(),
                  );

                  if (!mounted) return;

                  setState(() {});

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add course: $e'),
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final courses = _searchQuery.isEmpty
        ? presenter.courses
        : presenter.searchCourses(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
      ),

      // Mitsuri green-to-pink gradient background.
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.mitsuri,
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  // Search bar.
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search courses',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),

                  // Course list.
                  Expanded(
                    child: courses.isEmpty
                        ? const Center(
                            child: Text('No courses found.'),
                          )
                        : ListView.builder(
                            itemCount: courses.length,
                            itemBuilder: (context, index) {
                              final course = courses[index];

                              return Card(
                                color: Colors.white.withOpacity(0.65),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: ListTile(
                                  title: Text(
                                    course.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: course.description != null &&
                                          course.description!.isNotEmpty
                                      ? Text(course.description!)
                                      : null,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),

      // Add course button.
      floatingActionButton: AddFAB(
        onPressed: _showAddCourseDialog,
      ),
    );
  }
}
