import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../models/comment_model.dart';
import '../../../models/task_model.dart';
import '../../../utils/app_colors.dart';

class EditDeleteComments extends StatefulWidget {
  final Task task;
  final Comment comment;
  const EditDeleteComments({super.key, required this.comment, required this.task});

  @override
  State<EditDeleteComments> createState() => _EditDeleteCommentsState();
}

class _EditDeleteCommentsState extends State<EditDeleteComments> {
  List<String> suggestedUsers = [];
  List<String> mentionedUserIds = [];
  bool showSuggestions = false;
  TextEditingController _editCommentController = TextEditingController();

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
                    fetchComments(widget.task.taskId!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                _editCommentController.text = widget.comment.commentText; // Set the existing comment text to the controller
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Edit Comment"),
                      content: Column(
                        children: [
                          Wrap(
                            spacing: 4,
                            children: widget.comment.taggedUsers.toList().asMap().entries.map((entry) {
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
                                          List<Map<String, String>> updatedTaggedUsers = List.from(widget.comment.taggedUsers);
                                          updatedTaggedUsers.removeAt(index);

                                          // Create a new instance of Reply with updated taggedUsers
                                          Reply updatedReply = Reply(
                                            replyId: widget.comment.commentId,
                                            replierName: widget.comment.commenterName,
                                            replyText: widget.comment.commentText,
                                            replyTime: widget.comment.commentTime,
                                            taggedUsers: updatedTaggedUsers,
                                            replyOfReply: widget.comment.replies,
                                          );

                                          // Set the updated reply instance to the reply variable
                                          // widget.reply = updatedReply;
                                          print("Reply: ${widget.comment.taggedUsers}");
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
                            controller: _editCommentController,
                            decoration: InputDecoration(
                              hintText: "Edit your comment...",
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            String editedCommentText = _editCommentController.text;
                            List<String> editedTaggedUsers = _getTaggedUserNames(_editCommentController.text);
                            editComment(widget.comment.commentId, editedCommentText);
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
              child: Text("Edit Comment"),
            ),
          ],
        ),
      ),
    );
  }
}
