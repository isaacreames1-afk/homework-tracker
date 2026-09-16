import 'package:flutter/material.dart';
import '../presenters/assignment_presenter.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final AssignmentPresenter _presenter = AssignmentPresenter();

  // Keeps track of which assignments are selected
  final Set<int> _selectedAssignments = {};

  // Tracks whether selection mode is active
  bool _isSelecting = false;

  void _showAddAssignmentDialog() {
    String newAssignmentTitle = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Assignment'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter assignment title',
            ),
            onChanged: (value) {
              newAssignmentTitle = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newAssignmentTitle.trim().isNotEmpty) {
                  setState(() {
                    _presenter.addAssignment(
                      newAssignmentTitle.trim(),
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

  // Start selection mode
  void _startSelecting() {
    setState(() {
      _isSelecting = true;
    });
  }

  // Cancel selection mode
  void _cancelSelecting() {
    setState(() {
      _isSelecting = false;
      _selectedAssignments.clear();
    });
  }

  // Select or deselect an assignment
  void _toggleSelection(int index) {
    setState(() {
      if (_selectedAssignments.contains(index)) {
        _selectedAssignments.remove(index);
      } else {
        _selectedAssignments.add(index);
      }
    });
  }

  // Delete all selected assignments
  void _deleteSelectedAssignments() {
    if (_selectedAssignments.isEmpty) {
      return;
    }

    setState(() {
      // Delete from highest index to lowest index
      // so indexes do not shift incorrectly.
      final sortedIndexes = _selectedAssignments.toList()
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
              onPressed: _selectedAssignments.isEmpty
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

          if (_isSelecting) {
            return CheckboxListTile(
              title: Text(assignment.title),

              // This checkbox is for selecting assignments to delete
              value: _selectedAssignments.contains(index),

              onChanged: (value) {
                _toggleSelection(index);
              },
            );
          }

          return CheckboxListTile(
            title: Text(assignment.title),
            value: assignment.isCompleted,

            // Normal mode: check assignment as completed
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

