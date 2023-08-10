import 'dart:async';
import 'dart:convert';
import 'package:Taskapp/common_widgets/round_textfield.dart';
import 'package:Taskapp/models/fetch_user_model.dart';
import 'package:Taskapp/view/projects/projectDashScreen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:search_choices/search_choices.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Providers/project_provider.dart';
import '../../View_model/fetchApiSrvices.dart';
import '../../common_widgets/round_button.dart';
import '../../models/project_model.dart';
import '../../models/project_team_model.dart';
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
  List<dynamic> statuses = [];
  String? _selectedStatus;
  List<dynamic> priorities = [];
  String? _selectedPriority;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _documentsController = TextEditingController();
  List<User> users =[];
  List<Team> teams = [];
  List<String> _selectedMembers = [];
  List<String> _selectedTeams = [];
  TextEditingController _assigneeMembersController = TextEditingController();
  TextEditingController _assigneeTeamsController = TextEditingController();

  void createProject() async {
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

      final url = 'http://43.205.97.189:8000/api/Project/addProjects?org_id=$orgId';

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        "name": _projectTitle,
        "start_date": _startDate?.toUtc().toIso8601String(),
        "end_date": _endDate?.toUtc().toIso8601String(),
        "status" : _selectedStatus,
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

          // Create a Project instance with relevant data
          Project createdProject = Project(
            id: project['id'],
            name: project['name'],owner: project['created_by'], status: project['status']
            // Set other properties as needed
          );

          Navigator.pop(context,createdProject);
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
                actions: [
                  InkWell(
                    onTap: () async {
                       // Close the dialog
                      Navigator.pop(context,createdProject);
                    },
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
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

  void _showTeamsDropdown(BuildContext context) async {
    List<Team> _teams = await _fetchTeams();

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
    List<User> allUsers = await _fetchUsers();

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

  Future<List<User>> _fetchUsers() async {
    try {
      ApiServices apiServices = ApiServices();
      List<User> fetchedUsers = await apiServices.fetchUsers();
      return fetchedUsers;
    } catch (error) {
      print('Error fetching users: $error');
      // Handle error if necessary
      return [];
    }
  }

  Future<List<Team>> _fetchTeams() async {
    try {
      ApiServices apiServices = ApiServices();
      List<Team> fetchedTeams = await apiServices.fetchTeams();
      return fetchedTeams;
    } catch (error) {
      print('Error fetching teams: $error');
      // Handle error if necessary
      return [];
    }
  }

  Future<void> fetchPriorities() async {
    try {
      List<dynamic> fetchedPriorities = await ApiServices.fetchPriorities();
      setState(() {
        priorities = fetchedPriorities;
        // Check if priorities list is not empty
        if (priorities.isNotEmpty) {
          // Initialize _selectedPriority to the first priority ID in the list
          _selectedPriority = priorities[0]['id'];
        } else {
          // If priorities list is empty, set _selectedPriority to null
          _selectedPriority = null;
        }
      });
    } catch (e) {
      print('Error fetching priorities: $e');
      // Handle error if necessary
    }
  }

  Future<void> fetchStatusData() async {
    try {
      List<dynamic> fetchedStatuses = await ApiServices.fetchStatusData();
      setState(() {
        statuses = fetchedStatuses;
        // Check if statuses list is not empty
        if (statuses.isNotEmpty) {
          // Initialize _selectedStatus to the first status ID in the list
          _selectedStatus = statuses[0]['id'].toString();
        } else {
          // If statuses list is empty, set _selectedStatus to null
          _selectedStatus = null;
        }
      });
    } catch (e) {
      print('Error fetching statuses: $e');
      // Handle error if necessary
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _documentsController.dispose();
    _assigneeMembersController.dispose();
    _assigneeTeamsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchTeams();
    _fetchUsers();
    fetchPriorities();
    fetchStatusData();
    _titleController = TextEditingController();
    _documentsController = TextEditingController();
    _assigneeMembersController = TextEditingController();
    _assigneeTeamsController = TextEditingController();
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
                        onTap: (){
                          _showMembersDropdown(context);
                        },
                        textEditingController: _assigneeMembersController,
                      ),
                      SizedBox(height: 20.0),
                      Text("Assigned Team"),
                      RoundTextField(
                        hintText: "Assignee Teams",
                        icon: "assets/images/pers.png",
                        onTap:(){
                          _showTeamsDropdown(context);
                        },
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
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 150,
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
                                  fontSize: 8,
                                  color: Colors.grey,
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
                                  _selectedStatus = value; // Call the callback function with the selected value
                                });
                              },
                            ),
                          ),
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
