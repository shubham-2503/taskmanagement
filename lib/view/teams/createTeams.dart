import 'dart:convert';
import 'package:Taskapp/View_model/api_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/round_button.dart';
import '../../common_widgets/round_textfield.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';

class Team {
  String teamName;
  List<String> teamMembers;
  DateTime createdOn;

  Team({
    required this.teamName,
    required this.teamMembers,
    required this.createdOn,
  });
}

class TeamCreationPage extends StatefulWidget {
  @override
  _TeamCreationPageState createState() => _TeamCreationPageState();
}

class _TeamCreationPageState extends State<TeamCreationPage> {
  ApiRepo apiRepo = ApiRepo();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _teamNameController;
  List<User> users = [];
  List<String> _selectedMembers = [];
  TextEditingController _assigneeMembersController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _teamNameController = TextEditingController();
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
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

  Future<void> _createTeam() async {
    if (_formKey.currentState!.validate()) {
      Team newTeam = Team(
        teamName: _teamNameController.text,
        teamMembers: _selectedMembers,
        createdOn: DateTime.now(),
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      try {
        // API endpoint and payload
        final apiUrl = 'http://43.205.97.189:8000/api/Team/team';
        final headers = {
          'accept': '*/*',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $storedData',
        };
        final body = jsonEncode({
          "name": newTeam.teamName,
          "user_id": newTeam.teamMembers,
        });

        final response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);

        print("Response: ${response.body}");
        print("StatusCode: ${response.statusCode}");

        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Team Created'),
                content: Text('Team "${newTeam.teamName}" has been created successfully.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      _resetForm();
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('An error occurred while creating the team.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _teamNameController.clear();
    _selectedMembers.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"), // Replace with your background image
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 80),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Create Team',
                      style: TextStyle(
                        color: AppColors.secondaryColor2,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 30,),
                  RoundTextField(
                    hintText: "Team Name",
                    icon: "assets/images/title.jpeg",
                    onChanged: (value) {
                      setState(() {
                        _teamNameController.text = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a team name.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20,),
                  RoundTextField(
                    hintText: "Members",
                    icon: "assets/images/pers.png",
                    textInputType: TextInputType.text,
                    onTap: _showMembersDialog,
                    textEditingController: _assigneeMembersController,
                  ),
                  SizedBox(height: 25.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        height: 40,
                        width: 100,
                        child: RoundButton(
                          title: "Create\nTeam",
                          onPressed: _createTeam,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      SizedBox(
                        height: 40,
                        width: 100,
                        child: RoundButton(
                          title: "Reset",
                          onPressed: _resetForm,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
