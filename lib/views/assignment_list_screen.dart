import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';
import 'due_date_picker.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() =>
      _AssignmentListScreenState();
}

class _AssignmentListScreenState
    extends State<AssignmentListScreen> {
  final AssignmentPresenter _presenter =
      AssignmentPresenter();

  bool _isLoading = true;

  // Keeps track of which assignments are selected
  final Set<int> _selectedAssignments = {};

  // Tracks whether selection mode is active
  bool _isSelecting = false;

  // Stores the due date for a new assignment
  DateTime? _dueDate;

  // Stores the current search text
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    await _presenter.loadAssignments();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  void _showAddAssignmentDialog() {
    String newAssignmentTitle = '';

    // Reset the date when opening the dialog
    _dueDate = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Assignment'),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Assignment title
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Enter assignment title',
                ),
                onChanged: (value) {
                  newAssignmentTitle = value;
                },
              ),

              const SizedBox(height: 15),

              // Date picker button
              OutlinedButton(
                onPressed: () async {
                  final pickedDate =
                      await selectDueDate(context);

                  if (pickedDate != null) {
                    setState(() {
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

          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            // Add button
            TextButton(
              onPressed: () async {
                if (newAssignmentTitle
                    .trim()
                    .isNotEmpty) {
                  await _presenter.addAssignment(
                    newAssignmentTitle.trim(),
                    _dueDate,
                  );

                  if (!mounted) return;

                  setState(() {});
                }

                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _startSelecting() {
    setState(() {
      _isSelecting = true;
    });
  }

  void _cancelSelecting() {
    setState(() {
      _isSelecting = false;
      _selectedAssignments.clear();
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedAssignments.contains(index)) {
        _selectedAssignments.remove(index);
      } else {
        _selectedAssignments.add(index);
      }
    });
  }

  void _deleteSelectedAssignments() {
    if (_selectedAssignments.isEmpty) {
      return;
    }

    setState(() {
      // Delete from highest index to lowest index
      final sortedIndexes =
          _selectedAssignments.toList()
            ..sort((a, b) => b.compareTo(a));

      for (final index in sortedIndexes) {
        _presenter.assignments.removeAt(index);
      }

      _selectedAssignments.clear();
      _isSelecting = false;
    });
  }

@override
Widget build(BuildContext context) {
  final assignments = _searchQuery.isEmpty
      ? _presenter.assignments
      : _presenter.searchAssignments(_searchQuery);

  return Scaffold(
    appBar: AppBar(
      title: Text(
        _isSelecting
            ? '${_selectedAssignments.length} Selected'
            : 'Assignments',
      ),
      actions: [
        if (_isSelecting) ...[
          IconButton(
            onPressed: _cancelSelecting,
            icon: const Icon(Icons.close),
            tooltip: 'Cancel',
          ),
          IconButton(
            onPressed: _selectedAssignments.isEmpty
                ? null
                : _deleteSelectedAssignments,
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
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

              Expanded(
                child: ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = assignments[index];

                    if (_isSelecting) {
                      return CheckboxListTile(
                        title: Text(assignment.title),
                        value: _selectedAssignments.contains(index),
                        onChanged: (value) {
                          _toggleSelection(index);
                        },
                      );
                    }

                    return CheckboxListTile(
                      title: Text(assignment.title),
                      subtitle: assignment.dueDate != null
                          ? Text(
                              'Due: '
                              '${assignment.dueDate!.day}/'
                              '${assignment.dueDate!.month}/'
                              '${assignment.dueDate!.year}',
                            )
                          : const Text('No due date'),
                      value: assignment.isCompleted,
                      onChanged: (value) async {
                        await _presenter.toggleCompleted(index);

                        if (!mounted) return;

                        setState(() {});
                      },
                    );
                  },
                ),
              ),
            ],
          ),

    floatingActionButton: _isSelecting
        ? null
        : FloatingActionButton(
            onPressed: _showAddAssignmentDialog,
            child: const Icon(Icons.add),
          ),
    );
  }
}