import 'dart:convert';
import 'package:Taskapp/common_widgets/round_gradient_button.dart';
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
  final Task task; // Add the list of attachments

  TaskDetailsScreen({
    required this.task,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen>  with SingleTickerProviderStateMixin {
  Activity _selectedActivityType = Activity.All;
  late TabController _tabController;
  TextEditingController _commentController = TextEditingController();
  TextEditingController _replyController = TextEditingController();
  TextEditingController _editCommentController = TextEditingController();
  TextEditingController _editreplyCommentController = TextEditingController();
  List<String> suggestedUsers = [];
  List<String> mentionedUserIds = [];
  bool showSuggestions = false;
  List<String> historyLog = [];
  List<Map<String, dynamic>> commentsData = [];
  bool showReplies = false;
  List<Map<String, dynamic>> activityHistoryData = [];
  List<Map<String, dynamic>> historyData = [];
  List<Map<String, dynamic>> commentData = [];

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
    _replyController.dispose();
    super.dispose();
  }

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

  Future<void> replyComment(String commentId, String replyText, String taskId, List<String> mentionedUserIds,) async {
    print("Commentid: $commentId");
    print("ReplyText: $replyText");
    print("TaskId: $taskId");
    print("MentionedUsers: $mentionedUserIds");
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
    final url = Uri.parse(
        'http://43.205.97.189:8000/api/Comment/replyComment?comment_id=$commentId&replyText=$replyText&taskId=$taskId&org_id=$orgId');

    final headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $storedData',
    };

    final queryParams = {
      'comment_id': commentId,
      'comment': replyText,
      'task_id': taskId,
    };

    final requestBody = jsonEncode(mentionedUserIds);

    final response = await http.post(
      url.replace(queryParameters: queryParams),
      headers: headers,
      body: requestBody,
    );
    print("Response: ${response.body}");
    print("StatusCodee: ${response.statusCode}");

    if (response.statusCode == 200) {
      print('Reply comment successfully sent!');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Reply comment successfully sent!"),
            actions: [
              InkWell(
                onTap: () {
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
    } else if (response.statusCode == 401) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Failed to reply on comments...session ends"),
            actions: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
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
      // Handle unauthorized error
      print('Unauthorized: ${response.body}');
    } else if (response.statusCode == 403) {
      // Handle forbidden error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("FAiled to reply on Comments"),
            actions: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
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
      print('Forbidden: ${response.body}');
    } else {
      // Handle other error cases
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("OOPs"),
            content: Text("Failed to reply on Comments.Please try again"),
            actions: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
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
      print('Error: ${response.body}');
    }
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

  Future<void> deleteComment(String commentId) async {
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
    final url = Uri.parse(
        'http://43.205.97.189:8000/api/Comment/deleteComment?comment_id=$commentId&org_id=$orgId');

    final headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $storedData',
    };

    final response = await http.delete(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == true) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                  responseData['message'] ?? "Comment deleted successfully!"),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      fetchComments(widget.task.taskId!);
                    });
                    Navigator.pop(context);
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
      } else {
        // Handle the case when the status is false and show the appropriate error message.
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                  responseData['message'] ?? "Failed to delete comment!"),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
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
      }
    } else if (response.statusCode == 401) {
      // Handle unauthorized error
      print('Unauthorized: ${response.body}');
    } else if (response.statusCode == 403) {
      // Handle forbidden error
      print('Forbidden: ${response.body}');
    } else {
      // Handle other error cases
      print('Error: ${response.body}');
    }
  }

  void _showEditDeleteModal(String commentId, String CommentText,String Commenter) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      _editCommentController.text =
                          CommentText; // Set the existing comment text to the controller
                      return AlertDialog(
                        title: Text("Edit Comment"),
                        content: TextField(
                          controller: _editCommentController,
                          decoration: InputDecoration(
                              hintText: "Edit your comment..."),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // Call the editComment method when the user confirms the edit
                              String editedCommentText = _editCommentController.text;
                              editComment(commentId, editedCommentText);
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text("Save"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text("Cancel"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Delete Comment"),
                        content: Text(
                            "Are you sure you want to delete this comment?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              deleteComment(commentId);
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text("Yes"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text("No"),
                          ),
                        ],
                      );
                    },
                  ); // Close the bottom sheet
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showreplyModal(Reply reply) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      _editreplyCommentController.text = reply.replyText; // Set the existing comment text to the controller
                      return AlertDialog(
                        title: Text("Edit Comment"),
                        content: Column(
                          children: [
                            Wrap(
                              spacing: 4,
                              children: reply.taggedUsers.toList().asMap().entries.map((entry) {
                                int index = entry.key;
                                Map<String, String> taggedUser = entry.value;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(taggedUser['name']!),
                                      SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            List<Map<String, String>> updatedTaggedUsers = List.from(reply.taggedUsers);
                                            updatedTaggedUsers.removeAt(index);

                                            // Create a new instance of Reply with updated taggedUsers
                                            Reply updatedReply = Reply(
                                              replyId: reply.replyId,
                                              replierName: reply.replierName,
                                              replyText: reply.replyText,
                                              replyTime: reply.replyTime,
                                              taggedUsers: updatedTaggedUsers,
                                              replyOfReply: reply.replyOfReply,
                                            );

                                            // Set the updated reply instance to the reply variable
                                            reply = updatedReply;
                                            print("Reply: ${reply.taggedUsers}");
                                          });
                                        },
                                        child: Icon(Icons.close, size: 16),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            TextField(
                              controller: _editreplyCommentController,
                              decoration: InputDecoration(
                                  hintText: "Edit your comment..."),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              String editedCommentText = _editreplyCommentController.text;
                              List<String> editedTaggedUsers = _getTaggedUserNames(_editreplyCommentController.text);
                              editComment(reply.replyId, editedCommentText,);
                              Navigator.pop(context);
                            },
                            child: Text("Save"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text("Cancel"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Delete Comment"),
                        content: Text(
                            "Are you sure you want to delete this comment?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              deleteComment(reply.replyId);
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text("Yes"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text("No"),
                          ),
                        ],
                      );
                    },
                  ); // Close the bottom sheet
                },
              ),
            ],
          ),
        );
      },
    );
  }

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

  Future<void> editComment(String commentId, String editedCommentText) async {
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

    final requestJson = mentionedUserIds.isEmpty ? [] : mentionedUserIds;
    print("Mentioned Users: $mentionedUserIds");

    final url = Uri.parse(
        'http://43.205.97.189:8000/api/Comment/editComment?comment_id=$commentId&comment=$editedCommentText');

    final headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $storedData',
    };


    final response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode(requestJson),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == true) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                  responseData['message'] ?? "Comment Edited Successfully!"),
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
      } else {
        // Handle the case when the status is false and show the appropriate error message.
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                  responseData['message'] ?? "Failed to edit comment!"),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
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
      }
    } else if (response.statusCode == 401) {
      // Handle unauthorized error
      print('Unauthorized: ${response.body}');
    } else if (response.statusCode == 403) {
      // Handle forbidden error
      print('Forbidden: ${response.body}');
    } else {
      // Handle other error cases
      print('Error: ${response.body}');
    }
  }

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

  Widget _buildReportTypeText(Activity reportType) {
    switch (reportType) {
      case Activity.History:
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingText(); // Show a loading indicator while fetching data.
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
                          color: AppColors.primaryColor1,
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
                                color: AppColors
                                    .primaryColor1,
                                // Set the desired color for the userName
                                fontWeight: FontWeight
                                    .bold, // You can customize other styles as well
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
                              title: Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text: "$userName:",
                                    style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                        text: "$action",
                                        style: TextStyle(
                                          // Add any specific styles for the plan name here, if needed
                                          color: AppColors.blackColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              subtitle: Text(
                                '${DateFormat('dd MMMM, yyyy hh:mm a').format(
                                    DateTime.parse(historyItem['time']))}',
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
        return FutureBuilder<List<Comment>>(
          future: fetchComments(widget.task.taskId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingText();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<Comment> commentsData = snapshot.data ?? [];
              if (commentsData.isEmpty) {
                return Text('No comments available.');
              }

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
                    SizedBox(height: 2),
                    Expanded(
                      child: ListView.builder(
                        itemCount: commentsData.length,
                        itemBuilder: (context, index) {
                          Comment comment = commentsData[index];
                          List<InlineSpan> commentTextSpans = [];
                          if (comment.taggedUsers.isNotEmpty) {
                            var taggedUserNames = comment.taggedUsers.map((user) => user['name']).join(', ');
                            commentTextSpans.add(
                              TextSpan(
                                text: taggedUserNames,
                                style: TextStyle(
                                  color: AppColors.primaryColor2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                            commentTextSpans.add(TextSpan(text: " "));
                          }
                          final commentTextParts = comment.commentText.split(" ");
                          for (var textPart in commentTextParts) {
                            if (!textPart.startsWith("@")) {
                              commentTextSpans.add(
                                TextSpan(
                                  text: textPart,
                                  style: TextStyle(color: AppColors.blackColor),
                                ),
                              );
                            }
                            commentTextSpans.add(TextSpan(text: " "));
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    comment.commenterName[0],
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: AppColors.primaryColor1,
                                ),
                                title: Row(
                                  children: [
                                    Container(
                                      width: 190,
                                      child: RichText(
                                        text: TextSpan(
                                          text: "${comment.commenterName}:",
                                          style: TextStyle(
                                            color: AppColors.secondaryColor2,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                            children: [
                                              ...comment.taggedUsers.map((taggedUser) {
                                                return TextSpan(
                                                  text: "@${taggedUser['name']},",
                                                  style: TextStyle(
                                                    color: AppColors.primaryColor2,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              }).toList(),
                                              TextSpan(
                                                text: comment.commentText,
                                                style: TextStyle(
                                                  color: AppColors.blackColor,
                                                ),
                                              ),
                                            ]
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    IconButton(onPressed: () {
                                      _showEditDeleteModal(comment.commentId,
                                          comment.commentText,comment.commenterName);
                                    }, icon: Icon(Icons.more_vert,
                                          color: AppColors.secondaryColor2,)),
                                    IconButton(
                                      onPressed: () {
                                        print("Icon Pressed");
                                        _replyBottomSheet(context,comment);
                                      },
                                      icon: Icon(Icons.reply,
                                        color: AppColors.secondaryColor2,),
                                    ),
                                  ],
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      '${DateFormat('dd MMMM, yyyy').format(
                                          DateTime.parse(
                                              comment.commentTime))}',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 12,
                                      ),
                                    ),
                                    // IconButton(
                                    //   onPressed: () {
                                    //     setState(() {
                                    //       showReplies = !showReplies;
                                    //     });
                                    //   },
                                    //   icon: Icon(Icons.remove_red_eye_sharp),
                                    // ),
                                    SizedBox(width: 10,),
                                    InkWell(
                                        onTap: () {
                                          setState(() {
                                            showReplies = !showReplies;
                                          });
                                        },
                                        child: Text("View ${comment.replies
                                            .length} comments",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.secondaryColor2
                                          ),)),
                                  ],
                                ),
                              ),

                              // // Display replies here using ListView.builder or other widgets
                              // if (comment.replies.isNotEmpty && showReplies)
                              //   Padding(
                              //     padding: const EdgeInsets.only(left: 40.0),
                              //     // Add indentation for replies
                              //     child: Column(
                              //       crossAxisAlignment: CrossAxisAlignment
                              //           .start,
                              //       children: comment.replies.map((reply) {
                              //         return ListTile(
                              //           leading: CircleAvatar(
                              //             child: Text(
                              //               reply.replierName[0],
                              //               style: TextStyle(
                              //                 color: Colors.white,
                              //               ),
                              //             ),
                              //             backgroundColor: AppColors
                              //                 .primaryColor1,
                              //           ),
                              //           title: Row(
                              //             children: [
                              //               RichText(
                              //                 text: TextSpan(
                              //                   children: [
                              //                     TextSpan(
                              //                       text: "${reply.replierName}: ",
                              //                       style: TextStyle(
                              //                         color: AppColors.secondaryColor2,
                              //                         fontSize: 12,
                              //                         fontWeight: FontWeight.bold,
                              //                       ),
                              //                     ),
                              //                     TextSpan(
                              //                       text: reply.replyText,
                              //                       style: TextStyle(
                              //                         color: AppColors.blackColor,
                              //                         fontSize: 10,
                              //                         fontWeight: FontWeight.bold,
                              //                       ),
                              //                     ),
                              //                   ],
                              //                 ),
                              //               ),
                              //               Spacer(),
                              //               IconButton(onPressed: () {
                              //                 _showreplyModal(reply);
                              //               }, icon: Icon(Icons.more_vert,
                              //                 color: AppColors.secondaryColor2,)),
                              //               IconButton(
                              //                 onPressed: () {
                              //                   print("Icon Pressed");
                              //                   _replyBottomSheet(context,comment);
                              //                 },
                              //                 icon: Icon(Icons.reply,
                              //                   color: AppColors.secondaryColor2,),
                              //               ),
                              //             ],
                              //           ),
                              //           subtitle: Column(
                              //             crossAxisAlignment: CrossAxisAlignment
                              //                 .start,
                              //             children: [
                              //               Row(
                              //                 children: [
                              //                   Text(
                              //                     '${DateFormat(
                              //                         'dd MMMM, yyyy hh:mm a')
                              //                         .format(DateTime.parse(
                              //                         reply.replyTime))}',
                              //                     style: TextStyle(
                              //                       fontStyle: FontStyle.italic,
                              //                       fontSize: 8,
                              //                     ),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ],
                              //           ),
                              //         );
                              //       }).toList(),
                              //     ),
                              //   ),
                              if (comment.replies.isNotEmpty && showReplies)
                                Padding(
                                  padding: const EdgeInsets.only(left: 40.0),
                                  // Add indentation for replies
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: comment.replies.map((reply) {
                                      return ListTile(
                                        leading: CircleAvatar(
                                          child: Text(
                                            reply.replierName[0],
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: AppColors.primaryColor1,
                                        ),
                                        title: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 150,
                                                  child: RichText(
                                                    text: TextSpan(
                                                        text: "${reply.replierName}:",
                                                        style: TextStyle(
                                                          color: AppColors.secondaryColor2,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        children: [
                                                          ...reply.taggedUsers.map((taggedUser) {
                                                            return TextSpan(
                                                              text: "@${taggedUser['name']},",
                                                              style: TextStyle(
                                                                color: AppColors.primaryColor2,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            );
                                                          }).toList(),
                                                          TextSpan(
                                                            text: reply.replyText,
                                                            style: TextStyle(
                                                              color: AppColors.blackColor,
                                                            ),
                                                          ),
                                                        ]
                                                    ),
                                                  ),
                                                ),
                                                // RichText(
                                                //   text: TextSpan(
                                                //     children: [
                                                //       TextSpan(
                                                //         text: "${reply.replierName}: ",
                                                //         style: TextStyle(
                                                //           color: AppColors.secondaryColor2,
                                                //           fontSize: 12,
                                                //           fontWeight: FontWeight.bold,
                                                //         ),
                                                //       ),
                                                //       TextSpan(
                                                //         text: reply.replyText,
                                                //         style: TextStyle(
                                                //           color: AppColors.blackColor,
                                                //           fontSize: 10,
                                                //           fontWeight: FontWeight.bold,
                                                //         ),
                                                //       ),
                                                //     ],
                                                //   ),
                                                // ),
                                                Spacer(),
                                                IconButton(
                                                  onPressed: () {
                                                    _showreplyModal(reply);
                                                  },
                                                  icon: Icon(
                                                    Icons.more_vert,
                                                    color: AppColors.secondaryColor2,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    print("Icon Pressed");
                                                    _replyBottomSheet(context, comment);
                                                  },
                                                  icon: Icon(
                                                    Icons.reply,
                                                    color: AppColors.secondaryColor2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  '${DateFormat('dd MMMM, yyyy hh:mm a').format(DateTime.parse(reply.replyTime))}',
                                                  style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 8,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        );

      default:
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchActivityHistory(widget.task.taskId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingText();// Show a loading indicator while fetching data.
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              activityHistoryData = snapshot.data ?? [];
              return Flexible(
                fit: FlexFit.loose,
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
                        itemCount: activityHistoryData.length,
                        itemBuilder: (context, index) {
                          final activity = activityHistoryData[index];
                          final activityType = activity['type'] as String;
                          final activityComment = activity['comment'] as String;
                          final activityTime = activity['time'] as String;
                          final activityUserName = activity['name'] as String;

                          List<Map<String,
                              dynamic>> taggedUsers = activity['tagged'] != null
                              ? List<Map<String, dynamic>>.from(
                              activity['tagged'])
                              : [];

                          String taggedUserString = taggedUsers
                              .map((taggedUser) => "@${taggedUser['name']}")
                              .toList()
                              .join(', ');

                          // Replace tagged usernames with user mentions in the activity comment
                          String displayActivityComment = "$taggedUserString $activityComment";
                          print(displayActivityComment);
                          for (Map<String, dynamic> taggedUser in taggedUsers) {
                            final taggedUserName = taggedUser['name'] as String;
                            final userMention = "@$taggedUserName";
                            displayActivityComment = displayActivityComment
                                .replaceAll("@$taggedUserName", userMention);
                          }

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
                                      fontWeight: FontWeight.bold),
                                  children: [
                                    if (displayActivityComment.contains("@"))
                                      ...displayActivityComment.split(" ").map((
                                          textPart) {
                                        if (textPart.startsWith("@")) {
                                          // Apply the taggedUserStyle to tagged users
                                          return TextSpan(text: "$textPart  ",
                                              style: TextStyle(color: AppColors
                                                  .primaryColor2,
                                                  fontWeight: FontWeight.bold));
                                        } else {
                                          // Apply the commentTextStyle to the rest of the comment text
                                          return TextSpan(text: textPart,
                                              style: TextStyle(
                                                  color: AppColors.blackColor));
                                        }
                                      }).toList()
                                    else
                                      TextSpan(text: displayActivityComment,
                                          style: TextStyle(
                                              color: AppColors.blackColor)),
                                  ],
                                ),
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  '${DateFormat('dd MMMM, yyyy hh:mm a').format(
                                      DateTime.parse(activityTime))}',
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
                ),
              );
            }
          },
        );
    }
  }

  void _replyBottomSheet(BuildContext context,Comment comment){
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
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Reply to ${comment.commenterName}",style: TextStyle(
                            color: AppColors.secondaryColor2,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),),
                          IconButton(onPressed: (){
                            Navigator.pop(context);
                          }, icon: Icon(Icons.close)),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                            hintText: "Reply to ${comment.commenterName}",
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
                        controller:_replyController,
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
                              final currentText = _replyController.text;
                              final cursorPosition =
                                  _replyController.selection.base.offset;
                              final newText = currentText.substring(0, cursorPosition) + suggestedUsers[index] + ' ' +
                                  currentText.substring(cursorPosition);

                              setState(() {
                                _replyController.text = newText;
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
                        String replyText = _replyController.text;
                        print("Reply Text: $replyText");

                        List<String> mentionedUserIdsList = []; // Create a list to store user IDs

                        for (String mentionedUser in mentionedUserIds) {
                          print("Mentioned User: @$mentionedUser");
                        }

                        String replyTextWithoutMentions = replyText;
                        for (String mentionedUser in mentionedUserIds) {
                          replyTextWithoutMentions = replyTextWithoutMentions.replaceAll('@$mentionedUser', '');
                        }
                        replyTextWithoutMentions = replyTextWithoutMentions.trim(); // Remove unnecessary spaces

                        print("Reply Text without Mentions: $replyTextWithoutMentions");

                        for (String mentionedUser in mentionedUserIds) {
                          try {
                            String userId = await getUserIdByUsername(mentionedUser);
                            if (!mentionedUserIdsList.contains(userId)) {
                              mentionedUserIdsList.add(userId); // Store user ID in the list if not already present
                            }
                            print("Mentioned User: [$userId]");
                          } catch (e) {
                            print("Error getting user ID for $mentionedUser: $e");
                          }
                        }
                        print("Mentioned User IDs List: $mentionedUserIdsList");
                        await replyComment(comment.commentId, replyTextWithoutMentions, widget.task.taskId!, mentionedUserIdsList);
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

  Widget _buildLoadingText() {
    return Text('Loading data...');
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
            "Add comments",
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

  // void _openreplySheet(BuildContext context,String commenter) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return Container(
  //             padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 48.0), // Added padding from bottom
  //             margin: EdgeInsets.only(bottom: 20.0),
  //             child: SingleChildScrollView(
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Container(
  //                     width: 250,
  //                     height: 70,
  //                     padding: EdgeInsets.all(
  //                         16.0),
  //                     decoration: BoxDecoration(
  //                       color:AppColors.primaryColor1,
  //                       // Add the color here within the BoxDecoration
  //                       borderRadius: BorderRadius
  //                           .circular(10.0),
  //                     ),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Text(
  //                           "Replying to ${commenter}:",
  //                           style: TextStyle(
  //                               fontWeight: FontWeight
  //                                   .bold),
  //                         ),
  //                         SizedBox(width: 4,),
  //                         IconButton(
  //                           onPressed: () {
  //                             Navigator.pop(
  //                                 context);
  //                           },
  //                           icon: Icon(
  //                               Icons.close),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   SizedBox(height: 10,),
  //                   Container(
  //                     width: MediaQuery.of(context).size.width * 0.8,
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(15),
  //                       border: BoxBorder
  //                     ),
  //                     child: TextFormField(
  //                       decoration: InputDecoration(
  //                         contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
  //                         hintText: "Reply to $commenter",
  //                         enabledBorder: InputBorder.none,
  //                         focusedBorder: InputBorder.none,
  //                       ),
  //                       controller: _replyController,
  //                       onChanged: (text) {
  //                         if (text.endsWith('@')) {
  //                           setState(() {
  //                             showSuggestions = true;
  //                           });
  //                         } else {
  //                           setState(() {
  //                             showSuggestions = false;
  //                           });
  //                         }
  //                       },
  //                     ),
  //                   ),
  //                   if (showSuggestions)
  //                     ListView.builder(
  //                       shrinkWrap: true,
  //                       itemCount: suggestedUsers.length,
  //                       itemBuilder: (context, index) {
  //                         return ListTile(
  //                           title: Text(suggestedUsers[index]),
  //                           onTap: () {
  //                             final currentText = _replyController.text;
  //                             final cursorPosition =
  //                                 _replyController.selection.base.offset;
  //                             final newText = currentText.substring(0, cursorPosition) + suggestedUsers[index] + ' ' +
  //                                 currentText.substring(cursorPosition);
  //
  //                             setState(() {
  //                               _replyController.text = newText;
  //                               mentionedUserIds.add(suggestedUsers[index]);
  //                               showSuggestions = false;
  //                             });
  //                           },
  //                         );
  //                       },
  //                     ),
  //                   SizedBox(height: 20,),
  //                   RoundGradientButton(
  //                     title: "Send",
  //                     onPressed: () async {
  //                       String commentText = _replyController.text;
  //                       print("Comment Text: $commentText");
  //
  //                       List<String> mentionedUserIdsList = []; // Create a list to store user IDs
  //
  //                       for (String mentionedUser in mentionedUserIds) {
  //                         print("Mentioned User: @$mentionedUser");
  //                       }
  //
  //                       String commentTextWithoutMentions = commentText;
  //                       for (String mentionedUser in mentionedUserIds) {
  //                         commentTextWithoutMentions = commentTextWithoutMentions.replaceAll('@$mentionedUser', '');
  //                       }
  //                       commentTextWithoutMentions = commentTextWithoutMentions.trim(); // Remove unnecessary spaces
  //
  //                       print("Comment Text without Mentions: $commentTextWithoutMentions");
  //
  //                       for (String mentionedUser in mentionedUserIds) {
  //                         try {
  //                           String userId = await getUserIdByUsername(mentionedUser);
  //                           mentionedUserIdsList.add(userId); // Store user ID in the list
  //                           print("Mentioned User: @$mentionedUser ($userId)");
  //                         } catch (e) {
  //                           print("Error getting user ID for $mentionedUser: $e");
  //                         }
  //                       }
  //
  //                       print("Mentioned User IDs List: $mentionedUserIdsList");
  //
  //                       await addComment(widget.task.taskId!, commentTextWithoutMentions, mentionedUserIdsList);
  //                     },
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
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

  List<String> _getTaggedUserNames(String text) {
    List<String> taggedUserNames = [];
    RegExp exp = RegExp(r"@(\w+)");
    Iterable<RegExpMatch> matches = exp.allMatches(text);
    // Extract tagged user names and add them to the list
    for (RegExpMatch match in matches) {
      taggedUserNames.add(match.group(1)!);
    }

    return taggedUserNames;
  }
}

String formatDate(String? dateString) {
  print('Raw Date String: $dateString');
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
