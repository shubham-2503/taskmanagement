import 'dart:convert';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/view/tasks/editTask.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/comment_model.dart';
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
  final String taskId;
  final String? projectName;
  final String taskTitle;
  final String? assignedTo;
  final String? assignedTeam;
  final String? status;
  final String? priority;
  final String? description;
  final String? owner;
  final String? dueDate;
  final List<String>? attachments; // Add the list of attachments

  TaskDetailsScreen({
    this.projectName,
    required this.taskTitle,
    required this.assignedTo,
    this.status,
    required this.taskId,
    this.priority,
    this.assignedTeam,
    this.description,
    this.owner,
    this.dueDate,
    this.attachments, // Pass the list of attachments from the previous screen
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  Activity _selectedActivityType = Activity.All;
  TextEditingController _commentController = TextEditingController();
  TextEditingController _replyController = TextEditingController();
  TextEditingController _editCommentController = TextEditingController();
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
    // Step 2: Initialize the FocusNode
    fetchUsers();
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
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

    print("OrgId: $orgId");
    final url = Uri.parse('http://43.205.97.189:8000/api/Comment/replyComment?comment_id=$commentId&replyText=$replyText&taskId=$taskId&org_id=$orgId');

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
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Reply comment successfully sent!"),
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
    } else if (response.statusCode == 401) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Unauthorized: ${response.body}"),
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
            content: Text("Forbidden: ${response.body}"),
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
            content: Text("Error: ${response.body}"),
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
      String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

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
        Uri.parse('http://43.205.97.189:8000/api/UserAuth/getOrgUsers?org_id=$orgId'),
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
              data.map((userJson) => User.fromJson(userJson).userName).toList();

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
    String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

    if (orgId == null) {
      // If the user hasn't switched organizations, use the organization ID obtained during login time
      orgId = prefs.getString('org_id') ?? "";
    }

    print("OrgId: $orgId");


    if (orgId == null) {
      throw Exception('orgId not found locally');
    }

    print("OrgId: $orgId");
    final url = Uri.parse('http://43.205.97.189:8000/api/Comment/deleteComment?comment_id=$commentId&org_id=$orgId');

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
              content: Text(responseData['message'] ?? "Comment deleted successfully!"),
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
      } else {
        // Handle the case when the status is false and show the appropriate error message.
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(responseData['message'] ?? "Failed to delete comment!"),
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

  void _showEditDeleteModal(String commentId,String CommentText) {
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
                      _editCommentController.text = CommentText; // Set the existing comment text to the controller
                      return AlertDialog(
                        title: Text("Edit Comment"),
                        content: TextField(
                          controller: _editCommentController,
                          decoration: InputDecoration(hintText: "Edit your comment..."),
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
                        content: Text("Are you sure you want to delete this comment?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // Call the deleteComment method when the user confirms the deletion
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

  Future<List<Map<String, dynamic>>> fetchHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
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

      print("OrgId: $orgId");

      final response = await http.get(
        Uri.parse(
            'http://43.205.97.189:8000/api/History/history?taskId=${widget.taskId}'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
        },
      );

      print("TaskId: ${widget.taskId}");
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
    String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

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
      Uri.parse('http://43.205.97.189:8000/api/Comment/getComment?task_id=$taskId'),
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
                (taggedUserMap) => {
              'name': taggedUserMap['name'] as String,
              'user_id': taggedUserMap['user_id'] as String,
            },
          ),
        );

        List<Reply> replies = (commentMap['replies'] as List<dynamic>).map(
              (replyMap) => Reply(
            replierName: replyMap['name'] as String,
            replyText: replyMap['comment'] as String,
            replyTime: replyMap['time'] as String,
          ),
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
    String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

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
    // Check if the edited comment contains mentions
    final mentionPattern = RegExp(r'@\w+');
    Iterable<Match> mentionMatches = mentionPattern.allMatches(editedCommentText);
    String cleanedEditedCommentText = editedCommentText;
    if (mentionMatches.isNotEmpty) {
      // Remove mentions from the edited comment text
      cleanedEditedCommentText = editedCommentText.replaceAll(RegExp(r'@\w+'), '').trim();
      // Extract the mentioned users and add them to the mentionedUserIds list
      for (Match match in mentionMatches) {
        String mention = match.group(0)!;
        String username = mention.substring(1); // Remove the "@" symbol
        final userId = await getUserIdByUsername(username);
        if (!mentionedUserIds.contains(userId)) {
          mentionedUserIds.add(userId);
          print("UserId: $userId");
        }
      }
    }

    print("cleaned Edited Text: $cleanedEditedCommentText");
    print("Mentioned Users: $mentionedUserIds");

    final url = Uri.parse('http://43.205.97.189:8000/api/Comment/editComment?comment_id=$commentId&comment=$cleanedEditedCommentText');

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
              content: Text(responseData['message'] ?? "Comment Edited Successfully!"),
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
      } else {
        // Handle the case when the status is false and show the appropriate error message.
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(responseData['message'] ?? "Failed to edit comment!"),
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
    String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

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
                                    .primaryColor1, // Set the desired color for the userName
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
        return FutureBuilder<List<Comment>>(
          future: fetchComments(widget.taskId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
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
                                    RichText(
                                      text: TextSpan(
                                        text: "${comment.commenterName}:",
                                        style: TextStyle(
                                          color: AppColors.secondaryColor2,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          if (comment.commentText.contains("@"))
                                            ...comment.commentText.split(" ").map((textPart) {
                                              if (textPart.startsWith("@")) {
                                                // Apply the taggedUserStyle to tagged users
                                                return TextSpan(
                                                  text: "$textPart  ",
                                                  style: TextStyle(
                                                    color: AppColors.primaryColor2,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              } else {
                                                // Apply the commentTextStyle to the rest of the comment text
                                                return TextSpan(
                                                  text: textPart,
                                                  style: TextStyle(color: AppColors.blackColor),
                                                );
                                              }
                                            }).toList()
                                          else
                                            TextSpan(text: comment.commentText, style: TextStyle(color: AppColors.blackColor)),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    IconButton(onPressed: (){
                                      _showEditDeleteModal(comment.commentId,comment.commentText);
                                    }, icon: Icon(Icons.edit,color: AppColors.secondaryColor2,)),
                                    IconButton(
                                      onPressed: () {
                                        print("Icon Pressed");
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Reply"),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(16.0),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black26, // Add the color here within the BoxDecoration
                                                      borderRadius: BorderRadius.circular(10.0),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          "Replying to ${comment.commenterName}:",
                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          },
                                                          icon: Icon(Icons.close),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TextField(
                                                    controller: _replyController,
                                                    decoration: InputDecoration(hintText: "Write your reply..."),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                SizedBox(
                                                  height: 40,
                                                  width: 70,
                                                  child: RoundButton(
                                                    title: "Reply",
                                                    onPressed: () async {
                                                      String replyText = _replyController.text;
                                                      // Add the commenter's name with "@" symbol to the reply text
                                                      String replyWithMention = "${comment.commenterName} $replyText";

                                                      // Send the reply to the backend
                                                      await replyComment(comment.commentId, replyWithMention, widget.taskId, mentionedUserIds);

                                                      // Process the replyWithMention as needed (e.g., store it).
                                                      _replyController.clear(); // Clear the reply text field
                                                      Navigator.pop(context); // Close the dialog
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 40,
                                                  width: 90,
                                                  child: RoundButton(
                                                    title: "Cancel",
                                                    onPressed: () {
                                                      _replyController.clear(); // Clear the reply text field
                                                      Navigator.pop(context); // Close the dialog
                                                    },
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.reply,color: AppColors.secondaryColor2,),
                                    ),
                                  ],
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      '${DateFormat('dd MMMM, yyyy').format(DateTime.parse(comment.commentTime))}',
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
                                        onTap: (){
                                          setState(() {
                                            showReplies = !showReplies;
                                          });
                                        },
                                        child: Text("View ${comment.replies.length} comments",style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.secondaryColor2
                                        ),)),
                                  ],
                                ),
                              ),

                              // Display replies here using ListView.builder or other widgets
                              if (comment.replies.isNotEmpty && showReplies)
                                Padding(
                                  padding: const EdgeInsets.only(left: 40.0), // Add indentation for replies
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
                                        title: Text(
                                          "${reply.replierName}:",
                                          style: TextStyle(
                                            color: AppColors.secondaryColor2,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              reply.replyText,
                                              style: TextStyle(color: AppColors.blackColor, fontSize: 10),
                                            ),
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
          future: fetchActivityHistory(widget.taskId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Show a loading indicator while fetching data.
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

                          List<Map<String, dynamic>> taggedUsers = activity['tagged']!=null ? List<Map<String,dynamic>>.from(activity['tagged']): [];

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
                            displayActivityComment = displayActivityComment.replaceAll("@$taggedUserName", userMention);
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
                                      ...displayActivityComment.split(" ").map((textPart) {
                                        if (textPart.startsWith("@")) {
                                          // Apply the taggedUserStyle to tagged users
                                          return TextSpan(text: "$textPart  "  , style: TextStyle(color: AppColors.primaryColor2,fontWeight: FontWeight.bold));
                                        } else {
                                          // Apply the commentTextStyle to the rest of the comment text
                                          return TextSpan(text: textPart, style: TextStyle(color: AppColors.blackColor));
                                        }
                                      }).toList()
                                    else
                                      TextSpan(text: displayActivityComment,style: TextStyle(color: AppColors.blackColor)),
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
                ),
              );
            }
          },
        );
    }
  }


  Future<String> getUserIdByUsername(String username) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
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

      print("OrgId: $orgId");

      final response = await http.get(
        Uri.parse('http://43.205.97.189:8000/api/UserAuth/getOrgUsers?org_id=$orgId'),
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

  Future<String> addComment(String taskId, String commentText) async {
    try {
      if (commentText.isEmpty) {
        throw Exception('Comment cannot be empty');
      }

      List<Map<String, String>> mentionedUsers = [];
      final mentionPattern = RegExp(r'@\w+');
      Iterable<Match> mentionMatches = mentionPattern.allMatches(commentText);
      String cleanedCommentText = commentText;
      if (mentionMatches.isNotEmpty) {
        cleanedCommentText = commentText.replaceAll(RegExp(r'@\w+'), '').trim();
        for (Match match in mentionMatches) {
          String mention = match.group(0)!;
          String username = mention.substring(1); // Remove the "@" symbol
          final userId = await getUserIdByUsername(username);
          if (!mentionedUsers.any((user) => user['userId'] == userId)) {
            mentionedUsers.add({
              'userId': userId,
              'username': username,
            });
            print("Mentioned User: $username ($userId)");
          }
        }
      }

      print("Cleaned Text: $cleanedCommentText");
      print("Mentioned Users: $mentionedUsers");

      SharedPreferences prefs = await SharedPreferences.getInstance();
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

      print("OrgId: $orgId");
      print("Stored: $storedData");

      final response = await http.post(
        Uri.parse('http://43.205.97.189:8000/api/Comment/newComment?task_id=$taskId&comment=$cleanedCommentText&org_id=$orgId'),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
        },
        body: jsonEncode(mentionedUsers),
      );

      print("API response: ${response.body}");
      print("StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final comment = responseBody['data']['comment'];
        print('New Comment Text: $comment');
        return comment;
      } else {
        print('Failed to add comment: StatusCode: ${response.statusCode}');
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
    final projectName = widget.projectName;
    final taskTitle = widget.taskTitle;
    final assignee = widget.assignedTo;
    final status = widget.status;
    final priorityColor = getPriorityColor(widget.priority);
    final assigneeTeam = widget.assignedTeam;
    final description = widget.description;
    final dueDate = widget.dueDate;
    final owner = widget.owner;

    return Scaffold(
        body: Container(
            padding: EdgeInsets.only(top: 40, left: 20, right: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back_ios),
                  ),
                  Image.asset(
                    "assets/images/magic.png",
                    width: 30,
                  ),
                  SizedBox(width: 5),
                  RichText(
                    text: TextSpan(
                      text: "Task Title: ",
                      style: TextStyle(
                          color: AppColors.secondaryColor2,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: taskTitle,
                          style: TextStyle(
                            // Add any specific styles for the plan name here, if needed
                            color: AppColors.blackColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: priorityColor,
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditTaskPage(
                                    initialTitle: taskTitle,
                                    initialProject: "",
                                    initialAssignedTo: widget.assignedTo!,
                                    initialStatus: status!,
                                    initialDescription: description!,
                                    initialPriority: widget.priority!,
                                    taskId: widget.taskId,
                                    initialDueDate: formatDate(dueDate) ?? '',
                                    initialAssignedTeam: widget.assignedTeam!,
                                  )));
                    },
                    icon: Icon(
                      Icons.edit,
                      color: AppColors.secondaryColor2,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // print("id: ${widget.taskId}");
                      // _deleteTask(widget.taskId);
                    },
                    icon: Icon(
                      Icons.delete,
                      color: AppColors.secondaryColor2,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: "Task Description: ",
                      style: TextStyle(
                          color: AppColors.secondaryColor2,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: description,
                          style: TextStyle(
                            // Add any specific styles for the plan name here, if needed
                            color: AppColors.blackColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                  ),
                  // hasAttachments()
                  //     ?
                  // Row(
                  //   children: [
                  //     Icon(Icons.attach_file, color: AppColors.secondaryColor2),
                  //     Text("Count: ${widget.attachments!.length}"),
                  //   ],
                  // )
                  //     : SizedBox(),
                  Row(
                    children: [
                      Icon(Icons.attach_file, color: AppColors.secondaryColor2),
                      // Text("Count: "),
                    ],
                  )
                ],
              ),
              SizedBox(height: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      // Row(
                      //   children: [
                      //     Icon(
                      //       Icons.person,
                      //       color: AppColors.secondaryColor2,
                      //     ),
                      //     SizedBox(
                      //       width: 10,
                      //     ),
                      //     Text(
                      //       'AssigneeTo:',
                      //       style: TextStyle(
                      //         fontSize: 12,
                      //       ),
                      //     ),
                      //     SizedBox(
                      //       width: 10,
                      //     ),
                      //     Text(
                      //       assignee!,
                      //       style: TextStyle(
                      //           fontSize: 12, color: AppColors.primaryColor2),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(
                      //   width: 30,
                      // ),
                      Row(
                        children: [
                          Icon(
                            Icons.timelapse,
                            color: AppColors.secondaryColor2,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Status:',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            status!,
                            style: TextStyle(
                                fontSize: 12, color: AppColors.primaryColor2),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  // Row(
                  //   children: [
                  //     Row(
                  //       children: [
                  //         Icon(
                  //           Icons.person,
                  //           color: AppColors.secondaryColor2,
                  //         ),
                  //         SizedBox(
                  //           width: 10,
                  //         ),
                  //         Text(
                  //           'AssigneeTeam:',
                  //           style: TextStyle(
                  //             fontSize: 12,
                  //           ),
                  //         ),
                  //         SizedBox(
                  //           width: 10,
                  //         ),
                  //         Text(
                  //           assigneeTeam!,
                  //           style: TextStyle(
                  //               fontSize: 12, color: AppColors.primaryColor2),
                  //         ),
                  //       ],
                  //     ),
                  //     SizedBox(
                  //       width: 30,
                  //     ),
                  //     Row(
                  //       children: [
                  //         Icon(
                  //           Icons.create,
                  //           color: AppColors.secondaryColor2,
                  //         ),
                  //         SizedBox(
                  //           width: 10,
                  //         ),
                  //         Text(
                  //           'Created By:',
                  //           style: TextStyle(
                  //             fontSize: 12,
                  //           ),
                  //         ),
                  //         SizedBox(width: 10.0),
                  //         Text(
                  //           owner!,
                  //           style: TextStyle(
                  //               fontSize: 12, color: AppColors.primaryColor2),
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: AppColors.secondaryColor2,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'DueDate:',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        formatDate(dueDate) ?? '',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.primaryColor2),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
               SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  TypeAheadFormField<String>(
                                    textFieldConfiguration: TextFieldConfiguration(
                                      controller: _commentController,
                                      onChanged: (text) {
                                        if (text.endsWith("@") && text.length > 1) {
                                          fetchUsers();
                                          setState(() {
                                            showSuggestions = true;
                                          });
                                        } else {
                                          setState(() {
                                            showSuggestions = false;
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Write your comment...",
                                      ),
                                    ),
                                    suggestionsCallback: (pattern) async {
                                      final atIndex = pattern.indexOf("@");
                                      if (atIndex != -1 && atIndex + 1 < pattern.length) {
                                        final searchQuery =
                                        pattern.substring(atIndex + 1).toLowerCase();
                                        final filteredUsers = suggestedUsers
                                            .where((user) =>
                                            user.toLowerCase().contains(searchQuery))
                                            .toList();
                                        return filteredUsers;
                                      } else {
                                        return suggestedUsers;
                                      }
                                    },
                                    itemBuilder: (context, suggestion) {
                                      return ListTile(
                                        leading: CircleAvatar(
                                          child: Text(suggestion.substring(0, 1)),
                                        ),
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
                                          currentText.substring(0, lastAtSymbolIndex) +
                                              "@$suggestion ";

                                      // Clear the input field
                                      _commentController.clear();
                                      _commentController.text = newText;
                                    },
                                  ),
                                  Visibility(
                                    visible: showSuggestions,
                                    child: Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      child: Card(
                                        elevation: 4.0,
                                        child: SizedBox(
                                          height: 200,
                                          child: ListView.builder(
                                            itemCount: suggestedUsers.length,
                                            itemBuilder: (context, index) {
                                              final suggestion = suggestedUsers[index];
                                              return ListTile(
                                                leading: CircleAvatar(
                                                  child: Text(suggestion.substring(0, 1)),
                                                ),
                                                title: Text(suggestion),
                                                onTap: () async {
                                                  // Append the selected suggestion to the comment box
                                                  // Fetch the userId corresponding to the mentioned username
                                                  final userId =
                                                  await getUserIdByUsername(suggestion);
                                                  // Add the userId to the mentionedUserIds list
                                                  setState(() {
                                                    mentionedUserIds.add(userId);
                                                  });

                                                  // Append the selected suggestion to the comment box
                                                  final currentText =
                                                      _commentController.text;
                                                  final lastAtSymbolIndex =
                                                  currentText.lastIndexOf("@");
                                                  final newText =
                                                      currentText.substring(0, lastAtSymbolIndex) +
                                                          "@$suggestion ";

                                                  // Clear the input field
                                                  _commentController.clear();
                                                  _commentController.text = newText;
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10.0),
                            GestureDetector(
                              onTap: () async {
                                // Implement the send comments logic here
                                await addComment(
                                  widget.taskId,
                                  _commentController.text!,
                                );

                                // Fetch the comments again to refresh the list
                                await fetchComments(widget.taskId);

                                // Optionally, you can use setState to trigger a UI refresh if needed
                                setState((){
                                  // After successfully adding the comment, clear the input field
                                  _commentController.clear();
                                });

                                // Now, navigate back to the previous screen (assuming the comments section is on the previous screen)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Comment added successfully'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor1,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Send',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
            ])));
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
