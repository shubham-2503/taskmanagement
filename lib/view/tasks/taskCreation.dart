import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../common_widgets/date_widget.dart';
import '../../common_widgets/round_textfield.dart';
import '../../common_widgets/snackbar.dart';
import '../../models/fetch_user_model.dart';
import '../../models/project_model.dart';
import '../../models/project_team_model.dart';
import '../../utils/app_colors.dart';

class MisTaskCreationScreen extends StatefulWidget {

  @override
  _MisTaskCreationScreenState createState() => _MisTaskCreationScreenState();
}

class _MisTaskCreationScreenState extends State<MisTaskCreationScreen> {
  late String _taskTitle;
  late String _taskDescription = '';
  late String _attachment = '';
  List<String> _selectedMembers = [];
  List<String> _selectedTeams = [];
  DateTime? _startDate;
  DateTime? _endDate;
  List<dynamic> priorities = [];
  late String _priority = " ";
  TextEditingController _assigneeMembersController = TextEditingController();
  TextEditingController _assigneeTeamsController = TextEditingController();
  TextEditingController _attachmentController = TextEditingController();
  List<User> users =[];
  List<Team> teams = [];
  List<dynamic> statuses = [];
  String? _selectedStatus;
  List<Project> projects = [];
  String? _selectedProject;

  @override
  void initState() {
    super.initState();
    _attachmentController.text = _attachment;
    fetchPriorities();
    fetchStatusData();
    fetchUsers();
    fetchTeams();
    fetchMyProjects();
  }

  Future<void> fetchMyProjects() async {
    try {
      final url = 'http://43.205.97.189:8000/api/Project/myProjects';

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final List<Project> fetchedProjects = responseData.map((projectData) {
          // Convert the 'status' field to a string representation
          String status = projectData['status'] == true ? 'Active' : 'In-Active';
          String projectId = projectData['project_id'] ?? '';

          return Project(
            id: projectId,
            name: projectData['projectName'] ?? '',
            owner: projectData['created_by'] ?? '',
            status: status,
            dueDate: projectData['due_Date'] is bool ? null : projectData['due_Date'],
            // tasks: tasks,
            teams: teams,
            // users: users,
          );
        }).toList();

        // Create a default "NA" project for users who don't want to add project-tasks
        final Project naProject = Project(
          id: 'NA',
          name: 'NA (No Project)',
          owner: '',
          status: 'Active',
          dueDate: null,
          teams: [], // You can set teams and other fields as needed
        );

        setState(() {
          projects = [naProject, ...fetchedProjects];
        });

        // Check if projects list is not empty
        if (projects.isNotEmpty) {
          // Initialize _selectedProject to the first project ID in the list
          _selectedProject = projects[0].id;
        } else {
          // If projects list is empty, set _selectedProject to null
          _selectedProject = null;
        }
      } else {
        print('Error fetching projects: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching projects: $e');
    }
  }

  Future<void> fetchStatusData() async {
    final response = await http.get(Uri.parse('http://43.205.97.189:8000/api/Platform/getStatus'));

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
          final List<User> users = data.map((userJson) => User.fromJson(userJson)).toList();

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
                    users = snapshot.data!; // Assign the fetched users to the instance variable
                    return SingleChildScrollView(
                      child: Column(
                        children: users.map((user) {
                          bool isSelected = _selectedMembers.contains(user.userId);

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
                          .map((id) => users.firstWhere((user) => user.userId == id).userName.toString())
                          .toList();
                      // Set the value of the desired field
                      _assigneeMembersController.text = selectedMembersText.join(', ');
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

      final response = await http.get(
        Uri.parse('http://43.205.97.189:8000/api/Team/myTeams'), // Update the API endpoint URL
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
                  .map((teamJson) => Team.fromJson(teamJson as Map<String, dynamic>))
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
                    teams = snapshot.data!; // Assign the fetched teams to the instance variable
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
                          .map((id) => teams.firstWhere((team) => team.id == id).teamName.toString())
                          .toList();
                      // Set the value of the desired field
                      _assigneeTeamsController.text = selectedTeamsText.join(', ');
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
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightGrayColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedProject,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 15,
                            ),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: "Project",
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
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
                          items: projects.map<DropdownMenuItem<String>>((project) {
                            return DropdownMenuItem<String>(
                              value: project.id,
                              child: Text(project.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedProject = value; // Update the selected project here
                            });
                          },
                        ),
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
                      SizedBox(height: 16.0),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightGrayColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 15,
                            ),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: "Status",
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
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
                          items: statuses.map<DropdownMenuItem<String>>((status) {
                            return DropdownMenuItem<String>(
                              value: status['id'].toString(), // Assuming 'id' is of type String or can be converted to String
                              child: Text(status['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value;
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
    DateTime? startDate = await DatePickerUtils.selectStartDate(context);
    if (startDate != null) {
      setState(() {
        _startDate = startDate;
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    // Use DatePickerUtils.selectEndDate instead of showDatePicker directly
    DateTime? endDate = await DatePickerUtils.selectEndDate(context, _startDate);
    if (endDate != null) {
      setState(() {
        _endDate = endDate;
      });
    }
  }

  void createTask() async {
    if (_taskTitle.isEmpty) {
      DialogUtils.showSnackbar(context, 'Task Title is required.');
      return;
    }

    if (_taskDescription.isEmpty) {
      DialogUtils.showSnackbar(context, 'Task Description is required.');
      return;
    }

    // if (_attachment.isEmpty) {
    // DialogUtils.showSnackbar(context, 'Attachment is required.');
    //   return;
    // }

    if (_selectedMembers.isEmpty) {
      DialogUtils.showSnackbar(context, 'Assignee Members is required.');
      return;
    }

    // if (_selectedTeams.isEmpty) {
    //   DialogUtils.showSnackbar(context, 'AssigneeTeam is required.');
    //   return;
    // }

    if (_startDate == null) {
      DialogUtils.showSnackbar(context, 'Start Date is required.');
      return;
    }

    if (_endDate == null) {
      DialogUtils.showSnackbar(context, 'End Date is required.');
      return;
    }

    if (_priority.isEmpty) {
      DialogUtils.showSnackbar(context, 'Task Priority is required.');
      return;
    }

    if (_selectedStatus == null) {
      DialogUtils.showSnackbar(context, 'Status is required.');
      return;
    }

    if (_selectedProject == null) {
      DialogUtils.showSnackbar(context, 'Project is required.');
      return;
    }

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
      "status": _selectedStatus, // Replace with the appropriate status ID
    };

    if (_selectedProject != "NA") {
      taskData["project_id"] = _selectedProject;
    } else {
      taskData["project_id"] = null; // Set project_id to null for the "NA" project
    }

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
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Thank You'),
              content: RichText(
                text: TextSpan(
                  text: 'Your Task ',
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: taskTitle.isNotEmpty
                          ? taskTitle
                          : '',
                      style: TextStyle(
                        color: Colors.black, // Set the desired color here
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text: ' has been successfully created.',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
              actions: [
                InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Text("OK",style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 20
                    ),))
              ],
            );
          },
        );
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
