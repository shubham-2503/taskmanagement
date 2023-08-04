import 'dart:convert';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/common_widgets/round_textfield.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../models/fetch_user_model.dart';
import '../../models/project_team_model.dart';
import '../../utils/app_colors.dart';

class EditTaskPage extends StatefulWidget {
  final String taskId;
  final String initialTitle;
  final String initialProject;
  final String initialAssignedTo;
  final String initialAssignedTeam;
  final String initialStatus;
  final String initialDescription;
  final String initialPriority;
  final String initialDueDate;

  EditTaskPage({
    required this.initialTitle,
    required this.initialProject,
    required this.initialAssignedTo,
    required this.initialStatus,
    required this.initialDescription,
    required this.initialPriority,
    required this.taskId,
    required this.initialDueDate,
    required this.initialAssignedTeam,
  });

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController titleController;
  late TextEditingController projectController;
  late TextEditingController assignedToController;
  late TextEditingController assignedTeamController;
  late TextEditingController statusController;
  late TextEditingController descriptionController;
  late TextEditingController priorityController;
  late TextEditingController dueDateController;
  late DateTime selectedDueDate;
  List<User> users = [];
  List<Team> teams = [];
  List<String> _selectedMembers = [];
  List<String> _selectedTeams = [];
  List<dynamic> priorities = [];
  late String _priority = " ";
  List<dynamic> statuses = [];
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    projectController = TextEditingController(text: widget.initialProject);
    assignedToController =
        TextEditingController(text: widget.initialAssignedTo);
    assignedTeamController =
        TextEditingController(text: widget.initialAssignedTeam);
    statusController = TextEditingController(text: widget.initialStatus);
    descriptionController =
        TextEditingController(text: widget.initialDescription);
    priorityController = TextEditingController(text: widget.initialPriority);
    dueDateController = TextEditingController(text: widget.initialDueDate);
    fetchUsers();
    fetchTeams();
    fetchStatusData();
    fetchPriorities();
  }

  @override
  void dispose() {
    titleController.dispose();
    projectController.dispose();
    assignedToController.dispose();
    statusController.dispose();
    descriptionController.dispose();
    priorityController.dispose();
    super.dispose();
  }

  Future<void> updateTasks(String taskId) async {
    try {
      List<String> assignedMembers = users.map((user) => user.userId).toList();
      List<String> assignedTeams = teams.map((team) => team.id).toList();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      final String? orgId = prefs.getString('org_id');

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      final url = 'http://43.205.97.189:8000/api/Task/editTasks?org_id=$orgId';

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
          "task_id": taskId,
          "name": titleController.text,
          "description": descriptionController.text,
          "priority": priorityController.text,
          "end_date": dueDateController.text,
          "assigned_user": assignedMembers,
          "assigned_team": assignedTeams,
          "project_id": projectController.text,
          "status": statusController.text,
      });

      final response =
          await http.patch(Uri.parse(url), headers: headers, body: body);
      print("StatusCode: ${response.statusCode}");
      print("Body: ${response.body}");
      print("Response: ${jsonDecode(body)}");

      if (response.statusCode == 200) {
        // Update successful
        final responseData = json.decode(response.body);
        print('Tasks updated successfully: ${responseData['message']}');
        // You can handle the response data here if needed

        // Optionally, you can show a dialog to inform the user about the successful update
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Changes Saved'),
              content: Text('Your changes have been updated successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    // Optionally, you can navigate back to the previous screen or perform any other action here
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        print('Error updating tasks: ${response.statusCode}');
        // Optionally, you can show an error dialog to inform the user about the update failure
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content:
                  Text('Failed to update tasks. Please try again later.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error updating tasks: $e');
      // Optionally, you can show an error dialog to inform the user about the update failure
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content:
                Text('An unexpected error occurred. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<List<User>> fetchUsers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      final String? orgId = prefs.getString('org_id');

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

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
          final List<User> users =
              data.map((userJson) => User.fromJson(userJson)).toList();

          // Process the teams data as needed
          // For example, you can store them in a state variable or display them in a dropdown menu

          // Print the team names for testing
          for (User user in users) {
            print('User ID: ${user.userId}');
            print('User Name: ${user.userName}');
          }
          return users;
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
                    users = snapshot
                        .data!; // Assign the fetched users to the instance variable
                    return SingleChildScrollView(
                      child: Column(
                        children: users.map((user) {
                          bool isSelected =
                              _selectedMembers.contains(user.userId);

                          return CheckboxListTile(
                            title: Text(user.userName),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedMembers.add(user.userId);
                                } else {
                                  _selectedMembers.remove(user.userId);
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
                      // Perform any desired actions with the selected members
                      // For example, you can add them to a list or display them in a text field
                      List<String> selectedMembersText = _selectedMembers
                          .map((id) => users
                              .firstWhere((user) => user.userId == id)
                              .userName
                              .toString())
                          .toList();
                      // Set the value of the desired fielda
                      assignedToController.text =
                          selectedMembersText.join(', ');
                    });
                    Navigator.of(context).pop(); // Close the dialog
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      final String? orgId = prefs.getString('org_id');

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      final response = await http.get(
        Uri.parse(
            'http://43.205.97.189:8000/api/Team/myTeams?org_id=$orgId'), // Update the API endpoint URL
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
          try {
            final List<dynamic> data = jsonDecode(responseBody);
            if (data != null) {
              final List<Team> teams = data
                  .map((teamJson) =>
                      Team.fromJson(teamJson as Map<String, dynamic>))
                  .toList();

              for (var team in teams) {
                print("Team Name: ${team.teamName}");
                print("Team ID: ${team.id}");
                print("Users: ${team.users}");
                print("----------------------");
              }

              return teams;
            }
          } catch (e) {
            print('Response Body: $responseBody');
            print('Error decoding JSON: $e');
          }
        }
      } else {
        print('Error: ${response.statusCode}');
      }
      return teams;
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch teams');
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
                    teams = snapshot
                        .data!; // Assign the fetched teams to the instance variable
                    return SingleChildScrollView(
                      child: Column(
                        children: teams.map((team) {
                          bool isSelected = _selectedTeams.contains(team.id);

                          return CheckboxListTile(
                            title: Text(team.teamName),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  if (!_selectedTeams.contains(team.id)) {
                                    _selectedTeams.add(team.id);
                                  }
                                } else {
                                  if (_selectedTeams.contains(team.id)) {
                                    _selectedTeams.remove(team.id);
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
                      // Perform any desired actions with the selected teams
                      // For example, you can add them to a list or display them in a text field
                      List<String> selectedTeamsText = _selectedTeams
                          .map((id) => teams
                              .firstWhere((team) => team.id == id)
                              .teamName
                              .toString())
                          .toList();
                      // Set the value of the desired field
                      assignedTeamController.text =
                          selectedTeamsText.join(', ');
                    });
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> fetchStatusData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');
    final String? orgId = prefs.getString('org_id');

    if (orgId == null) {
      throw Exception('orgId not found locally');
    }
    final response = await http
        .get(Uri.parse('http://43.205.97.189:8000/api/Platform/getStatus?org_id=$orgId'));

    print("StatusCode: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      setState(() {
        statuses = json.decode(response.body);
        _selectedStatus = statuses[0]['id'];
      });
    } else {
      print('Failed to fetch status. Status code: ${response.statusCode}');
    }
  }

  void fetchPriorities() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');
    final String? orgId = prefs.getString('org_id');

    if (orgId == null) {
      throw Exception('orgId not found locally');
    }
    final response = await http
        .get(Uri.parse('http://43.205.97.189:8000/api/Platform/getPriorities?org_id=$orgId'));

    if (response.statusCode == 200) {
      setState(() {
        priorities = json.decode(response.body);
        _priority = priorities[0]['id'];
      });
    } else {
      print('Failed to fetch priorities');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Title",
                style: TextStyle(
                  color: AppColors.secondaryColor2,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: RoundTextField(
                hintText: "Title",
                icon: "assets/images/title.jpeg",
                textEditingController: titleController,
              ),
            ),
            Visibility(
              visible: widget.initialProject != null &&
                  widget.initialProject!.isNotEmpty,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "Project",
                      style: TextStyle(
                        color: AppColors.secondaryColor2,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: RoundTextField(
                      textEditingController: projectController,
                      hintText: "Project",
                      icon: "assets/images/title.jpeg",
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Assigned To",
                style: TextStyle(
                  color: AppColors.secondaryColor2,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: GestureDetector(
                onTap: _showMembersDialog,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  height: MediaQuery.of(context).size.height * 0.12,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrayColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: assignedToController.text.isNotEmpty
                            ? [
                          Container(
                            // width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              color: AppColors.lightGrayColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Chip(
                              label: Text(
                                assignedToController.text,
                              ),
                              deleteIcon: Icon(Icons.clear),
                              onDeleted: () {
                                setState(() {
                                  assignedToController.clear();
                                });
                              },
                            ),
                          ),
                        ]
                            : [], // Show the selected priority name chip when priorityController is not empty
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: widget.initialAssignedTeam != null &&
                  widget.initialAssignedTeam!.isNotEmpty,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "Assigned Team",
                      style: TextStyle(
                        color: AppColors.secondaryColor2,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: RoundTextField(
                      textEditingController: assignedTeamController,
                      hintText: "Assigned Team",
                      icon: "assets/images/pers.png",
                      onTap: widget.initialAssignedTeam != null &&
                              widget.initialAssignedTeam!.isNotEmpty
                          ? _showTeamsDialog
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Selected Status:',
                style: TextStyle(
                  color: AppColors.secondaryColor2,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: GestureDetector(
                onTap: _showStatusDialog,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  height: MediaQuery.of(context).size.height * 0.12,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrayColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: statusController.text.isNotEmpty
                            ? [
                          Container(
                            // width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              color: AppColors.lightGrayColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                                  child: Chip(
                                    label: Text(
                                      statusController.text,
                                    ),
                                    deleteIcon: Icon(Icons.clear),
                                    onDeleted: () {
                                      setState(() {
                                        statusController.clear();
                                      });
                                    },
                                  ),
                                ),
                              ]
                            : [], // Show the selected priority name chip when priorityController is not empty
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Selected Priorities:',
                style: TextStyle(
                  color: AppColors.secondaryColor2,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: GestureDetector(
                onTap: _showPriorityDialog,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  height: MediaQuery.of(context).size.height * 0.12,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrayColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 2,
                        children: priorityController.text.isNotEmpty
                            ? [
                                Container(
                                  // width: MediaQuery.of(context).size.width * 0.8,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGrayColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Chip(
                                    label: Text(
                                      priorityController.text,
                                    ),
                                    deleteIcon: Icon(Icons.clear),
                                    onDeleted: () {
                                      setState(() {
                                        priorityController.clear();
                                      });
                                    },
                                  ),
                                ),
                              ]
                            : [], // Show the selected priority name chip when priorityController is not empty
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Due Date",
                style: TextStyle(
                  color: AppColors.secondaryColor2,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: GestureDetector(
                onTap: _selectDueDate,
                child: AbsorbPointer(
                  child: RoundTextField(
                    textEditingController: dueDateController,
                    hintText: "Due Date",
                    icon: "assets/icons/calendar_icon.png",
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.0),
            Center(
              child: SizedBox(
                  height: 30,
                  width: 120,
                  child: RoundButton(title: "Save Changes", onPressed: () {
                    updateTasks(widget.taskId);
                  })),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDueDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDueDate = pickedDate;
        dueDateController.text = selectedDueDate.toString();
      });
    }
  }

  // Function to fetch status data and show the status dialog
  void _showStatusDialog() {
    print("Status dialog is being shown");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              bool isSelected = _selectedStatus == status['id'];

              return CheckboxListTile(
                title: Text(status['name']),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = isSelected ? null : status['id'];
                  });
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              child: Text('Done'),
              onPressed: () {
                if (_selectedStatus != null) {
                  String selectedStatusName = statuses.firstWhere(
                      (status) => status['id'] == _selectedStatus)['name'];
                  setState(() {
                    priorityController.text = selectedStatusName;
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Function to fetch priority data and show the priority dialog
  void _showPriorityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Priority'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: priorities.map((priority) {
                  bool isSelected = _priority == priority['id'];

                  return CheckboxListTile(
                    title: Text(priority['name']),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        _priority = value! ? priority['id'] : null;
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  child: Text('Done'),
                  onPressed: () {
                    if (_priority != null) {
                      String selectedPriorityName = priorities.firstWhere(
                          (priority) => priority['id'] == _priority)['name'];
                      setState(() {
                        priorityController.text = selectedPriorityName;
                      });
                    }
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
