import 'package:flutter/material.dart';

class DatePickerUtils {
  static Future<DateTime?> selectStartDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
  }

  static Future<DateTime?> selectEndDate(BuildContext context, DateTime? startDate) async {
    return await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
  }
}
