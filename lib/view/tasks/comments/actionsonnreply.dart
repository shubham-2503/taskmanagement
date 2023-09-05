import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../models/comment_model.dart';
import '../../../utils/app_colors.dart';

class ActionsOnReply extends StatefulWidget {
  final Reply reply;
  const ActionsOnReply({super.key, required this.reply});

  @override
  State<ActionsOnReply> createState() => _ActionsOnReplyState();
}

class _ActionsOnReplyState extends State<ActionsOnReply> {
  List<String> suggestedUsers = [];
  List<String> mentionedUserIds = [];
  bool showSuggestions = false;
  TextEditingController _editreplyCommentController = TextEditingController();

  Future<void> editComment(String replyId, String editedreplyText) async {
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
        'http://43.205.97.189:8000/api/Comment/editComment?comment_id=$replyId&comment=$editedreplyText');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                    _editreplyCommentController.text = widget.reply.replyText; // Set the existing comment text to the controller
                    return AlertDialog(
                      title: Text("Edit Comment"),
                      content: Column(
                        children: [
                          Wrap(
                            spacing: 4,
                            children: widget.reply.taggedUsers.toList().asMap().entries.map((entry) {
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
                                          List<Map<String, String>> updatedTaggedUsers = List.from(widget.reply.taggedUsers);
                                          updatedTaggedUsers.removeAt(index);

                                          // Create a new instance of Reply with updated taggedUsers
                                          Reply updatedReply = Reply(
                                            replyId: widget.reply.replyId,
                                            replierName: widget.reply.replierName,
                                            replyText: widget.reply.replyText,
                                            replyTime: widget.reply.replyTime,
                                            taggedUsers: updatedTaggedUsers,
                                            replyOfReply: widget.reply.replyOfReply,
                                          );

                                          // Set the updated reply instance to the reply variable
                                          // widget.reply = updatedReply;
                                          print("Reply: ${widget.reply.taggedUsers}");
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
                            editComment(widget.reply.replyId, editedCommentText,);
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
                            deleteComment(widget.reply.replyId);
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
      ));
  }
}
