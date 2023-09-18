import 'dart:convert';
import 'package:Taskapp/common_widgets/round_gradient_button.dart';
import 'package:Taskapp/view/tasks/all.dart';
import 'package:Taskapp/view/tasks/comments/comments.dart';
import 'package:Taskapp/view/tasks/history.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/comment_model.dart';
import '../../models/fetch_user_model.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

enum Activity {
  All,
  Comments,
  History,
}

class TaskDetailsScreen extends StatefulWidget {
  final Task task;
  TaskDetailsScreen({required this.task,});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen>  with SingleTickerProviderStateMixin {
  Activity _selectedActivityType = Activity.All;
  late TabController _tabController;
  TextEditingController _commentController = TextEditingController();
  List<String> suggestedUsers = [];
  List<String> mentionedUserIds = [];
  bool showSuggestions = false;
  List<Map<String, dynamic>> commentsData = [];
  bool showReplies = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
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
            'http://43.205.97.189:8000/api/UserAuth/getOrgUsers?org_id=$orgId'),
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
          final List<String> users =
          data.map((userJson) =>
          User
              .fromJson(userJson)
              .userName).toList();

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

  Widget _buildReportTypeText(Activity reportType) {
    switch (reportType) {
      case Activity.History:
        return HistoryScreen(task: widget.task);

      case Activity.Comments:
        return CommentScreen(task: widget.task);

      default:
        return AllScreen(task: widget.task);
    }
  }

  Future<String> getUserIdByUsername(String username) async {
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
            'http://43.205.97.189:8000/api/UserAuth/getOrgUsers?org_id=$orgId'),
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

  Future<List<Comment>> fetchComments(String taskId) async {
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
          'http://43.205.97.189:8000/api/Comment/getComment?task_id=$taskId'),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as List<dynamic>;
      List<Comment> commentsData = jsonData.map((commentMap) {
        List<Map<String, String>> taggedUsers = List<Map<String, String>>.from(
          (commentMap['tagged'] as List<dynamic>).map(
                (taggedUserMap) =>
            {
              'name': taggedUserMap['name'] as String,
              'user_id': taggedUserMap['user_id'] as String,
            },
          ),
        );

        List<Reply> replies = (commentMap['replies'] as List<dynamic>).map(
              (replyMap) =>
              Reply.fromJson(replyMap), // Pass the correct JSON data for reply parsing
        ).toList();

        return Comment(
          commentId: commentMap['comment_id'] as String,
          commenterName: commentMap['name'] as String,
          commentText: commentMap['comment'] as String,
          commentTime: commentMap['time'] as String,
          taggedUsers: taggedUsers,
          replies: replies,
        );
      }).toList();

      // Example of accessing the data
      for (var comment in commentsData) {
        print('Comment ID: ${comment.commentId}');
        print('Commenter Name: ${comment.commenterName}');
        print('Comment Text: ${comment.commentText}');
        print('Comment Time: ${comment.commentTime}');
        print('Tagged Users:');
        for (var taggedUser in comment.taggedUsers) {
          print('  ${taggedUser['name']} (User ID: ${taggedUser['user_id']})');
        }
        print('Replies:');
        for (var reply in comment.replies) {
          print('  Replier Name: ${reply.replierName}');
          print('  Reply Text: ${reply.replyText}');
          print('  Reply Time: ${reply.replyTime}');
        }
      }
      return commentsData;
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<String> addComment(String taskId, String commentText,List<String> mentionedUserIds) async {
    print("$taskId");
    print("$commentText");
    print("$mentionedUserIds");
    try {
      if (commentText.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("Comment Cannot be empty!"),
              actions: [
                InkWell(
                  onTap: () async {
                    Navigator.pop(context,true);
                    setState(() {
                      fetchComments(widget.task.taskId!);
                    });
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(color: AppColors.blackColor, fontSize: 20),
                  ),
                )
              ],
            );
          },
        );
        throw Exception('Comment cannot be empty');
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      print("Stored: $storedData");

      List<String> requestBody = mentionedUserIds.isNotEmpty ? mentionedUserIds : [];

      print("Request Body: $requestBody");

