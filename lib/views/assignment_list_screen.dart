
import 'package:flutter/material.dart';

import '../models/assignment_model.dart';
import '../presenters/assignment_presenter.dart';
import '../presenters/course_presenter.dart';
import '../widgets/add_fab.dart';
import 'due_date_picker.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() =>
      _AssignmentListScreenState();
}

class _AssignmentListScreenState
    extends State<AssignmentListScreen> {
  final AssignmentPresenter _presenter = AssignmentPresenter();
  final CoursePresenter _coursePresenter = CoursePresenter();

  bool _isLoading = true;
  bool _isSelecting = false;

  DateTime? _dueDate;
  String _searchQuery = '';
  String? _selectedCourseFilter;
  String? _newAssignmentCourse;

  List<String> _courseNames = [];

  // Keep track of selected assignments directly.
  // This prevents search and course filters from changing
  // which assignments are selected for deletion.
  final Set<Assignment> _selectedAssignments = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load assignments and courses from Firebase.
  Future<void> _loadData() async {
    try {
      await _presenter.loadAssignments();
      await _coursePresenter.loadCourses();

      if (!mounted) return;

      setState(() {
        _courseNames = _coursePresenter.courses
            .map((course) => course.name)
            .toList();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Display the Add Assignment dialog.
  void _showAddAssignmentDialog() {
    String newAssignmentTitle = '';

    _newAssignmentCourse = _courseNames.isNotEmpty
        ? _courseNames.first
        : null;

    _dueDate = null;

    showDialog<void>(
      context: context,
      builder: (outerDialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, dialogSetState) {
            return AlertDialog(
              title: const Text('Add Assignment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Assignment title.
                    TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter assignment title',
                        labelText: 'Assignment Title',
                      ),
                      onChanged: (value) {
                        newAssignmentTitle = value;
                      },
                    ),

                    const SizedBox(height: 15),

                    // Course dropdown.
                    DropdownButton<String>(
                      value: _newAssignmentCourse,
                      hint: const Text('Select Course'),
                      isExpanded: true,
                      items: _courseNames.map((name) {
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        dialogSetState(() {
                          _newAssignmentCourse = value;
                        });
                      },
                    ),

                    if (_courseNames.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Add a course before creating an assignment.',
                        ),
                      ),

                    const SizedBox(height: 15),

                    // Date picker.
                    OutlinedButton(
                      onPressed: () async {
                        final pickedDate =
                            await selectDueDate(dialogContext);

                        if (pickedDate != null &&
                            dialogContext.mounted) {
                          dialogSetState(() {
                            _dueDate = pickedDate;
                          });
                        }
                      },
                      child: Text(
                        _dueDate == null
                            ? 'Select Due Date'
                            : 'Due: '
                                '${_dueDate!.day}/'
                                '${_dueDate!.month}/'
                                '${_dueDate!.year}',
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                // Cancel button.
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),

                // Add button.
                TextButton(
                  onPressed: () async {
                    if (newAssignmentTitle.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter an assignment title.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (_newAssignmentCourse == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select a course.',
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      await _presenter.addAssignment(
                        newAssignmentTitle.trim(),
                        _dueDate,
                        _newAssignmentCourse!,
                      );

                      if (!mounted) return;

                      setState(() {});

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to add assignment: $e',
                          ),
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
      },
    );
  }

  // Enter selection mode.
  void _startSelecting() {
    setState(() {
      _isSelecting = true;
      _selectedAssignments.clear();
    });
  }

  // Cancel selection mode.
  void _cancelSelecting() {
    setState(() {
      _isSelecting = false;
      _selectedAssignments.clear();
    });
  }

  // Select or deselect an assignment.
  void _toggleSelection(Assignment assignment) {
    setState(() {
      if (_selectedAssignments.contains(assignment)) {
        _selectedAssignments.remove(assignment);
      } else {
        _selectedAssignments.add(assignment);
      }
    });
  }

  // Delete selected assignments from Firebase.
  Future<void> _deleteSelectedAssignments() async {
    if (_selectedAssignments.isEmpty) return;

    final selectedItems = _selectedAssignments.toList();

    try {
      await _presenter.deleteAssignments(selectedItems);

      if (!mounted) return;

      setState(() {
        _selectedAssignments.clear();
        _isSelecting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assignments deleted successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        // Remove successfully deleted items from selection.
        _selectedAssignments.removeWhere(
          (assignment) =>
              !_presenter.assignments.contains(assignment),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete assignments: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // First apply the search.
    final assignments = _searchQuery.isEmpty
        ? _presenter.assignments
        : _presenter.searchAssignments(_searchQuery);

    // Then apply the course filter.
    final displayedAssignments = _selectedCourseFilter == null
        ? assignments
        : assignments
            .where(
              (assignment) =>
                  assignment.courseName == _selectedCourseFilter,
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSelecting
              ? '${_selectedAssignments.length} Selected'
              : 'Assignments',
        ),
        actions: [
          // Filter assignments by course.
          if (!_isSelecting && _courseNames.isNotEmpty)
            DropdownButton<String>(
              hint: const Text(
                'All Courses',
                style: TextStyle(color: Colors.white),
              ),
              dropdownColor: Colors.white,
              value: _selectedCourseFilter,
              onChanged: (value) {
                setState(() {
                  _selectedCourseFilter = value;
                });
              },
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Courses'),
                ),
                ..._courseNames.map(
                  (name) => DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  ),
                ),
              ],
            ),

          // Selection mode buttons.
          if (_isSelecting) ...[
            IconButton(
              onPressed: _cancelSelecting,
              icon: const Icon(Icons.close),
              tooltip: 'Cancel selection',
            ),
            IconButton(
              onPressed: _selectedAssignments.isEmpty
                  ? null
                  : () => _deleteSelectedAssignments(),
              icon: const Icon(Icons.delete),
              tooltip: 'Delete selected assignments',
            ),
          ] else
            IconButton(
              onPressed: _startSelecting,
              icon: const Icon(Icons.checklist),
              tooltip: 'Select assignments',
            ),
        ],
      ),

      body: _isLoading
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
                      labelText: 'Search assignments',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                // Assignment list.
                Expanded(
                  child: displayedAssignments.isEmpty
                      ? const Center(
                          child: Text('No assignments found.'),
                        )
                      : ListView.builder(
                          itemCount: displayedAssignments.length,
                          itemBuilder: (context, index) {
                            final assignment =
                                displayedAssignments[index];

                            // Selection mode.
                            if (_isSelecting) {
                              return CheckboxListTile(
                                title: Text(assignment.title),
                                subtitle: Text(
                                  'Course: ${assignment.courseName}',
                                ),
                                value: _selectedAssignments
                                    .contains(assignment),
                                onChanged: (_) {
                                  _toggleSelection(assignment);
                                },
                              );
                            }

                            // Normal mode.
                            return CheckboxListTile(
                              title: Text(assignment.title),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Course: ${assignment.courseName}',
                                  ),
                                  if (assignment.dueDate != null)
                                    Text(
                                      'Due: '
                                      '${assignment.dueDate!.day}/'
                                      '${assignment.dueDate!.month}/'
                                      '${assignment.dueDate!.year}',
                                    )
                                  else
                                    const Text('No due date'),
                                ],
                              ),
                              value: assignment.isCompleted,
                              onChanged: (_) async {
                                final actualIndex = _presenter
                                    .assignments
                                    .indexOf(assignment);

                                if (actualIndex == -1) return;

                                try {
                                  await _presenter
                                      .toggleCompleted(actualIndex);

                                  if (!mounted) return;

                                  setState(() {});
                                } catch (e) {
                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to update assignment: $e',
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),

      // Use only one floating action button.
      floatingActionButton: _isSelecting
          ? null
          : AddFAB(
              onPressed: _showAddAssignmentDialog,
            ),
    );
  }
}
