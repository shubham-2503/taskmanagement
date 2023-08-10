import 'dart:convert';
import 'package:Taskapp/common_widgets/round_textfield.dart';
import 'package:http/http.dart' as http;
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/fetch_user_model.dart';
import '../../utils/app_colors.dart';

class EditTeamPage extends StatefulWidget {
  final String teamId;
  final String? name;
  final List<String>? users;

  EditTeamPage({required this.teamId, this.name, this.users});

  @override
  _EditTeamPageState createState() => _EditTeamPageState();
}

class _EditTeamPageState extends State<EditTeamPage> {
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _userController = TextEditingController();
  List<User> users =[];
  List<String> _selectedMembers = [];
  TextEditingController _assigneeMembersController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _userController = TextEditingController(text: widget.users!.join(', '));
    _assigneeMembersController = TextEditingController();
    fetchUsers();
  }

  void dispose(){
    super.dispose();
    _assigneeMembersController.dispose();
    _nameController.dispose();
    _userController.dispose();
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
                                  if (!_selectedMembers.contains(user.userId)) {
                                    _selectedMembers.add(user.userId);
                                  }
                                } else {
                                  if (_selectedMembers.contains(user.userId)) {
                                    _selectedMembers.remove(user.userId);
                                  }
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
                          .map((id) => users.firstWhere((user) => user.userId == id).userName)
                          .toList();

                      // Append the new members to the existing members in the text field
                      String existingMembersText = _userController.text.trim();
                      if (existingMembersText.isNotEmpty) {
                        existingMembersText += ', ';
                      }
                      _userController.text = existingMembersText + selectedMembersText.join(', ');
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateTeamData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('jwtToken');
      String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

      if (orgId == null) {
        // If the user hasn't switched organizations, use the organization ID obtained during login time
        orgId = prefs.getString('org_id') ?? "";
      }

      print("OrgId: $orgId");


      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      if (storedToken == null || storedToken.isEmpty) {
        // Handle the case when storedToken is null or empty
        print('Stored token is null or empty. Cannot make API request.');
        return;
      }

      final url = 'http://43.205.97.189:8000/api/Team/team?team_id=${widget.teamId}&org_id=$orgId';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $storedToken',
      };
      final body = jsonEncode({
        'name': _nameController.text.trim(),
        'users': _userController.text.split(',').map((user) => user.trim()).toList(),
      });

      final response = await http.patch(Uri.parse(url), headers: headers, body: body);

      print("Response: ${response.body}");
      print("Statuscode: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Team data updated successfully
        _showUpdatedDialog();
      } else {
        // Handle errors, e.g., display an error message to the user
        print('Failed to update team data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle errors, e.g., display an error message to the user
      print('Error updating team data: $e');
    }
  }

  void _showUpdatedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Changes Saved'),
          content: Text('Your changes has been updated successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Team",style: TextStyle(
                color:
                AppColors.secondaryColor2,
                fontSize: 14,
                fontWeight: FontWeight.bold),),
            SizedBox(height: 8),
            RoundTextField(hintText: "Team Name",textEditingController: _nameController,),
            SizedBox(height: 16),
            Text("Members",style: TextStyle(
                color:
                AppColors.secondaryColor2,
                fontSize: 14,
                fontWeight: FontWeight.bold),),
            SizedBox(height: 8),
            RoundTextField(hintText: "Users",textEditingController: _userController,onTap: _showMembersDialog, ),
            SizedBox(height: 30),
            Center(
              child: SizedBox(
                  height: 50,
                  width: 150,
                  child: RoundButton(title: "Save Changes", onPressed: _updateTeamData)),
            ),
          ],
        ),
      ),
    );
  }
}
