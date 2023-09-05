import 'dart:convert';
import 'package:Taskapp/common_widgets/round_gradient_button.dart';
import 'package:Taskapp/view/tasks/comments/edit_delete_comments.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/comment_model.dart';
import '../../../models/fetch_user_model.dart';
import '../../../models/task_model.dart';
import '../../../utils/app_colors.dart';

class CommentScreen extends StatefulWidget {
  final Task task;
  const CommentScreen({super.key, required this.task});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  bool showReplies = false;
  TextEditingController _replyController = TextEditingController();
  List<String> suggestedUsers = [];
  List<String> mentionedUserIds = [];
  bool showSuggestions = false;

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
          User.fromJson(userJson)
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

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FutureBuilder<List<Comment>>(
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

              return ListView.separated(
                itemCount: commentsData.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  return _buildCommentTile(commentsData[index]);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildCommentTile(Comment comment) {
    final taggedUserNames = comment.taggedUsers.map((user) => "@${user['name']}").join(', ');

    final commentTextParts = comment.commentText.split(" ");
    final textSpans = <InlineSpan>[];

    if (taggedUserNames.isNotEmpty) {
      textSpans.add(
        TextSpan(
          text: taggedUserNames,
          style: TextStyle(
            color: AppColors.primaryColor2,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      textSpans.add(const TextSpan(text: " "));
    }

    textSpans.addAll(commentTextParts.map((textPart) {
      if (!textPart.startsWith("@")) {
        return TextSpan(
          text: textPart,
          style: TextStyle(color: AppColors.blackColor),
        );
      }
      return TextSpan(
        text: textPart + " ",
        style: TextStyle(color: AppColors.primaryColor2, fontWeight: FontWeight.bold),
      );
    }));

    return ListTile(
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
                text: "${comment.commenterName}: ",
                style: TextStyle(
                  color: AppColors.secondaryColor2,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                children: textSpans,
              ),
            ),
          ),
          Spacer(),
          _buildIconButton(Icons.more_vert, () async {
            bool edited = await showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return EditDeleteComments(comment: comment, task: widget.task,);
              },
            );
            if(edited == true){
              await fetchComments(widget.task.taskId!);
            }
          }),
          _buildIconButton(Icons.reply, () {
            _replyBottomSheet(context, comment);
          }),
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
          SizedBox(width: 10),
          InkWell(
            onTap: () {
              setState(() {
                showReplies = !showReplies;
              });
            },
            child: Text(
              "View ${comment.replies.length} comments",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryColor2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: AppColors.secondaryColor2,
      ),
    );
  }
}
