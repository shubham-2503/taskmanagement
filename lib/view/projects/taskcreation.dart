import 'dart:convert';
import 'package:Taskapp/View_model/api_services.dart';
import 'package:http/http.dart' as http;
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/view/tasks/tasks.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../common_widgets/round_textfield.dart';
import '../../models/teams.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';

class TaskCreationScreen extends StatefulWidget {
  final String initialTitle;

  const TaskCreationScreen({super.key, required this.initialTitle});
  @override
  _TaskCreationScreenState createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  ApiRepo apiRepo = ApiRepo();
  late String _projectName;
  late String _taskTitle;
  late String _taskDescription;
  late String _organizationName;
  late String _attachment = '';// Updated to store Team objects
  DateTime? _startDate;
  DateTime? _endDate;
  List<dynamic> priorities = [];
  late String _priority;
  TextEditingController _assigneeMembersController = TextEditingController();
  TextEditingController _assigneeTeamsController = TextEditingController();
  TextEditingController _attachmentController = TextEditingController();
  TextEditingController projectNameController = TextEditingController();
  List<User> users = [];
  List<Team> teams = [];

  @override
  void initState() {
    super.initState();
    projectNameController = TextEditingController(text: widget.initialTitle);
    _attachmentController.text = _attachment;
    fetchPriorities();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    projectNameController.dispose();
    super.dispose();
  }

  void fetchPriorities() async {
    final response = await http.get(Uri.parse('http://43.205.97.189:8000/api/Platform/getPriorities'));

    if (response.statusCode == 200) {
      setState(() {
        priorities = json.decode(response.body);
        _priority = priorities[0]['id'];
      });
    } else {
      print('Failed to fetch priorities');
    }
  }

