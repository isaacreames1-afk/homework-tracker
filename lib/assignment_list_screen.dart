
import 'package:flutter/material.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final List<Map<String, dynamic>> _assignments = [];

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
                    _assignments.add({
                      'title': newAssignmentTitle.trim(),
                      'completed': false,
                    });
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

  void _toggleCompleted(int index, bool? value) {
    setState(() {
      _assignments[index]['completed'] = value ?? false;
    });
  }

  // Select or unselect an assignment
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
    setState(() {
      // Delete from highest index to lowest index
      // so the indexes do not shift incorrectly
      final sortedIndexes = _selectedAssignments.toList()
        ..sort((a, b) => b.compareTo(a));

      for (final index in sortedIndexes) {
        _assignments.removeAt(index);
      }

      _selectedAssignments.clear();
      _isSelecting = false;
    });
  }

  // Enter selection mode
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSelecting
              ? '${_selectedAssignments.length} selected'
              : 'Assignments',
        ),

        actions: [
          if (_isSelecting)
            TextButton(
              onPressed: _selectedAssignments.isEmpty
                  ? null
                  : _deleteSelectedAssignments,
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            )
          else
            TextButton(
              onPressed: _startSelecting,
              child: const Text('Delete'),
            ),

          if (_isSelecting)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelSelecting,
            ),
        ],
      ),

      body: ListView.builder(
        itemCount: _assignments.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedAssignments.contains(index);

          return CheckboxListTile(
            title: Text(_assignments[index]['title']),
            value: _isSelecting
                ? isSelected
                : _assignments[index]['completed'],

            // In selection mode, checkbox selects assignments
            onChanged: (value) {
              if (_isSelecting) {
                _toggleSelection(index);
              } else {
                _toggleCompleted(index, value);
              }
            },

            // Highlight selected assignments
            selected: _isSelecting && isSelected,
            selectedTileColor: Colors.blue.withOpacity(0.1),
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
