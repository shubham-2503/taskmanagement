import 'dart:convert';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/fetch_user_model.dart';
import '../../utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

enum Activity {
  All,
  Comments,
  History,
}

class TaskDetailsScreen extends StatefulWidget {
  final String? taskId;
  final String? projectName;
  final String taskTitle;
  final String assignee;
  final String? status;

  TaskDetailsScreen({
    this.projectName,
    required this.taskTitle,
    required this.assignee,
    this.status,
    this.taskId,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  Activity _selectedActivityType = Activity.All;
  GlobalKey<AutoCompleteTextFieldState<String>> _autoCompleteKey = GlobalKey();
  TextEditingController _commentController = TextEditingController();
  List<String> suggestedUsers = [];
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
    _selectedStatus =
        widget.status; // Call the method to fetch history logs and comments
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      final response = await http.get(
        Uri.parse('http://43.205.97.189:8000/api/UserAuth/getOrgUsers'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
        },
      );

      print("Stored: $storedData");
      print("API response: ${response.body}");
      print("StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody != null && responseBody.isNotEmpty) {
          final List<dynamic> data = jsonDecode(responseBody);
          final List<String> users = data.map((userJson) => User.fromJson(userJson).userName).toList();

          setState(() {
            suggestedUsers = users;
          });

          // Print the user names for testing
          for (String userName in suggestedUsers) {
            print('User Name: $userName');
          }
        } else {
          print('Failed to fetch users: Response body is null or empty');
          throw Exception('Failed to fetch users');
        }
      } else {
        print('Failed to fetch users: StatusCode: ${response.statusCode}');
        throw Exception('Failed to fetch users');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch users');
    }
  }

  Future<List<Map<String, dynamic>>> fetchHistory() async {
    final response = await http.post(
      Uri.parse('http://43.205.97.189:8000/api/History/history?taskId=${widget.taskId}'),
    );
    print("TaskId: ${widget.taskId}");
    print("Response: ${response.statusCode}");
    print("Statuscode: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      final historyList = jsonData['result'] as List<dynamic>;

      // Convert historyList to List<Map<String, dynamic>>
      final historyData = historyList.cast<Map<String, dynamic>>();

      return historyData;
    } else {
      throw Exception('Failed to load history');
    }
  }


