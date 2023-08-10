import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../common_widgets/round_textfield.dart';
import '../../common_widgets/snackbar.dart';
import '../../models/project_team_model.dart';
import 'package:Taskapp/models/fetch_user_model.dart';
import '../../utils/app_colors.dart';

class ProjectTaskCreationScreen extends StatefulWidget {
  final String ProjectId;
  final String ProjectName;

  const ProjectTaskCreationScreen({super.key, required this.ProjectId, required this.ProjectName});
  @override
  _ProjectTaskCreationScreenState createState() => _ProjectTaskCreationScreenState();
}

class _ProjectTaskCreationScreenState extends State<ProjectTaskCreationScreen> {
  late String _taskTitle;
  late String _taskDescription;
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
  List<String> _selectedMembers = [];
  List<String> _selectedTeams = [];
  List<dynamic> statuses = [];
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    projectNameController = TextEditingController(text: widget.ProjectName);
    _attachmentController.text = _attachment;
    fetchPriorities();
    fetchTeams();
    fetchUsers();
    fetchStatusData();
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

  Future<List<Team>> fetchTeams() async {
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

      final response = await http.get(
        Uri.parse('http://43.205.97.189:8000/api/Team/myTeams?org_id=$orgId'), // Update the API endpoint URL
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

  Future<List<User>> fetchUsers() async {
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

      if (storedData == null || storedData.isEmpty) {
        // Handle the case when storedData is null or empty
        print('Stored token is null or empty. Cannot make API request.');
        throw Exception('Failed to fetch users: Stored token is null or empty.');
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
          final List<User> users = data.map((userJson) => User.fromJson(userJson)).toList();

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

  void _showTeamsDropdown(BuildContext context) async {
    List<Team> _teams = await fetchTeams();

    final selectedTeamIds = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        List<String> selectedTeamsIds = _selectedTeams.toList();
        return AlertDialog(
          title: Text('Select Teams'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: _teams.map((team) {
                        bool isSelected = selectedTeamsIds.contains(team.id);

                        return CheckboxListTile(
                          title: Text(team.teamName),
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedTeams.add(team.id);
                              } else {
                                _selectedTeams.remove(team.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Done'),
              onPressed: () {
                Navigator.of(context).pop(selectedTeamsIds);
              },
            ),
          ],
        );
      },
    );

    if (selectedTeamIds != null) {
      _selectedTeams = selectedTeamIds;
      List<String> selectedTeamsText = _selectedTeams
          .map((id) => _teams.firstWhere((team) => team.id == id).teamName.toString())
          .toList();
      _assigneeTeamsController.text = selectedTeamsText.join(', ');
    }
  }

  void _showMembersDropdown(BuildContext context) async {
    List<User> allUsers = await fetchUsers();

    final selectedUserIds = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        List<String> selectedIds = _selectedMembers.toList();
        return AlertDialog(
          title: Text('Select Members'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: allUsers.map((user) {
                        bool isSelected = selectedIds.contains(user.userId);

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
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Done'),
              onPressed: () {
                Navigator.of(context).pop(selectedIds);
              },
            ),
          ],
        );
      },
    );

    if (selectedUserIds != null) {
      _selectedMembers = selectedUserIds;
      List<String> selectedMembersText = _selectedMembers
          .map((id) => allUsers.firstWhere((user) => user.userId == id).userName.toString())
          .toList();
      _assigneeMembersController.text = selectedMembersText.join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectId = widget.ProjectId;
    final projectName = widget.ProjectName;
    print("Id: $projectId");
    print("Name: $projectName");
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Text(
          'Task Creation With Project',
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
                        onTap: (){
                          _showMembersDropdown(context);
                        },
                        textEditingController: _assigneeMembersController,
                      ),
                      SizedBox(height: 16.0),
                      RoundTextField(
                        hintText: "Assignee Teams",
                        icon: "assets/images/pers.png",
                        onTap:(){
                          _showTeamsDropdown(context);
                        },
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
                          onPressed: (){
                            createTask();
                          },
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

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        backgroundColor: AppColors.primaryColor1,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void createTask() async {
    if (_taskTitle.isEmpty) {
      showSnackbar(context, "Title is required");
    }

    if (_taskDescription.isEmpty) {
      showSnackbar(context, "Description is required");
    }


    if (_startDate == null) {
      showSnackbar(context, "Start Date is required");
    }

    if (_endDate == null) {
      showSnackbar(context, "End date is required");
    }

    if (_priority.isEmpty) {
      showSnackbar(context, "Priority is required");
    }

    if (_selectedStatus == null) {
      showSnackbar(context, "Status is required");
    }

    if (projectNameController == null) {
      showSnackbar(context, "Project is required");
    }

    // String projectname = projectNameController.text;
    String taskTitle = _taskTitle;
    String taskDescription = _taskDescription;
    String attachment = _attachment;
    List<String> assignedMembers = users.map((user) => user.userId).toList();
    List<String> assignedTeams = teams.map((team) => team.id).toList();
    String priority = _priority;

    // Get the current timestamp
    DateTime currentTimestamp = DateTime.now();

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

    print("Data: $taskData");

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


      String apiUrl = 'http://43.205.97.189:8000/api/Task/tasks?project_id=${widget.ProjectId}&org_id=$orgId';

      // Send the HTTP POST request to create the task with the project_id as a query parameter
      final response = await http.post(
        Uri.parse(apiUrl),
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
