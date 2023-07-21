import 'dart:convert';
import 'package:Taskapp/view/tasks/taskDetails.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../common_widgets/round_button.dart';
import '../../common_widgets/round_textfield.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';

class MyTaskScreen extends StatefulWidget {
  const MyTaskScreen({super.key});

  @override
  State<MyTaskScreen> createState() => _MyTaskScreenState();
}

class _MyTaskScreenState extends State<MyTaskScreen> {
  TextEditingController _mentionController = TextEditingController();
  List<Task> filteredMyTasks = [];
  List<Task> mytasks = [];

  Future<void> fetchMyTasks() async {
    try {
      final url = 'http://43.205.97.189:8000/api/Task/myTasks';

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      print("StatusCode: ${response.statusCode}");
      print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final List<Task> fetchedTasks = responseData.map((taskData) {
          return Task(
            taskName: taskData['task_name'] ?? '', // Changed to 'task_name'
            assignedTo: taskData['assignee'] ?? '', // Changed to 'assignee'
            status: taskData['status'] ?? '',
            description: taskData['description'] ?? '',
            priority: taskData['priority'] ?? '',
            dueDate: taskData['dueDate'], // 'dueDate' remains the same
          );
        }).toList();
        setState(() {
          mytasks = fetchedTasks;
          filteredMyTasks = fetchedTasks;
        });
      } else {
        print('Error fetching tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchMyTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Column(
            children: [
              Text(
                'My Tasks',
                style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredMyTasks.length,
                  itemBuilder: (BuildContext context, int index) {
                    Task task = filteredMyTasks[index];
                    // Determine color based on the task's status
                    Color statusColor = Colors.grey; // Default color
                    switch (task.status) {
                      case 'InProgress':
                        statusColor = Colors.blue;
                        break;
                      case 'Completed':
                        statusColor = Colors.red;
                        break;
                      case 'ToDo':
                        statusColor = AppColors.primaryColor2;
                        break;
                      case 'transferred':
                        statusColor = Colors.black54;
                        break;
                    // Add more cases for different statuses if needed
                    }
                    // Determine color based on the task's priority
                    Color priorityColor = Colors.grey; // Default color
                    switch (task.priority) {
                      case 'High':
                        priorityColor = AppColors.primaryColor2;
                        break;
                      case 'Low':
                        priorityColor = Colors.green;
                        break;
                      case 'Critical':
                        priorityColor = Colors.red;
                        break;
                      case 'Medium':
                        priorityColor = Colors.blue;
                        break;
                    // Add more cases for different priorities if needed
                    }
                    return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 2),
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 9),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              AppColors.primaryColor2.withOpacity(0.3),
                              AppColors.primaryColor1.withOpacity(0.3)
                            ]),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      task.taskName,
                                      style: TextStyle(
                                          color: AppColors.secondaryColor2,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Assignee: ',
                                          style: TextStyle(
                                              color: AppColors.blackColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          task.assignedTo ?? 'N/A',
                                          style: TextStyle(
                                              color: AppColors.blackColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Priority: ',
                                          style: TextStyle(
                                              color: AppColors.secondaryColor2,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          task.priority,
                                          style: TextStyle(
                                              color: priorityColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Status: ',
                                          style: TextStyle(
                                              color: AppColors.secondaryColor2,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          task.status,
                                          style: TextStyle(
                                              color: statusColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Due Date: ',
                                          style: TextStyle(
                                              color: AppColors.blackColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          formatDate(task.dueDate) ?? '',
                                          style: TextStyle(
                                              color: AppColors.secondaryColor2,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          height: 30,
                                          child: RoundButton(
                                              title: "View More",
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        TaskDetailsScreen(
                                                      taskTitle: '',
                                                      assignee: '',
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                        SizedBox(
                                          width: 30,
                                        ),
                                        SizedBox(
                                          width: 100,
                                          height: 30,
                                          child: RoundButton(
                                              title: "Comments",
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      contentPadding:
                                                          EdgeInsets.fromLTRB(
                                                              16.0,
                                                              12.0,
                                                              16.0,
                                                              16.0), // Adjust content padding
                                                      title:
                                                          Text('Task Details'),
                                                      content:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(task.taskName),
                                                            // Text(task.description),
                                                            SizedBox(
                                                                height: 14.0),
                                                            Text(
                                                              'Comments:',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            SizedBox(
                                                                height: 8.0),
                                                            Column(
                                                              children: [
                                                                CommentWidget(
                                                                  commenter:
                                                                      'John',
                                                                  comment:
                                                                      'This is a comment',
                                                                  timestamp:
                                                                      'July 6, 2023',
                                                                  addSubCommentCallback:
                                                                      (String
                                                                          subComment) {
                                                                    // Handle adding the sub-comment to the main comment
                                                                    // You can perform any necessary actions with the sub-comment text here
                                                                    print(
                                                                        'Added sub-comment: $subComment');
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        16.0),
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              16.0),
                                                                  child:
                                                                      CommentWidget(
                                                                    commenter:
                                                                        'Alice',
                                                                    comment:
                                                                        'This is a sub-comment',
                                                                    timestamp:
                                                                        'July 7, 2023',
                                                                    addSubCommentCallback:
                                                                        (String
                                                                            subComment) {
                                                                      // Handle adding the sub-comment to the main comment
                                                                      // You can perform any necessary actions with the sub-comment text here
                                                                      print(
                                                                          'Added sub-comment: $subComment');
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 20.0),
                                                            RoundTextField(
                                                              hintText:
                                                                  "Add comments",
                                                              icon:
                                                                  "assets/images/comments.png",
                                                              textInputType:
                                                                  TextInputType
                                                                      .text,
                                                              onChanged:
                                                                  (value) {
                                                                if (value
                                                                    .contains(
                                                                        '@')) {
                                                                  String
                                                                      mentionedUser =
                                                                      value.substring(
                                                                          value.indexOf('@') +
                                                                              1);
                                                                  // TODO: Implement logic to search for suggested users based on the mentionedUser value
                                                                  // You can use a FutureBuilder or any other method to fetch and display the suggested users
                                                                  List<String>
                                                                      suggestedUsers =
                                                                      [
                                                                    'Samridhi',
                                                                    'Aman'
                                                                  ]; // Dummy list of suggested users

                                                                  // Show suggestions if there are any
                                                                  if (suggestedUsers
                                                                      .isNotEmpty) {
                                                                    showUserSuggestions(
                                                                        context,
                                                                        mentionedUser,
                                                                        suggestedUsers,
                                                                        _mentionController);
                                                                  }

                                                                  _mentionController
                                                                          .text =
                                                                      value;
                                                                }
                                                              },
                                                            ),
                                                            SizedBox(
                                                                height: 12.0),
                                                            Center(
                                                              child: SizedBox(
                                                                height: 30,
                                                                width: 70,
                                                                child:
                                                                    RoundButton(
                                                                        title:
                                                                            "Send",
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        }),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                            ],
                          ),
                        ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showUserSuggestions(BuildContext context, String query,
    List<String> suggestedUsers, TextEditingController _mentionController) {
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

class CommentWidget extends StatefulWidget {
  final String commenter;
  final String comment;
  final String timestamp;
  final Function(String) addSubCommentCallback;

  CommentWidget({
    required this.commenter,
    required this.comment,
    required this.timestamp,
    required this.addSubCommentCallback,
  });

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool isAddingSubComment = false;
  TextEditingController subCommentController = TextEditingController();
  List<String> subComments = [];

  @override
  void dispose() {
    subCommentController.dispose();
    super.dispose();
  }

  void toggleAddSubComment() {
    setState(() {
      isAddingSubComment = !isAddingSubComment;
    });
  }

  void addSubComment() {
    String subCommentText = subCommentController.text;
    if (subCommentText.isNotEmpty) {
      widget.addSubCommentCallback(subCommentText);
      subCommentController.clear();
      toggleAddSubComment();
    }
  }

  void openSubCommentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Sub-Comment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: subCommentController,
                decoration: InputDecoration(
                  labelText: 'Sub-Comment',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      addSubComment();
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Send'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.commenter,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4.0),
            Text(widget.timestamp),
          ],
        ),
        SizedBox(height: 4.0),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(widget.comment),
          if (!isAddingSubComment)
            GestureDetector(
              onTap: () {},
              child: Text(
                'Reply',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ]),
      ],
    );
  }
}