  Future<List<String>> fetchComments() async {
    final response = await http.get(
      Uri.parse('http://43.205.97.189:8000/api/Comment/getComment/${widget.taskId}'),
    );

    print("response: ${response.body}");
    print("StatusCode: ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((item) => item['text'] as String).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }



  Widget _buildReportTypeText() {
    switch (_selectedActivityType) {
      case Activity.History:
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Show a loading indicator while fetching data.
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final historyData = snapshot.data ?? [];
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
                      SizedBox(
                        height: 2,
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
                                color: AppColors.primaryColor1, // Set the desired color for the userName
                                fontWeight: FontWeight.bold, // You can customize other styles as well
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
                              title: RichText(
                                text: TextSpan(
                                  children: [
                                    userNameSpan, // Add the userName span to the TextSpan
                                    TextSpan(text: '$action',style: TextStyle(
                                      color: Colors.black54
                                    )), // Add the action to the TextSpan
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
                  ),
                ),
              );
            }
          },
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
                    SizedBox(
                      height: 2,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final entry = comments[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                comments[0],
                                style: TextStyle(
                                  color: Colors.white,
                                ),
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
                    RoundButton(
                      title: "Add Comments",
                      onPressed: () {
                        _showAddCommentsDialog(widget.taskId!);
                      },
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
                          backgroundColor: isComment
                              ? AppColors.primaryColor1
                              : AppColors.secondaryColor2,
                        ),
                        title: Text(
                          entry['text'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isComment
                                ? AppColors.secondaryColor2
                                : AppColors.primaryColor1,
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

  void _showAddCommentsDialog(String taskId) {
    List<String> mentionedUserIds = [];
    print("TaskId: $taskId");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Comments"),
          content: Form(
            child: TypeAheadFormField<String>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _commentController,
                onChanged: (text) {
                  // Check if "@" is typed and there is at least one character after it
                  if (text.endsWith("@") && text.length > 1) {
                    // Trigger fetching users when "@" is typed and there is at least one character after it
                    fetchUsers();
                  }
                },
                decoration: InputDecoration(
                  hintText: "Write your comment...",
                ),
              ),
              suggestionsCallback: (pattern) async {
                // Check if "@" is present in the input pattern and it's not the first character
                final atIndex = pattern.indexOf("@");
                if (atIndex != -1 && atIndex + 1 < pattern.length) {
                  // Filter the suggested users based on the input pattern after the "@" symbol
                  final searchQuery = pattern.substring(atIndex + 1).toLowerCase();
                  final filteredUsers = suggestedUsers
                      .where((user) => user.toLowerCase().contains(searchQuery))
                      .toList();
                  return filteredUsers;
                } else {
                  // Return an empty list if "@" is not followed by any characters
                  return suggestedUsers;
                }
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              onSuggestionSelected: (suggestion) async {
                // Append the selected suggestion to the comment box
                // Fetch the userId corresponding to the mentioned username
                final userId = await getUserIdByUsername(suggestion);
                // Add the userId to the mentionedUserIds list
                setState(() {
                  mentionedUserIds.add(userId);
                });

                // Append the selected suggestion to the comment box
                final currentText = _commentController.text;
                final lastAtSymbolIndex = currentText.lastIndexOf("@");
                final newText =
                    currentText.substring(0, lastAtSymbolIndex) + "@$suggestion ";

                // Clear the input field
                _commentController.clear();
                _commentController.text = newText;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await addComment(taskId, _commentController.text, mentionedUserIds);
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<String> getUserIdByUsername(String username) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      final response = await http.get(
        Uri.parse('http://43.205.97.189:8000/api/UserAuth/getOrgUsers'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
        },
      );

      print('API Response: ${response.body}');
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        final user = users.firstWhere(
              (user) => user['name'].toLowerCase() == username.toLowerCase(),
          orElse: () => null,
        );

        if (user != null) {
          final String userId = user['id'];
          return userId;
        } else {
          // User not found with the given username
          throw Exception('User not found');
        }
      } else {
        // Failed to fetch users from the API
        throw Exception('Failed to fetch users');
      }
    } catch (e) {
      // Handle any exceptions that may occur during the API call
      print('Error: $e');
      throw Exception('Failed to get userId by username');
    }
  }

  Future<void> addComment(String taskId, String commentText, List<String> mentionedUserIds) async {
    try {
      if (commentText.isEmpty) {
        // Ensure the comment text is not empty
        throw Exception('Comment cannot be empty');
      }

      // Check if the comment contains mentions
      final mentionPattern = RegExp(r'@\w+');
      Iterable<Match> mentionMatches = mentionPattern.allMatches(commentText);
      String cleanedCommentText = commentText;
      if (mentionMatches.isNotEmpty) {
        // Remove mentions from the comment text
        cleanedCommentText = commentText.replaceAll(RegExp(r'@\w+'), '').trim();
        // Extract the mentioned users and add them to the mentionedUserIds list
        for (Match match in mentionMatches) {
          String mention = match.group(0)!;
          String username = mention.substring(1); // Remove the "@" symbol
          final userId = await getUserIdByUsername(username);
          mentionedUserIds.add(userId);
          print("UserId: $userId");
        }
      }

      print("cleaned Text: $cleanedCommentText");
      print("Mentioned Users: $mentionedUserIds");

      // Remove duplicates from the mentionedUserIds list
      List<String> uniqueMentionedUserIds = mentionedUserIds.toSet().toList();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      final requestJson = {
        'mentionedUserIds': uniqueMentionedUserIds, // Include the mentioned user IDs in the request body
      };

      print("Stored: $storedData");

      final response = await http.post(
        Uri.parse('http://43.205.97.189:8000/api/Comment/newComment?task_id=$taskId&comment=$commentText'),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
        },
        body: uniqueMentionedUserIds,
      );

      print("API response: ${response.body}");
      print("StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        // Assuming the API response contains the data for the new comment
        final id = responseBody['data']['id'];
        final comment = responseBody['data']['comment'];
        print('New Comment ID: $id');
        print('New Comment Text: $comment');
      } else {
        print('Failed to add comment: StatusCode: ${response.statusCode}');
        throw Exception('Failed to add comment');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to add comment');
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectName = widget.projectName;
    final taskTitle = widget.taskTitle;
    final assignee = widget.assignee;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 40,left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back_ios)),
                Image.asset(
                  "assets/images/magic.png",
                  width: 30,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  taskTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              taskTitle,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor2),
            ),
            SizedBox(
              height: 30,
            ),
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
                Image.asset(
                  "assets/images/att.png",
                  width: 30,
                  height: 20,
                ),
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
                Image.asset(
                  "assets/images/pers.png",
                  width: 30,
                  height: 20,
                ),
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
              child: Text(
                assignee,
                style: TextStyle(fontSize: 15, color: AppColors.primaryColor2),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Image.asset(
                  "assets/images/complete_task.jpeg",
                  width: 30,
                  height: 20,
                ),
                SizedBox(
                  width: 10,
                ),
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
              child: Text(
                'Jane Smith',
                style: TextStyle(fontSize: 15, color: AppColors.primaryColor2),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Image.asset(
                  "assets/icons/date.png",
                  width: 30,
                  height: 20,
                ),
                SizedBox(
                  width: 10,
                ),
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
              child: Text(
                '2023-07-12 10:30 AM',
                style: TextStyle(fontSize: 15, color: AppColors.primaryColor2),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/icons/activity_select_icon.png",
                      width: 30,
                      height: 20,
                    ),
                    SizedBox(
                      width: 10,
                    ),
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
}
