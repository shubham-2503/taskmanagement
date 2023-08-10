import 'package:flutter/material.dart';
import '../../View_model/fetchApiSrvices.dart';
import '../app_colors.dart';

class FetchStatusDropdown extends StatefulWidget {
  final Function(String?) onStatusChanged;

  FetchStatusDropdown({required this.onStatusChanged});

  @override
  _FetchStatusDropdownState createState() => _FetchStatusDropdownState();
}

class _FetchStatusDropdownState extends State<FetchStatusDropdown> {
  List<dynamic> statuses = [];
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    fetchStatusData();
  }

  Future<void> fetchStatusData() async {
    try {
      List<dynamic> fetchedStatuses = await ApiServices.fetchStatusData();
      setState(() {
        statuses = fetchedStatuses;
        // Check if statuses list is not empty
        if (statuses.isNotEmpty) {
          // Initialize _selectedStatus to the first status ID in the list
          _selectedStatus = statuses[0]['id'].toString();
        } else {
          // If statuses list is empty, set _selectedStatus to null
          _selectedStatus = null;
        }
      });
    } catch (e) {
      print('Error fetching statuses: $e');
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
        value: _selectedStatus,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 15,
          ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: "Status",
          hintStyle: TextStyle(
            fontSize: 12,
            color: Colors.grey,
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
        items: statuses.map<DropdownMenuItem<String>>((status) {
          return DropdownMenuItem<String>(
            value: status['id'].toString(), // Assuming 'id' is of type String or can be converted to String
            child: Text(status['name']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedStatus = value;
            widget.onStatusChanged(value); // Call the callback function with the selected value
          });
        },
      ),
    );
  }
}
