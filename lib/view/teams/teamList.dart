import 'dart:convert';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../models/teams.dart';
import '../../models/user.dart';
import 'createTeams.dart';

class TeamsFormedScreen extends StatefulWidget {
  @override
  State<TeamsFormedScreen> createState() => _TeamsFormedScreenState();
}

class _TeamsFormedScreenState extends State<TeamsFormedScreen> {
  final List<MyTeam> _teams = [];
  List<User> users =[];
  List<String> _selectedMembers = [];
  TextEditingController _assigneeMembersController = TextEditingController();

  @override
  void dispose(){
    _assigneeMembersController.dispose();
    super.dispose();
  }

  Future<List<MyTeam>> fetchMyTeams() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      final response = await http.get(
        Uri.parse('http://43.205.97.189:8000/api/Team/teamUsers'), // Update the API endpoint URL
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
        },
      );

      print("Stored: $storedData");
      print("API response: ${response.body}");
      print("StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final List<MyTeam> teams = responseData.map((teamJson) {
          return MyTeam.fromJson(teamJson as Map<String, dynamic>);
        }).toList();

        // Print the team names and users for testing
        for (MyTeam team in teams) {
          print('Team Name: ${team.teamName}');
          print('Users: ${team.users}');
        }

        return teams;
      }

      print('Failed to fetch teams');
      throw Exception('Failed to fetch teams');
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch teams');
    }
  }

  Future<void> editTeam(String teamId, String updatedMembers) async {
    final apiUrl = 'http://43.205.97.189:8000/api/Team/team/$teamId';

    final requestBody = {
      "teamId": teamId,
      "users": updatedMembers.split(',').map((member) => member.trim()).toList(),
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    final http.Response response = await http.patch(
      Uri.parse(apiUrl),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print("Stored: $token");
    print("API response: ${response.body}");
    print("StatusCode: ${response.statusCode}");
    if (response.statusCode == 200) {
      // Team updated successfully
      print('Team updated successfully');

      // Update the local team list with the modified team
      setState(() {
        final List<String> updatedUsers = (requestBody['users'] as List<dynamic>).cast<String>();
        final int teamIndex = _teams.indexWhere((team) => team.teamId == teamId);
        final MyTeam updatedTeam = MyTeam(
          teamId: teamId,
          teamName: _teams[teamIndex].teamName,
          users: updatedUsers,
        );

        if (teamIndex != -1) {
          _teams[teamIndex] = updatedTeam;
        }
      });
    } else {
      // Failed to update team
      print('Failed to update team: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MyTeam>>(
      future: fetchMyTeams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          _teams.clear();
          _teams.addAll(snapshot.data ?? []);
          return Scaffold(
            appBar: AppBar(
            ),
            body: Container(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'My Teams',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _teams.length,
                        itemBuilder: (context, index) {
                          MyTeam team = _teams[index];
                          return Card(
                            child: ListTile(
                              title: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Text(
                                      "Team Name: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(team.teamName),
                                  ],
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Members: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(team.users.join(", ")), // Join team members with commas
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      // Handle edit button pressed for the team
                                      // Perform necessary actions, such as opening a dialog box with editable members
                                      final TextEditingController _assigneeMembersController = TextEditingController(text: _teams[index].users.join(', '));
                                      // Add this variable before the showDialog function
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Edit Team'),
                                            content: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('Team: ${_teams[index].teamName}'),
                                                SizedBox(height: 16),
                                                Text('Members:'),
                                                TextFormField(
                                                  decoration: InputDecoration(
                                                    hintText: "Assignee Members",
                                                    prefixIcon: Image.asset("assets/images/pers.png",width: 2,height: 2,),
                                                  ),
                                                  onTap: _showMembersDialog,
                                                  controller: _assigneeMembersController,
                                                )
                                              ],
                                            ),
                                            actions: [
                                              SizedBox(
                                                height: 40,
                                                width: 90,
                                                child: RoundButton(title: "Cancel", onPressed: () {
                                                  Navigator.of(context).pop();
                                                }),
                                              ),
                                              SizedBox(
                                                height: 40,
                                                width: 70,
                                                child: RoundButton(title: "Save", onPressed: () {
                                                  String updatedMembers = _assigneeMembersController.text;
                                                  // Perform necessary actions, such as saving the changes to the server
                                                  editTeam(team.teamId, updatedMembers);
                                                  Navigator.of(context).pop();
                                                }),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      // Handle delete button pressed for the team
                                      // Perform necessary actions, such as showing a confirmation dialog and deleting the team
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // Add your logic for the floating action button here
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeamCreationPage()),
                );
              },
              child: Icon(Icons.add),
            ),
          );
        }
      },
    );
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
}

