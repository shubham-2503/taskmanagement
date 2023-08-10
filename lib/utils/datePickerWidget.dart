import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_colors.dart';

class DatePickerWidget extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController textEditingController;
  final Function(DateTime) onDateSelected;

  const DatePickerWidget({
    required this.hintText,
    required this.icon,
    required this.textEditingController,
    required this.onDateSelected,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != textEditingController.text) {
      onDateSelected(pickedDate);
      textEditingController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 180,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppColors.lightGrayColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _selectDate(context); // Open the date picker on icon tap
            },
            child: Icon(icon),
          ),
          Expanded(
            child: TextFormField(
              controller: textEditingController,
              readOnly: true,
              onTap: () {
                _selectDate(context); // Open the date picker on text field tap
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
