import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_colors.dart';

class MyFilterOptionsModal extends StatefulWidget {
  @override
  _MyFilterOptionsModalState createState() => _MyFilterOptionsModalState();
}

class _MyFilterOptionsModalState extends State<MyFilterOptionsModal> {
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  List<String> priorities = [];
  List<String> status = [];
  String? selectedStatus;
  String? selectedpriority;
  String? selectedReportType;
  String? selectedOnSchedule;

  @override
  void initState() {
    super.initState();
    // Fetch data when the widget initializes
    fetchAllData();
  }

  Future<void> fetchData({String? reportType, bool? active, String? onSchedule, String? priority, String? status, String? startDate, String? endDate}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final storedData = prefs.getString('jwtToken');
  String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

  if (orgId == null) {
    // If the user hasn't switched organizations, use the organization ID obtained during login time
    orgId = prefs.getString('org_id') ?? "";
  }


  print("OrgId: $orgId");

  if (orgId == null) {
    throw Exception('orgId not found locally');
  }

  final Url = 'http://43.205.97.189:8000/api/Common/taskReport?org_id=$orgId'; // Replace with your API base URL
  // By default, set active to true
  bool active = true;

  // If the status is 'completed', set active to false
  if (status == 'completed') {
    active = false;
  }

  // Construct the query parameters
  final queryParams = {
    'org_id': orgId,
    if (reportType != null) 'report_type': reportType,
    if (active != null) 'active': active.toString(),
    if (onSchedule != null) 'on_schedule': onSchedule,
    if (priority != null) 'priority': priority,
    if (status != null) 'status': status,
    if (startDate != null) 'start_date': startDate,
    if (endDate != null) 'end_date': endDate,
  };

  // Print the query parameters in JSON format
  final queryParamsJson = jsonEncode(queryParams);
  print('Query Parameters: $queryParamsJson');

  final url = Uri.parse(Url).replace(queryParameters: queryParams);

  final headers = {
    'Authorization': 'Bearer $storedData', // Add the Authorization header with the JWT token
  };

  try {
    final response = await http.get(url);
    print("StatusCode: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      print("Successfully fetched the Reports");
    } else if (response.statusCode == 401) {
      print("Failed to fetched the Reports: ${response.statusCode}");
    } else if (response.statusCode == 403) {
      // Handle forbidden error
      print("Failed to fetched the Reports: ${response.statusCode}");
    } else {
      // Handle other errors
      print("Failed to fetched the Reports: ${response.statusCode}");
    }
  } catch (e) {
    // Handle network or other errors
    print("Failed to fetched the Reports");
  }
}

  Future<void> fetchAllData() async {
    try {
      priorities = await fetchPriorities();
      status = await fetchStatus();
      setState(() {});
    } catch (error) {
      // Handle error if necessary
    }
  }

  Future<List<String>> fetchPriorities() async {
    final response =
    await http.get(Uri.parse('http://43.205.97.189:8000/api/Platform/getPriorities'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item['name'] as String).toList();
    } else {
      throw Exception('Failed to fetch priorities');
    }
  }

  Future<List<String>> fetchStatus() async {
    final response =
    await http.get(Uri.parse('http://43.205.97.189:8000/api/Platform/getStatus'));

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
                          // // Call the fetchData API function here
                          // fetchData(
                          //   reportType: selectedReportType,
                          //   active: selectedStatus == 'completed' ? false : true,
                          //   onSchedule: selectedOnSchedule,
                          //   priority: selectedpriority,
                          //   status: selectedStatus,
                          //   startDate: _startDateController.text,
                          //   endDate: _endDateController.text,
                          // );
                        },
                        child: Text(
                          "APPLY",
                          style: TextStyle(
                            color: AppColors.secondaryColor2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor1),
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
                                fontSize: 10, // Set the font size for the selected date
                                color: AppColors.secondaryColor2,
                                fontWeight: FontWeight.bold
                            ),
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
                                fontSize: 10, // Set the font size for the selected date
                                color: AppColors.secondaryColor2,
                                fontWeight: FontWeight.bold
                            ),
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
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Type',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedReportType = 'MyReport';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: selectedReportType == 'MyReport' ? AppColors.secondaryColor2 : AppColors.primaryColor1,
                        ),
                        child: Text('My Report'),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedReportType = 'TeamReport';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: selectedReportType == 'TeamReport' ? AppColors.secondaryColor2 : AppColors.primaryColor1,
                        ),
                        child: Text('Team Report'),
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
                  'On Schedule',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedOnSchedule = 'OnTrack';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: selectedOnSchedule == 'OnTrack' ? AppColors.secondaryColor2 : AppColors.primaryColor1,
                        ),
                        child: Text('On Track'),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedOnSchedule = 'OffTrack';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: selectedOnSchedule == 'offTrack' ? AppColors.secondaryColor2 : AppColors.primaryColor1,
                        ),
                        child: Text('Off Track'),
                      ),
                    ),
                  ],
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

