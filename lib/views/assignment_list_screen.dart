import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';
import 'due_date_picker.dart';

class AssignmentListScreen extends StatefulWidget { const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final AssignmentPresenter _presenter =AssignmentPresenter();

  // Keeps track of which assignments are selected
  final Set<int> _selectedAssignments = {};

  // Tracks whether selection mode is active
  bool _isSelecting = false;

  // Stores the due date for a new assignment
  DateTime? _dueDate;


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
              onPressed: () {

                if (newAssignmentTitle
                    .trim()
                    .isNotEmpty) {

                  setState(() {
                    _presenter.addAssignment(
                      newAssignmentTitle.trim(),
                      _dueDate,
                    );
                  });
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

    final assignments = _presenter.assignments;

    return Scaffold(

      appBar: AppBar(
        title: Text(
          _isSelecting
              ? '${_selectedAssignments.length} Selected'
              : 'Assignments',
        ),

        actions: [

          if (_isSelecting) ...[

            // Cancel selection
            IconButton(
              onPressed: _cancelSelecting,
              icon: const Icon(Icons.close),
              tooltip: 'Cancel',
            ),

            // Delete selected assignments
            IconButton(
              onPressed:
                  _selectedAssignments.isEmpty
                      ? null
                      : _deleteSelectedAssignments,
              icon: const Icon(Icons.delete),
              tooltip: 'Delete',
            ),

          ] else

            // Enter selection mode
            IconButton(
              onPressed: _startSelecting,
              icon: const Icon(Icons.checklist),
              tooltip: 'Select assignments',
            ),
        ],
      ),

      body: ListView.builder(
        itemCount: assignments.length,

        itemBuilder: (context, index) {

          final assignment = assignments[index];

          // Selection mode
          if (_isSelecting) {

            return CheckboxListTile(
              title: Text(assignment.title),

              value: _selectedAssignments.contains(index),

              onChanged: (value) {
                _toggleSelection(index);
              },
            );
          }

          // Normal mode
          return CheckboxListTile(
            title: Text(assignment.title),

            // Show due date underneath assignment
            subtitle: assignment.dueDate != null
                ? Text(
                    'Due: '
                    '${assignment.dueDate!.day}/'
                    '${assignment.dueDate!.month}/'
                    '${assignment.dueDate!.year}',
                  )
                : const Text('No due date'),

            value: assignment.isCompleted,

            // Mark assignment as completed
            onChanged: (value) {
              setState(() {
                _presenter.toggleCompleted(index);
              });
            },
          );
        },
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