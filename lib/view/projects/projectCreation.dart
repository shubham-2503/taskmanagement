import 'dart:async';
import 'dart:convert';
import 'package:Taskapp/View_model/api_services.dart';
import 'package:Taskapp/common_widgets/round_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:search_choices/search_choices.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../common_widgets/round_button.dart';
import '../../models/teams.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';

class ProjectCreationScreen extends StatefulWidget {
  @override
  _ProjectCreationScreenState createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends State<ProjectCreationScreen> {
  late String _projectTitle;
  late String _attachment = '';
  DateTime? _startDate;
  DateTime? _endDate;
  bool value = false;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _documentsController = TextEditingController();
  List<User> users =[];
  List<Team> teams = [];
  List<String> _selectedMembers = [];
  List<String> _selectedTeams = [];
  TextEditingController _assigneeMembersController = TextEditingController();
  TextEditingController _assigneeTeamsController = TextEditingController();
  ApiRepo apiRepo = ApiRepo();

  void createProject() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      final url = 'http://43.205.97.189:8000/api/Project/addProjects';

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        "name": _projectTitle,
        "start_date": _startDate?.toUtc().toIso8601String(),
        "end_date": _endDate?.toUtc().toIso8601String(),
        "team_id": _selectedTeams, // Remove the square brackets here
        "user_id": _selectedMembers, // Remove the square brackets here
      });

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      print("Response: ${response.body}");
      print("StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          final project = data['data']['project'];

          // Handle the project data as needed
          print('Project ID: ${project['id']}');
          print('Project Name: ${project['name']}');
          // ...
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Thank You'),
                content: RichText(
                  text: TextSpan(
                    text: 'Your project ',
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: _titleController.text.isNotEmpty
                            ? _titleController.text
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
              );
            },
          );
        } else {
          print('Error creating project: ${data['message']}');
        }
      } else {
        print('Error creating project: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating project: $e');
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
          _documentsController.text = _attachment;
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
  void dispose() {
    _titleController.dispose();
    _documentsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchTeams();
    fetchUsers();
    _titleController = TextEditingController();
    _documentsController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Project',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: constraints.maxHeight,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      RoundTextField(
                        hintText: "Title",
                        icon: "assets/images/title.jpeg",
                        onChanged: (value) {
                          setState(() {
                            _projectTitle = value;
                          });
                        },
                        textInputType: TextInputType.text,
                        textEditingController: _titleController,
                      ),
                      SizedBox(height: 20.0),
                      RoundTextField(
                        hintText: "Documents",
                        icon: "assets/images/att.png",
                        onTap: openFilePicker,
                        isReadOnly: true,
                        onChanged: (value) {
                          setState(() {
                            _attachment = value;
                          });
                        },
                        textEditingController: _documentsController,
                      ),
                      SizedBox(height: 20.0),
                      Text("Assigned To"),
                      RoundTextField(
                        hintText: "Assignee Members",
                        icon: "assets/images/pers.png",
                        onTap: _showMembersDialog,
                        textEditingController: _assigneeMembersController,
                      ),
                      SizedBox(height: 20.0),
                      Text("Assigned Team"),
                      RoundTextField(
                        hintText: "Assignee Teams",
                        icon: "assets/images/pers.png",
                        onTap: _showTeamsDialog,
                        textEditingController: _assigneeTeamsController,
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        children: [
                          Container(
                            height: 60,
                            width: 150,
                            decoration: BoxDecoration(
                              color: AppColors.lightGrayColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: TextFormField(
                              onTap: () {
                                _selectStartDate(context);
                              },
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: 'Start Date',
                                hintStyle: TextStyle(fontSize: 12, color: AppColors.grayColor),
                                prefixIcon: Container(
                                  alignment: Alignment.center,
                                  width: 20,
                                  height: 20,
                                  child: Image.asset(
                                    "assets/icons/calendar_icon.png",
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              controller: TextEditingController(
                                text: _startDate != null
                                    ? DateFormat('yyyy-MM-dd').format(_startDate!)
                                    : '',
                              ),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Container(
                            height: 60,
                            width: 150,
                            decoration: BoxDecoration(
                              color: AppColors.lightGrayColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: TextFormField(
                              onTap: () {
                                _selectEndDate(context);
                              },
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: 'End Date',
                                hintStyle: TextStyle(fontSize: 12, color: AppColors.grayColor),
                                prefixIcon: Container(
                                  alignment: Alignment.center,
                                  width: 20,
                                  height: 20,
                                  child: Image.asset(
                                    "assets/icons/calendar_icon.png",
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              controller: TextEditingController(
                                text: _endDate != null
                                    ? DateFormat('yyyy-MM-dd').format(_endDate!)
                                    : '',
                              ),
                            ),
                          ),
                          // Expanded(
                          //   child: RoundTextField(
                          //     hintText: "End Date",
                          //     icon: "assets/icons/calendar_icon.png",
                          //     isReadOnly: true,
                          //     textInputType: TextInputType.datetime,
                          //     onTap: () {
                          //       _selectEndDate(context);
                          //     },
                          //     textEditingController: TextEditingController(
                          //       text: _endDate != null
                          //           ? DateFormat('yyyy-MM-dd').format(_endDate!)
                          //           : '',
                          //     ),
                          //     onChanged: (value) {
                          //       setState(() {
                          //         _selectEndDate(context); // Updated here
                          //       });
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(height: 40.0),
                      SizedBox(
                          height: 40,
                          width: 90,
                          child: RoundButton(
                              title: "Create Project", onPressed: createProject)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().toUtc(), // Set initial date in UTC format
      firstDate: DateTime.now().toUtc(), // Set first selectable date in UTC format
      lastDate: DateTime.now().add(Duration(days: 365)).toUtc(), // Set last selectable date in UTC format
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
      initialDate: (_startDate ?? DateTime.now()).toUtc(), // Set initial date in UTC format, considering the selected start date if available
      firstDate: (_startDate ?? DateTime.now()).toUtc(), // Set first selectable date in UTC format, considering the selected start date if available
      lastDate: DateTime.now().add(Duration(days: 365)).toUtc(), // Set last selectable date in UTC format
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }


}
