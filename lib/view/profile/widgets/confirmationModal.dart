import 'package:flutter/material.dart';

class DeleteConfirmationModal extends StatelessWidget {
  final VoidCallback onConfirm;

  DeleteConfirmationModal({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Confirm Deletion",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text("Are you sure you want to delete this organization?"),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the modal when cancel is pressed
                },
                child: Text("Cancel"),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: onConfirm,
                child: Text("Delete"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
