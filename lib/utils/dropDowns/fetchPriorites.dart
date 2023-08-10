import 'package:flutter/material.dart';
import '../../View_model/fetchApiSrvices.dart';
import '../app_colors.dart';

class FetchPriorityDropdown extends StatefulWidget {
  final Function(String?) onPriorityChanged;

  FetchPriorityDropdown({required this.onPriorityChanged});

  @override
  _FetchPriorityDropdownState createState() => _FetchPriorityDropdownState();
}

class _FetchPriorityDropdownState extends State<FetchPriorityDropdown> {
  List<dynamic> priorities = [];
  String? _selectedPriority;

  @override
  void initState() {
    super.initState();
    fetchPriorities();
  }

  Future<void> fetchPriorities() async {
    try {
      List<dynamic> fetchedPriorities = await ApiServices.fetchPriorities();
      setState(() {
        priorities = fetchedPriorities;
        // Check if priorities list is not empty
        if (priorities.isNotEmpty) {
          // Initialize _selectedPriority to the first priority ID in the list
          _selectedPriority = priorities[0]['id'];
        } else {
          // If priorities list is empty, set _selectedPriority to null
          _selectedPriority = null;
        }
      });
    } catch (e) {
      print('Error fetching priorities: $e');
      // Handle error if necessary
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrayColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedPriority,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 15,
          ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: "Priority",
          hintStyle: TextStyle(
            fontSize: 12,
            color: AppColors.grayColor,
          ),
          icon: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Image.asset(
              "assets/images/pri.png",
              width: 20,
              color: Colors.grey,
            ),
          ),
        ),
        items: priorities.map((priority) {
          return DropdownMenuItem<String>(
            value: priority['id'],
            child: Text(priority['name']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedPriority = value;
            widget.onPriorityChanged(value); // Call the callback function
          });
        },
      ),
    );
  }
}