  void openFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false, // Allow only a single file selection
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        setState(() {
          _attachment = file.path ?? '';
          _attachmentController.text = _attachment;
        });
      }
    } on PlatformException catch (e) {
      print('Error while picking the file: $e');
    }
  }

  Future<List<User>> fetchUsers() async {
    try {
      // Call the fetchUsers function from api_service.dart
      final users = await apiRepo.fetchUsers();
      return users ?? []; // If users is null, return an empty list
    } catch (e) {
      print('Error while fetching users: $e');
      return []; // Return an empty list in case of an error
    }
  }

  void _showMembersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Assignee Members'),
              content: FutureBuilder<List<User>>(
                future: fetchUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    users = snapshot.data!; // Assign the fetched users to the instance variable
                    return SingleChildScrollView(
                      child: Column(
                        children: users.map((user) {
                          bool isSelected = users.contains(user);

                          return CheckboxListTile(
                            title: Text(user.userName),
                            value: users.contains(user), // Check if the user is already in the users list
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  users.add(user); // Add the user to the list if the checkbox is checked
                                } else {
                                  users.remove(user); // Remove the user from the list if the checkbox is unchecked
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    return Text('No members found.');
                  }
                },
              ),
              actions: [
                TextButton(
                  child: Text('Add'),
                  onPressed: () {
                    setState(() {
                      // Close the dialog
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<Team>> fetchTeams() async {
    try {
      // Call the fetchTeams function from api_service.dart
      final teams = await apiRepo.fetchTeams();
      return teams ?? []; // If teams is null, return an empty list
    } catch (e) {
      print('Error while fetching teams: $e');
      return []; // Return an empty list in case of an error
    }
  }

  void _showTeamsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Assignee Teams'),
              content: FutureBuilder<List<Team>>(
                future: fetchTeams(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    teams = snapshot.data!; // Assign the fetched teams to the instance variable
                    return SingleChildScrollView(
                      child: Column(
                        children: teams.map((team) {
                          bool isSelected = teams.contains(team);

                          return CheckboxListTile(
                            title: Text(team.name),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  if (!teams.contains(team)) {
                                    teams.add(team);
                                  }
                                } else {
                                  if (teams.contains(team)) {
                                    teams.remove(team);
                                  }
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    return Text('No teams found.');
                  }
                },
              ),
              actions: [
                TextButton(
                  child: Text('Add'),
                  onPressed: () {
                    setState(() {
                      // Close the dialog
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Text(
          'Task Creation',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      RoundTextField(
                        hintText: "Project Name",
                        icon: "assets/icons/naa.png",
                       isReadOnly: true,
                        textEditingController: projectNameController,
                      ),
                      SizedBox(height: 16.0),
                      RoundTextField(
                        hintText: "Task Title",
                        icon: "assets/images/title.jpeg",
                        textInputType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {
                            _taskTitle = value;
                          });
                        },
                      ),
                      SizedBox(height: 16.0),
                      RoundTextField(
                        hintText: "Task Description",
                        icon: "assets/images/des.png",
                        textInputType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {
                            _taskDescription = value;
                          });
                        },
                      ),
                      SizedBox(height: 16.0),
                      RoundTextField(
                        hintText: "Attachment",
                        icon: "assets/images/att.png",
                        onTap: openFilePicker,
                        isReadOnly: true,
                        onChanged: (value) {
                          setState(() {
                            _attachmentController.text = value;
                          });
                        },
                      ),
                      SizedBox(height: 16.0),
                      RoundTextField(
                        hintText: "Assignee Members",
                        icon: "assets/images/pers.png",
                        onTap: _showMembersDialog,
                        textEditingController: _assigneeMembersController,
                      ),
                      SizedBox(height: 16.0),
                      RoundTextField(
                        hintText: "Assignee Teams",
                        icon: "assets/images/pers.png",
                        onTap: _showTeamsDialog,
                        textEditingController: _assigneeTeamsController,
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: RoundTextField(
                              hintText: "Start Date",
                              icon: "assets/icons/calendar_icon.png",
                              isReadOnly: true,
                              onTap: () {
                                _selectStartDate(context);
                              },
                              textEditingController: TextEditingController(
                                text: _startDate != null
                                    ? DateFormat('yyyy-MM-dd')
                                    .format(_startDate!)
                                    : '',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectStartDate(context);
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: RoundTextField(
                              hintText: "End Date",
                              icon: "assets/icons/calendar_icon.png",
                              isReadOnly: true,
                              onTap: () {
                                _selectEndDate(context);
                              },
                              textEditingController: TextEditingController(
                                text: _endDate != null
                                    ? DateFormat('yyyy-MM-dd')
                                    .format(_endDate!)
                                    : '',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectStartDate(context);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightGrayColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _priority,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 15,
                            ),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: "Priority",
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: AppColors.grayColor,
                            ),
                            icon: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Image.asset(
                                "assets/images/pri.png",
                                width: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          items: priorities.map((priority) {
                            return DropdownMenuItem<String>(
                              value: priority['id'],
                              child: Text(priority['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _priority = value!;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 30.0),
                      SizedBox(
                        height: 40,
                        width: 100,
                        child: RoundButton(
                          title: "Create Task",
                          onPressed: createTask,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void createTask() async {
    // Fetch the necessary data from the form fields
    String projectName = projectNameController.text;
    String taskTitle = _taskTitle;
    String taskDescription = _taskDescription;
    String attachment = _attachment;
    List<String> assignedMembers = users.map((user) => user.userId).toList();
    List<String> assignedTeams = teams.map((team) => team.id).toList();
    String priority = _priority;

    // Get the current timestamp
    DateTime currentTimestamp = DateTime.now();

    // Format the timestamp as a string
    String creationTimestamp = currentTimestamp.toIso8601String();

    // Convert the start_date and end_date to UTC before sending
    String? startDate = _startDate?.toUtc().toIso8601String();
    String? endDate = _endDate?.toUtc().toIso8601String();

    // Create a map representing the task data
    Map<String, dynamic> taskData = {
      "name": taskTitle,
      "description": taskDescription,
      "priority": priority,
      "attachment": attachment,
      "start_date": startDate,
      "end_date": endDate,
      "assigned_user": assignedMembers,
      "assigned_team": assignedTeams,
      "status": "3fa85f64-5717-4562-b3fc-2c963f66afa6", // Replace with the appropriate status ID
    };

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      // Send the HTTP POST request to create the task
      final response = await http.post(
        Uri.parse('http://43.205.97.189:8000/api/Task/tasks'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData', // Replace with the actual access token
          'Content-Type': 'application/json',
        },
        body: json.encode(taskData),
      );

      print("Response: ${response.body}");
      print("StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Task creation successful
        print('Task created successfully');

        // Proceed to the next screen or perform any additional actions if needed

      } else {
        // Task creation failed
        print('Failed to create task: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while creating task: $e');
    }
  }

}
