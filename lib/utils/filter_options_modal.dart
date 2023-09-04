import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../view/tasks/tasks.dart';
import 'app_colors.dart';

class FilterOptionsModal extends StatefulWidget {
  final Function(Map<String, String?>) onApplyFilters;

  FilterOptionsModal({required this.onApplyFilters});
  @override
  _FilterOptionsModalState createState() => _FilterOptionsModalState();
}

class _FilterOptionsModalState extends State<FilterOptionsModal> {
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  List<String> priorities = [];
  List<String> status = [];
  String? selectedStatus;
  String? selectedpriority;

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  void applyFilters(
      {String? startDate,
      String? endDate,
      String? selectedPriority,
      String? selectedStatus}) {
    startDate = (startDate?.isEmpty ?? true) ? null : startDate;
    endDate = (endDate?.isEmpty ?? true) ? null : endDate;
    selectedPriority =
        (selectedPriority?.isEmpty ?? true) ? null : selectedPriority;
    selectedStatus = (selectedStatus?.isEmpty ?? true) ? null : selectedStatus;

    final Map<String, String?> filters = {
      'startDate': startDate ?? null,
      'endDate': endDate ?? null,
      'priority': selectedPriority,
      'status': selectedStatus,
    };

    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              TaskScreen(), // Replace with your screen widget
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(
              opacity: anim,
              child: child,
            );
          },
        ));
  }

  Future<void> fetchAllData() async {
    try {
      priorities = await fetchPriorities();
      status = await fetchStatus();
      setState(() {});
    } catch (error) {}
  }

  Future<List<String>> fetchPriorities() async {
    final response = await http
        .get(Uri.parse('http://43.205.97.189:8000/api/Platform/getPriorities'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item['name'] as String).toList();
    } else {
      throw Exception('Failed to fetch priorities');
    }
  }

  Future<List<String>> fetchStatus() async {
    final response = await http
        .get(Uri.parse('http://43.205.97.189:8000/api/Platform/getStatus'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item['name'] as String).toList();
    } else {
      throw Exception('Failed to fetch status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Date Range',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () {
                          Map<String, String?> selectedFilters = {
                            'startDate': _startDateController.text,
                            'endDate': _endDateController.text,
                            'priority': selectedpriority,
                            'status': selectedStatus,
                          };

                          // Call the callback function to update filters and refresh data
                          widget.onApplyFilters(selectedFilters);

                          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>TaskScreen()));
                          // Navigator.pushReplacement(
                          //     context,
                          //     PageRouteBuilder(
                          //       pageBuilder: (_, __, ___) =>
                          //           TaskScreen(), // Replace with your screen widget
                          //       transitionsBuilder: (_, anim, __, child) {
                          //         return FadeTransition(
                          //           opacity: anim,
                          //           child: child,
                          //         );
                          //       },
                          //     ));
                          applyFilters(
                            startDate: _startDateController.text,
                            endDate: _endDateController.text,
                            selectedPriority: selectedpriority,
                            selectedStatus: selectedStatus,
                          );
                        },
                        child: Text(
                          "APPLY",
                          style: TextStyle(
                            color: AppColors.secondaryColor2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor1),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          DatePicker.showDatePicker(
                            context,
                            showTitleActions: true,
                            onConfirm: (date) {
                              _startDateController.text = formatDate(date);
                            },
                            currentTime: DateTime.now(),
                            locale: LocaleType.en,
                          );
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _startDateController,
                            decoration: InputDecoration(
                              labelText: 'from',
                              labelStyle: TextStyle(
                                fontSize: 10,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            style: TextStyle(
                                fontSize:
                                    10, // Set the font size for the selected date
                                color: AppColors.secondaryColor2,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          DatePicker.showDatePicker(
                            context,
                            showTitleActions: true,
                            onConfirm: (date) {
                              _endDateController.text = formatDate(date);
                            },
                            currentTime: DateTime.now(),
                            locale: LocaleType.en,
                          );
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _endDateController,
                            decoration: InputDecoration(
                              labelText: 'To',
                              labelStyle: TextStyle(
                                fontSize: 10,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            style: TextStyle(
                                fontSize:
                                    10, // Set the font size for the selected date
                                color: AppColors.secondaryColor2,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Priority',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    for (String priority in priorities)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedpriority = priority;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: priority == selectedpriority
                                ? AppColors.secondaryColor2
                                : AppColors.primaryColor1,
                          ),
                          child: Text(priority),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (String statue in status)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedStatus = statue;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: statue == selectedStatus
                                  ? AppColors.secondaryColor2
                                  : AppColors.primaryColor1,
                            ),
                            child: Text(statue),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String formatDate(DateTime date) {
  final formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(date);
}
