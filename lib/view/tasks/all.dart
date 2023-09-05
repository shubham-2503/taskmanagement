import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task_model.dart';

class AllScreen extends StatefulWidget {
  final Task task;
  const AllScreen({super.key, required this.task});

  @override
  State<AllScreen> createState() => _AllScreenState();
}

class _AllScreenState extends State<AllScreen> {
  List<Map<String, dynamic>> activityHistoryData = [];

  Future<List<Map<String, dynamic>>> fetchActivityHistory(String taskId) async {
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
          'http://43.205.97.189:8000/api/History/allActivity?taskId=$taskId'),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as List<dynamic>;
      final activityHistory =
      jsonData.map((item) => item as Map<String, dynamic>).toList();
      return activityHistory;
    } else {
      throw Exception('Failed to load activity history');
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
          future: fetchActivityHistory(widget.task.taskId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingText(); // Show a loading indicator while fetching data.
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              activityHistoryData = snapshot.data ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "All:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor2,
                      ),
                    ),
                  ),
                  SizedBox(height: 2),
                  Expanded(
                    child: ListView.builder(
                      itemCount: activityHistoryData.length,
                      itemBuilder: (context, index) {
                        final activity = activityHistoryData[index];
                        final activityType = activity['type'] as String;
                        final activityComment = activity['comment'] as String;
                        final activityTime = activity['time'] as String;
                        final activityUserName = activity['name'] as String;

                        final taggedUsers = activity['tagged'] != null
                            ? List<Map<String, dynamic>>.from(activity['tagged'])
                            : [];

                        final taggedUserString = taggedUsers
                            .map((taggedUser) => "@${taggedUser['name']}")
                            .join(', ');

                        // Replace tagged usernames with user mentions in the activity comment
                        String displayActivityComment = activityComment;
                        for (Map<String, dynamic> taggedUser in taggedUsers) {
                          final taggedUserName = taggedUser['name'] as String;
                          final userMention = "@$taggedUserName";
                          displayActivityComment = displayActivityComment.replaceAll("@$taggedUserName", userMention);
                        }

                        final textParts = displayActivityComment.split(" ");
                        final userMentionStyle = TextStyle(
                          color: AppColors.primaryColor2,
                          fontWeight: FontWeight.bold,
                        );
                        final commentTextStyle = TextStyle(
                          color: AppColors.blackColor,
                        );

                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              activityType[0],
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: AppColors.primaryColor1,
                          ),
                          title: Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: "$activityUserName:",
                                style: TextStyle(
                                  color: AppColors.secondaryColor2,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  if (textParts.any((textPart) => textPart.startsWith("@")))
                                    ...textParts.map((textPart) {
                                      if (textPart.startsWith("@")) {
                                        // Apply the taggedUserStyle to tagged users
                                        return TextSpan(text: "$textPart  ", style: userMentionStyle);
                                      } else {
                                        // Apply the commentTextStyle to the rest of the comment text
                                        return TextSpan(text: textPart, style: commentTextStyle);
                                      }
                                    }).toList()
                                  else
                                    TextSpan(text: displayActivityComment, style: commentTextStyle),
                                ],
                              ),
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                '${DateFormat('dd MMMM, yyyy hh:mm a').format(DateTime.parse(activityTime))}',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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
