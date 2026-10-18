import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../presenters/assignment_presenter.dart';
import '../theme/app_gradients.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AssignmentPresenter _presenter = AssignmentPresenter();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    await _presenter.loadAssignments();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = _presenter.completionRatio;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework Tracker'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          :Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppGradients.mitsuri,
              ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: CircularPercentIndicator(
                      radius: 120.0,
                      lineWidth: 14.0,
                      percent: percent,
                      center: Text(
                        '${(percent * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      progressColor: Colors.purple,
                      backgroundColor: Colors.grey.shade300,
                      animation: true,
                      animationDuration: 800,
                      footer: const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('Assignments Completed'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Card(
                    child: ListTile(
                      title: const Text('Total Assignments'),
                      trailing: Text('${_presenter.totalAssignments}'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Completed Assignments'),
                      trailing: Text('${_presenter.completedAssignments}'),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
