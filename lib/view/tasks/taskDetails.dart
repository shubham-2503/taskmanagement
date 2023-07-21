import 'dart:convert';

import 'package:flutter/material.dart';
import '../../common_widgets/round_textfield.dart';
import '../../utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;


enum Activity{
  All,
  Comments,
  History,
}

class TaskDetailsScreen extends StatefulWidget {
  final String? projectName;
  final String taskTitle;
  final String assignee;
  final String? status;

  TaskDetailsScreen({
    this.projectName,
    required this.taskTitle,
    required this.assignee,
    this.status,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  Activity _selectedActivityType = Activity.All;
  TextEditingController _mentionController = TextEditingController();
  TextEditingController _commentController = TextEditingController();
  String? _selectedStatus;

  List<String> historyLog = [];

  List<String> comments = [
    'Looking forward to the next update.',
    'I have a suggestion for improvement.',
    'Well done! Keep up the good work.',
  ];

  List<Map<String, String>> All = [
    {'type': 'Comment', 'text': 'Well done! Keep up the good work.'},
    {'type': 'History', 'text': 'Aman changes the Status'},
    {'type': 'Comment', 'text': 'I have a suggestion for improvement.'},
    {'type': 'Comment', 'text': 'Looking forward to the next update.'},
    {'type': 'History', 'text': 'Aman updates summary'},
    {'type': 'History', 'text': 'Aman created the task'},
  ];

  Color getCircleAvatarColor(String entry) {
    if (entry.contains('Comment:')) {
      return AppColors.primaryColor1;
    } else if (entry.contains('History:')) {
      return AppColors.secondaryColor2;
    }
    return Colors.transparent; // Default color
  }

  Color getTextColor(String entry) {
    if (entry.startsWith('Comment:')) {
      return AppColors.secondaryColor2;
    } else if (entry.startsWith('History:')) {
      return AppColors.primaryColor1;
    }
    return Colors.transparent; // Default color
  }

  IconData getLeadingIcon(String entry) {
    if (entry.startsWith('Comment:')) {
      return Icons.comment;
    } else if (entry.startsWith('History:')) {
      return Icons.history;
    }
    return Icons.error; // Default icon
  }

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.status;
    _fetchHistoryLog();
  }

  Future<void> _fetchHistoryLog() async {
    try {
      // Replace 'YOUR_HISTORY_LOG_API_ENDPOINT' with the actual API endpoint URL
      final apiUrl = 'http://43.205.97.189:8000/api/History/history';
      // final taskId = widget.taskId; // Assuming you have a widget property containing the task ID
      final response = await http.post(Uri.parse(apiUrl),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            // 'taskId': taskId,
          }));

      if (response.statusCode == 200) {
        // If the API call is successful, parse the response JSON
        final data = jsonDecode(response.body);
        // Assuming the API response contains a list of history log strings
        List<String> historyData = List<String>.from(data['result']);
        setState(() {
          historyLog = historyData;
        });
      } else {
        // Handle API call failure
        // You may want to display an error message or retry the request
      }
    } catch (e) {
      // Handle exceptions
      // You may want to display an error message or retry the request
    }
  }


  Widget _buildReportTypeText() {
    switch (_selectedActivityType) {
      case Activity.History:
        return Flexible(
          fit: FlexFit.loose,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "History:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryColor2,
                  ),
                ),
                SizedBox(height: 2,),
                Expanded(
                  child: ListView.builder(
                    itemCount: historyLog.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            historyLog[index][0],
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: AppColors.primaryColor1,
                        ),
                        title: Text(
                          historyLog[index],
                          style: TextStyle(
                            color: AppColors.secondaryColor2,
                          ),
                        ),
                        subtitle: Text(
                          '${DateFormat('dd MMMM, yyyy hh:mm a').format(DateTime.now())}',
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
            ),
          ),
        );
      case Activity.Comments:
        return Flexible(
          fit: FlexFit.loose,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Comments:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor2,
                ),
              ),
              SizedBox(height: 2,),
              Expanded(
                child: ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          comments[index][0],
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: AppColors.secondaryColor2,
                      ),
                      title: Text(
                        comments[index],
                        style: TextStyle(
                          color: AppColors.primaryColor2,
                        ),
                      ),
                      subtitle: Text(
                        '${DateFormat('dd MMMM, yyyy hh:mm a').format(DateTime.now())}',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RoundTextField(
                  hintText: "Add comments",
                  icon: "assets/images/comments.png",
                  textInputType: TextInputType.text,
                  onChanged: (value) {
                    if (value.contains('@')) {
                      String mentionedUser = value.substring(value.indexOf('@') + 1);
                      // TODO: Implement logic to search for suggested users based on the mentionedUser value
                      // You can use a FutureBuilder or any other method to fetch and display the suggested users
                      List<String> suggestedUsers = ['Samridhi', 'Aman']; // Dummy list of suggested users

                      // Show suggestions if there are any
                      if (suggestedUsers.isNotEmpty) {
                        showUserSuggestions(context, mentionedUser, suggestedUsers, _mentionController);
                      }

                      _mentionController.text = value;
                    }
                  },
                ),
              ),
            ],
          ),
        );
      default:
        return Flexible(
          fit: FlexFit.loose,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "All:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryColor2,
                  ),
                ),
                SizedBox(height: 2),
                Expanded(
                  child: ListView.builder(
                    itemCount: All.length,
                    itemBuilder: (context, index) {
                      final entry = All[index];
                      final isComment = entry['type'] == 'Comment';

                      return ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            isComment ? Icons.comment : Icons.history,
                            color: Colors.white,
                          ),
                          backgroundColor: isComment ? AppColors.primaryColor1 : AppColors.secondaryColor2,
                        ),
                        title: Text(
                          entry['text'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isComment ? AppColors.secondaryColor2 : AppColors.primaryColor1,
                          ),
                        ),
                        subtitle: Text(
                          '${DateFormat('dd MMMM, yyyy hh:mm a').format(DateTime.now())}',
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
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectName = widget.projectName;
    final taskTitle = widget.taskTitle;
    final assignee = widget.assignee;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 60, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back_ios)),
                Image.asset("assets/images/magic.png", width: 30,),
                SizedBox(width: 5,),
                Text(
                  taskTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15,),
            Text(
              taskTitle,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor2
              ),
            ),
            SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                width: 130,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor2,
                ),
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration.collapsed(hintText: ''),
                  value: _selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedItemBuilder: (BuildContext context) {
                    return [
                      Text(
                        'In-Progress',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Open',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Completed',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Transferred',
                        style: TextStyle(color: Colors.white),
                      ),
                    ];
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'In-Progress',
                      child: Text(
                        'In-Progress',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Open',
                      child: Text(
                        'Open',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Completed',
                      child: Text(
                        'Completed',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Transferred',
                      child: Text(
                        'Transferred',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 26.0),
            Row(
              children: [
                Image.asset("assets/images/att.png", width: 30, height: 20,),
                Text(
                  'Attachments',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            SizedBox(height: 26.0),
            Row(
              children: [
                Image.asset("assets/images/pers.png", width: 30, height: 20,),
                Text(
                  'Assignee',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(assignee, style: TextStyle(
                  fontSize: 15,
                  color: AppColors.primaryColor2
              ),),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Image.asset("assets/images/complete_task.jpeg", width: 30, height: 20,),
                SizedBox(width: 10,),
                Text(
                  'Created By',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text('Jane Smith', style: TextStyle(
                  fontSize: 15,
                  color: AppColors.primaryColor2
              ),),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Image.asset("assets/icons/date.png", width: 30, height: 20,),
                SizedBox(width: 10,),
                Text(
                  'Created Date and Time',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text('2023-07-12 10:30 AM', style: TextStyle(
                  fontSize: 15,
                  color: AppColors.primaryColor2
              ),),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset("assets/icons/activity_select_icon.png", width: 30, height: 20,),
                    SizedBox(width: 10,),
                    Text(
                      'Activity',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<Activity>(
                    decoration: InputDecoration.collapsed(hintText: ''),
                    value: _selectedActivityType,
                    onChanged: (value) {
                      setState(() {
                        _selectedActivityType = value!;
                      });
                    },
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return [
                        Text(
                          'All',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Comments',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Activity',
                          style: TextStyle(color: Colors.white),
                        ),
                      ];
                    },
                    items: Activity.values.map((activity) {
                      return DropdownMenuItem<Activity>(
                        value: activity,
                        child: Text(
                          activity.toString().split('.').last,
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            _buildReportTypeText(),
          ],
        ),
      ),
    );
  }

  void showUserSuggestions(BuildContext context, String query, List<String> suggestedUsers, TextEditingController _mentionController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          insetPadding: EdgeInsets.symmetric(vertical: 10),
          title: Text('User Suggestions'),
          content: Container(
            width: 300, // Adjust the width value as needed
            height: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: suggestedUsers.length,
                    itemBuilder: (BuildContext context, int index) {
                      final user = suggestedUsers[index];
                      return ListTile(
                        title: Text(user),
                        onTap: () {
                          // Replace the text in the comment field with the selected user
                          _mentionController.text = user;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

