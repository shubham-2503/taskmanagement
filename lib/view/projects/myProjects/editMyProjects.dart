import 'package:http/http.dart' as http;
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:flutter/material.dart';
import '../../../View_model/fetchApiSrvices.dart';
import '../../../View_model/updateApiSevices.dart';
import '../../../models/fetch_user_model.dart';
import '../../../models/project_team_model.dart';
import '../../../utils/app_colors.dart';

class EditMyProjectPage extends StatefulWidget {
  final String projectId;
  final String initialTitle;
  final String initialAssignedTo;
  final String? initialAssignedTeam;
  final String initialStatus;
  final String initialDueDate;

  EditMyProjectPage({
    required this.initialTitle,
    required this.initialAssignedTo,
    this.initialAssignedTeam,
    required this.initialStatus,
    required this.initialDueDate, required this.projectId,
  });

  @override
  _EditMyProjectPageState createState() => _EditMyProjectPageState();
}

class _EditMyProjectPageState extends State<EditMyProjectPage> {
  late TextEditingController titleController;
  late TextEditingController assignedToController;
  TextEditingController assignedTeamController = TextEditingController();
  late TextEditingController statusController;
  late TextEditingController dueDateController;
  late DateTime selectedDueDate;
  List<User> users =[];
  List<Team> teams = [];
  late bool isActive;
  List<String> _selectedMembers = [];
  List<String> _selectedTeams = [];
  List<User> temporarySelectedMembers = [];
  List<Team> temporarySelectedTeams = [];


  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    assignedToController = TextEditingController(text: widget.initialAssignedTo);
    assignedTeamController = TextEditingController(text: widget.initialAssignedTeam); // Add this line
    statusController = TextEditingController(text: widget.initialStatus);

    try {
      selectedDueDate = DateTime.parse(widget.initialDueDate);
      isActive = selectedDueDate.isAfter(DateTime.now()); // Initialize isActive based on the initial due date
    } catch (e) {
      // Handle invalid date format gracefully, defaulting to today's date
      selectedDueDate = DateTime.now();
      isActive = true; // Default to active status when the initial due date is invalid
    }
    dueDateController = TextEditingController(text: widget.initialDueDate);
  }

  Future<void> updateProject(String projectId, bool status) async {
    try {

      String title = titleController.text;
      String assignedTo = assignedToController.text;
      String? assignedTeam = assignedTeamController.text;
      String status = statusController.text;
      // Get the required data from the widget's state
      String dueDate = dueDateController.text;
      DateTime parsedDueDate = DateTime.parse(dueDate);
      DateTime dueDateUtc = parsedDueDate.toUtc();


      // Call the static method from ProjectApi to update the project
      String message = await UpdateApiServices.updateProject(projectId, title, assignedTo, assignedTeam, status,  dueDateUtc.toIso8601String(), users, teams,);

      // Show a dialog to inform the user about the successful update
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Changes Saved'),
            content: Text('Your changes have been updated successfully.\n$message'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context,true); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error updating project: $e');
      // Show an error dialog to inform the user about the update failure
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('$e'),
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
      assignedTeamController.text = selectedTeamsText.join(', ');
    }
  }
  void _showMembersDropdown(BuildContext context,List<String> selectedMembers) async {
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
      setState(() {
        _selectedMembers = selectedUserIds;
      });

      List<String> selectedMembersText = _selectedMembers
          .map((id) => allUsers.firstWhere((user) => user.userId == id).userName.toString())
          .toList();
      assignedToController.text = selectedMembersText.join(', ');
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    assignedToController.dispose();
    assignedTeamController.dispose();
    statusController.dispose();
    dueDateController.dispose();
    super.dispose();
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

  @override
  @override
  Widget build(BuildContext context) {
    final projectId = widget.projectId;
    print("Id: $projectId");
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Project'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(fontSize: 12, color: AppColors.grayColor),
                ),
              ),
              TextField(
                controller: assignedToController,
                decoration: InputDecoration(
                  labelText: 'Assigned To',
                  labelStyle: TextStyle(fontSize: 12, color: AppColors.grayColor),
                ),
                onTap: (){
                  temporarySelectedMembers = List<User>.from(_selectedMembers);
                  _showMembersDropdown(context,_selectedMembers);
                },
              ),
              Visibility(
                visible: widget.initialAssignedTeam != null && widget.initialAssignedTeam!.isNotEmpty,
                child: TextField(
                  controller: assignedTeamController,
                  decoration: InputDecoration(
                    labelText: 'Assigned Team',
                    labelStyle: TextStyle(fontSize: 12, color: AppColors.grayColor),
                  ),
                  enabled: widget.initialAssignedTeam != null && widget.initialAssignedTeam!.isNotEmpty,
                  onTap:(){
                    temporarySelectedTeams = List<Team>.from(_selectedTeams);
                    widget.initialAssignedTeam != null && widget.initialAssignedTeam!.isNotEmpty ? _showTeamsDropdown(context) : null;
                  }
                ),
              ),
              TextField(
                controller: statusController,
                decoration: InputDecoration(
                  labelText: 'Status',
                  labelStyle: TextStyle(fontSize: 12, color: AppColors.grayColor),
                ),
              ),
              GestureDetector(
                onTap: _selectDueDate,
                child: AbsorbPointer(
                  child: TextField(
                    controller: dueDateController,
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      labelStyle: TextStyle(fontSize: 12, color: AppColors.grayColor),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                height: 30,
                width: 60,
                child: RoundButton(
                  title: "Save Changes",
                  onPressed: () {
                    updateProject(projectId, isActive); // Pass the isActive variable as the status value
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
