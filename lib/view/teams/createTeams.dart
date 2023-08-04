import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_widgets/round_button.dart';
import '../../common_widgets/round_textfield.dart';
import '../../models/fetch_user_model.dart';
import '../../models/project_team_model.dart';
import '../../utils/app_colors.dart';

class TeamCreationPage extends StatefulWidget {
  @override
  _TeamCreationPageState createState() => _TeamCreationPageState();
}

class _TeamCreationPageState extends State<TeamCreationPage> {
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      final String? orgId = prefs.getString('org_id');

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      print("OrgId: $orgId");

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

  Future<List<Team>> fetchTeams() async {
    List<Team> teams = [];
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      final String? orgId = prefs.getString('org_id');

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      print("OrgId: $orgId");

      final response = await http.get(
        Uri.parse('http://43.205.97.189:8000/api/Team/teamUser?orgId=$orgId'), // Update the API endpoint URL
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
        id: "",
        teamName: _teamNameController.text,
        users: _selectedMembers,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      final String? orgId = prefs.getString('selectedOrgId');
      print("OrgId: $orgId");

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      print("OrgId: $orgId");

      try {
        // API endpoint and payload
        final apiUrl = 'http://43.205.97.189:8000/api/Team/team?orgId=$orgId';
        final headers = {
          'accept': '*/*',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $storedData',
        };
        final body = jsonEncode({
          "name": newTeam.teamName,
          "user_id": newTeam.users,
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
                      Navigator.pop(context);
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
