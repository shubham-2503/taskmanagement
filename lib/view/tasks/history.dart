import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/task_model.dart';
import '../../utils/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  final Task task;
  const HistoryScreen({super.key, required this.task});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  Future<List<Map<String, dynamic>>> fetchHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId = prefs.getString(
          "selectedOrgId"); // Get the selected organization ID

      if (orgId == null) {
        // If the user hasn't switched organizations, use the organization ID obtained during login time
        orgId = prefs.getString('org_id') ?? "";
      }

      print("OrgId: $orgId");


      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      print("OrgId: $orgId");

      final response = await http.get(
        Uri.parse(
            'http://43.205.97.189:8000/api/History/history?taskId=${widget.task
                .taskId}'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
        },
      );

      print("TaskId: ${widget.task.taskId}");
      print("Response: ${response.statusCode}");
      print("Statuscode: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as List<dynamic>;
        final historyData =
        jsonData.map((item) => item as Map<String, dynamic>).toList();
        return historyData;
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Widget _buildLoadingText() {
    return Text('Loading data...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingText(); // Show a loading indicator while fetching data.
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final historyData = snapshot.data ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "History:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor1,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: historyData.length,
                      itemBuilder: (context, index) {
                        final historyItem = historyData[index];
                        final userName = historyItem['userName'] as String;
                        final action = historyItem['action'] as String;

                        // Create a TextSpan with different style for the userName
                        final userNameSpan = TextSpan(
                          text: userName,
                          style: TextStyle(
                            color: AppColors.primaryColor1,
                            fontWeight: FontWeight.bold,
                          ),
                        );

                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              userName[0],
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: AppColors.primaryColor1,
                          ),
                          title: Text.rich(
                            TextSpan(
                              text: "$userName: ",
                              style: TextStyle(
                                color: AppColors.secondaryColor2,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: action,
                                  style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          subtitle: Text(
                            '${DateFormat('dd MMMM, yyyy hh:mm a').format(DateTime.parse(historyItem['time']))}',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