      final response = await http.post(
        Uri.parse(
            'http://43.205.97.189:8000/api/Comment/newComment?task_id=$taskId&comment=$commentText'),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
        },
        body: jsonEncode(requestBody),
      );

      print("API response: ${response.body}");
      print("StatusCode: ${response.statusCode}");
      print('Request Body: ${jsonEncode(requestBody)}');


      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final comment = responseBody['data']['comment'];
        print('New Comment Text: $comment');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("Comment Added Successfully!"),
              actions: [
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    Navigator.pop(context,true);
                    setState(() {
                      fetchComments(widget.task.taskId!);
                    });
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(color: AppColors.blackColor, fontSize: 20),
                  ),
                )
              ],
            );
          },
        );
        return comment;
      } else {
        print('Failed to add comment: StatusCode: ${response.statusCode}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("Failed to add Comments!"),
              actions: [
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    Navigator.pop(context,true);
                    setState(() {
                      fetchComments(widget.task.taskId!);
                    });
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(color: AppColors.blackColor, fontSize: 20),
                  ),
                )
              ],
            );
          },
        );
        throw Exception('Failed to add comment');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to add comment');
    }
  }

  Color getPriorityColor(String? priority) {
    if (priority == null) {
      return Colors.grey; // Return a default color when priority is null
    }

    switch (priority.toLowerCase()) {
      case 'high':
        return Color(
            0xFFE1B297); // Set the appropriate color for "High" priority
      case 'low':
        return Colors.green; // Set the appropriate color for "Low" priority
      case 'critical':
        return Colors.red; // Set the appropriate color for "Critical" priority
      case 'medium':
        return Colors.yellow; // Set the appropriate color for "Medium" priority
      default:
        return Colors.grey; // Default color for unknown priority values
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _openBottomSheet(context);
            },
            icon: Icon(Icons.add_circle, color: AppColors.secondaryColor2),
          ),
          Text(
            "Add comments    ",
            style: TextStyle(
                color: AppColors.secondaryColor2, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Text(
                  'All',
                  style: TextStyle(
                    color: AppColors.secondaryColor2, // Change the text color as needed
                    fontSize: 16, // Change the font size as needed
                    fontWeight: FontWeight.bold, // Change the font weight as needed
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Comments',
                  style: TextStyle(
                    color: AppColors.secondaryColor2, // Change the text color as needed
                    fontSize: 16, // Change the font size as needed
                    fontWeight: FontWeight.bold, // Change the font weight as needed
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'History',
                  style: TextStyle(
                    color: AppColors.secondaryColor2, // Change the text color as needed
                    fontSize: 16, // Change the font size as needed
                    fontWeight: FontWeight.bold, // Change the font weight as needed
                  ),
                ),
              ),
            ],
            onTap: (index) {
              setState(() {
                _selectedActivityType = Activity.values[index];
              });
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(), // Disable sliding
              children: [
                _buildReportTypeText(Activity.All),
                _buildReportTypeText(Activity.Comments),
                _buildReportTypeText(Activity.History),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 48.0), // Added padding from bottom
              margin: EdgeInsets.only(bottom: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Add Comments",style: TextStyle(
                      color: AppColors.secondaryColor2,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),),
                    SizedBox(height: 10,),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "Write your Comments",
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.secondaryColor2,
                              width: 1.2,
                            ),
                          )
                        ),
                        controller: _commentController,
                        onChanged: (text) {
                          if (text.endsWith('@')) {
                            setState(() {
                              showSuggestions = true;
                            });
                          } else {
                            setState(() {
                              showSuggestions = false;
                            });
                          }
                        },
                      ),
                    ),
                    if (showSuggestions)
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: suggestedUsers.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(suggestedUsers[index]),
                            onTap: () {
                              final currentText = _commentController.text;
                              final cursorPosition =
                                  _commentController.selection.base.offset;
                              final newText = currentText.substring(0, cursorPosition) + suggestedUsers[index] + ' ' +
                                  currentText.substring(cursorPosition);

                              setState(() {
                                _commentController.text = newText;
                                mentionedUserIds.add(suggestedUsers[index]);
                                showSuggestions = false;
                              });
                            },
                          );
                        },
                      ),
                    SizedBox(height: 20,),
                    RoundGradientButton(
                      title: "Send",
                      onPressed: () async {
                        String commentText = _commentController.text;
                        print("Comment Text: $commentText");

                        List<String> mentionedUserIdsList = []; // Create a list to store user IDs

                        for (String mentionedUser in mentionedUserIds) {
                          print("Mentioned User: @$mentionedUser");
                        }

                        String commentTextWithoutMentions = commentText;
                        for (String mentionedUser in mentionedUserIds) {
                          commentTextWithoutMentions = commentTextWithoutMentions.replaceAll('@$mentionedUser', '');
                        }
                        commentTextWithoutMentions = commentTextWithoutMentions.trim(); // Remove unnecessary spaces

                        print("Comment Text without Mentions: $commentTextWithoutMentions");

                        for (String mentionedUser in mentionedUserIds) {
                          try {
                            String userId = await getUserIdByUsername(mentionedUser);
                            mentionedUserIdsList.add(userId); // Store user ID in the list
                            print("Mentioned User: @$mentionedUser ($userId)");
                          } catch (e) {
                            print("Error getting user ID for $mentionedUser: $e");
                          }
                        }
                        print("Mentioned User IDs List: $mentionedUserIdsList");
                        await addComment(widget.task.taskId!, commentTextWithoutMentions, mentionedUserIdsList);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

String formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return 'N/A'; // Return "N/A" for null or empty date strings
  }
  try {
    final dateTime = DateTime.parse(dateString);
    final formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDate;
  } catch (e) {
    return 'Invalid Date'; // Return a placeholder for invalid date formats
  }
}
