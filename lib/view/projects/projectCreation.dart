import 'dart:async';
import 'dart:convert';
import 'package:Taskapp/common_widgets/round_textfield.dart';
import 'package:Taskapp/models/fetch_user_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Providers/project_provider.dart';
import '../../View_model/fetchApiSrvices.dart';
import '../../common_widgets/round_button.dart';
import '../../models/project_model.dart';
import '../../models/project_team_model.dart';
import '../../utils/app_colors.dart';

class ProjectCreationScreen extends StatefulWidget {
  final int? Count;

  const ProjectCreationScreen({super.key, this.Count});
  @override
  _ProjectCreationScreenState createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends State<ProjectCreationScreen> {
  TextEditingController _assigneeMembersController = TextEditingController();
  TextEditingController _assigneeTeamsController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _statusController = TextEditingController();
  List<String> _selectedMembers = [];
  List<String> _selectedTeams = [];
  late String _attachment = '';
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  List<dynamic> statuses = [];
  TextEditingController _attachmentController = TextEditingController();

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

  void createProject(int ProjectCount) async {
    if (_titleController.text.isEmpty) {
      showSnackbar(context, "Title is required");
      return;
    }

    if (_descriptionController.text.isEmpty) {
      showSnackbar(context, 'Description is required.');
      return;
    }



    if (_startDate == null) {
      showSnackbar(context, 'Start Date is required.');
      return;
    }

    if (_endDate == null) {
      showSnackbar(context, 'End Date is required.');
      return;
    }

    if (_selectedStatus==null) {
      showSnackbar(context, 'Status is required.');
      return;
    }

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
        "name": _titleController.text.toString(),
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
          ProjectCountManager projectCountManager = ProjectCountManager(prefs);
          await projectCountManager.incrementProjectCount();
          await projectCountManager.fetchTotalProjectCount();
          await projectCountManager.updateProjectCount();

          final project = data['data']['project'];

          // Handle the project data as needed
          print('Project ID: ${project['id']}');
          print('Project Name: ${project['name']}');

          // Create a Project instance with relevant data
          Project createdProject = Project(
            id: project['id'],
            name: project['name'],owner: project['created_by'], status: project['status'], description: project['description'] ?? " ",
            // Set other properties as needed
          );

          // Navigator.pop(context);
          // final ProjectDataProvider projectProvider = Provider.of<ProjectDataProvider>(context, listen: false);
          // projectProvider.addProject(createdProject);

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
                    Navigator.pop(context,true);
                    Navigator.pop(context,true);
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
    List<Team> teams = await _fetchTeams();

    List<String> selectedTeamsIds = _selectedTeams.toList(); // Store the initial selected ids

    final selectedTeamIds = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Teams'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: teams.map((team) {
                        bool isSelected = selectedTeamsIds.contains(team.id);

                        return ListTile(
                          title: Text(team.teamName),
                          trailing: isSelected
                              ? Icon(Icons.remove_circle, color: AppColors.primaryColor2)
                              : Icon(Icons.add_circle, color: AppColors.secondaryColor2),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedTeamsIds.remove(team.id);
                              } else {
                                selectedTeamsIds.add(team.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
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
      },
    );

    if (selectedTeamIds != null) {
      _selectedTeams = selectedTeamIds;
      List<String> selectedTeamsText = _selectedTeams
          .map((id) => teams.firstWhere((team) => team.id == id).teamName.toString())
          .toList();
      _assigneeTeamsController.text = selectedTeamsText.join(', ');
    }
  }

  void _showMembersDropdown(BuildContext context) async {
    List<User> allUsers = await _fetchUsers();

    List<String> selectedIds = _selectedMembers.toList(); // Store the initial selected ids

    final selectedUserIds = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Members'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: allUsers.map((user) {
                        bool isSelected = selectedIds.contains(user.userId);

                        return ListTile(
                          title: Text(user.userName),
                          trailing: isSelected
                              ? Icon(Icons.remove_circle, color: AppColors.primaryColor2)
                              : Icon(Icons.add_circle, color: AppColors.secondaryColor2),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedIds.remove(user.userId);
                              } else {
                                selectedIds.add(user.userId);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
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
          _attachmentController.text = _attachment;
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

  Future<void> fetchStatusData() async {
    try {
      List<dynamic> fetchedStatuses = await ApiServices.fetchStatusData();
      setState(() {
        statuses = fetchedStatuses;
        // Check if statuses list is not empty
        if (statuses.isNotEmpty) {
          // Initialize _selectedStatus to the first status ID in the list
          _selectedStatus = statuses[0]['id'].toString();
          statuses = fetchedStatuses
              .where((status) => status['name'] != 'Completed')
              .toList();

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
    _attachmentController.dispose();
    _assigneeMembersController.dispose();
    _assigneeTeamsController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchTeams();
    _fetchUsers();
    fetchStatusData();
    _titleController = TextEditingController();
    _attachmentController = TextEditingController();
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
                            _titleController.text = value;
                          });
                        },
                      ),
                      SizedBox(height: 20.0),
                      RoundTextField(
                        hintText: "Description",
                        icon: "assets/images/title.jpeg",
                        onChanged: (value) {
                          setState(() {
                            _descriptionController.text = value;
                          });
                        },
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
                        textEditingController: _attachmentController,
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
                        isReadOnly: true,
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
                        isReadOnly: true,
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
                      Padding(
                        padding: EdgeInsets.only(left: 20,right: 20),
                        child: Container(
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
                      ),
                      SizedBox(height: 40.0),
                      SizedBox(
                          height: 40,
                          width: 90,
                          child: RoundButton(
                              title: "Create Project", onPressed: (){
                                createProject(widget.Count!);
                                print("Count: ${widget.Count}");
                          })),
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



