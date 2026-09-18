import 'package:flutter/material.dart';

Future<DateTime?> selectDueDate(BuildContext context) async {
  return await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2030),
  );
}