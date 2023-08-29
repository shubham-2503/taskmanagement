import 'dart:convert';

import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/fetch_user_model.dart';
import '../models/task_model.dart';
import '../models/teams.dart';

class AddMembersAndTeamsModal extends StatefulWidget {
  final Task task; // Declare the task property
  AddMembersAndTeamsModal({required this.task});

  @override
  _AddMembersAndTeamsModalState createState() => _AddMembersAndTeamsModalState();
}

class _AddMembersAndTeamsModalState extends State<AddMembersAndTeamsModal> {
  List<User> selectedUsers = [];
  List<MyTeam> selectedTeams = [];
  List<User> users = []; // Store fetched users here
  List<MyTeam> teams = [];

  Future<void> updateTask(String taskId, List<String> selectedUserIds, List<String> selectedTeamIds) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      List<String> selectedUserIds = selectedUsers.map((user) => user.userId!).toList();
      List<String> selectedTeamIds = selectedTeams.map((team) => team.teamId!).toList();

      print("$selectedTeamIds");
      print("$selectedUserIds");

      // Construct the request body using provided or existing data
      Map<String, dynamic> requestBody = {
        'id': taskId,
        'assigned_users': selectedUserIds,
        'assigned_teams': selectedTeamIds,
      };

      final response = await http.patch(
        Uri.parse('http://43.205.97.189:8000/api/Task/editTasks'),
        headers: {
          'accept': 'application/json', // Accept JSON response
          'Authorization': 'Bearer $storedData',
          'Content-Type': 'application/json', // Set content type to JSON
        },
        body: jsonEncode(requestBody),
      );

      print("DecodedBody: $requestBody");
      print("StatusCode: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        print('Task updated successfully');
      } else {
        print('Failed to update task');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchMyTeams() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId = prefs.getString("selectedOrgId");

      if (orgId == null) {
        orgId = prefs.getString('org_id') ?? "";
      }

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      final response = await http.get(
        Uri.parse('http://43.205.97.189:8000/api/Team/teamUsers?org_id=$orgId'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final List<MyTeam> fetchedTeams = responseData.map((teamJson) {
          return MyTeam.fromJson(teamJson as Map<String, dynamic>);
        }).toList();

        final List<String> assignedTeamNames = widget.task.assignedTeam ?? [];

        print("Assigned Team Names: $assignedTeamNames");

        List<MyTeam> filteredTeams = fetchedTeams
            .where((team) => !assignedTeamNames.contains(team.teamName))
            .toList();

        setState(() {
          teams = filteredTeams; // Update the 'teams' list with filtered data
        });
      } else {
        print('Failed to fetch teams');
        throw Exception('Failed to fetch teams');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch teams');
    }
  }

  Future<void> fetchUsers() async {
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
          final List<User> fetchedUsers =
          data.map((userJson) => User.fromJson(userJson)).toList();

          final List<String> assignedToNames = widget.task.assignedTo ?? [];

          print("Assigned Team Names: $assignedToNames");

          List<User> filteredUsers = fetchedUsers
              .where((user) => !assignedToNames.contains(user.userName))
              .toList();


          setState(() {
            users = filteredUsers; // Update the 'users' list with fetched data
          });

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

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await fetchUsers(); // Fetch users and update the 'users' list
      await fetchMyTeams(); // Fetch teams and update the 'teams' list

      setState(() {
        selectedUsers = users.where((user) => widget.task.assignedTo!.contains(user.userId)).toList();
        selectedTeams = teams.where((team) => widget.task.assignedTeam!.contains(team.teamId)).toList();
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Select Users:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor2
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Wrap(
              children: users.map((user) {
                final isSelected = selectedUsers.contains(user);
                return ListTile(
                  title: Text(
                    user.userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor2,
                    ),
                  ),
                  trailing: GestureDetector(
                    child: Icon(
                      isSelected ? Icons.remove_circle : Icons.add_circle,
                      color: isSelected ? AppColors.primaryColor2 : AppColors.secondaryColor2,
                    ),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedUsers.remove(user);
                        } else {
                          selectedUsers.add(user);
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Select Teams:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor2
                ),
              ),
            ),
            Wrap(
              children: teams.map((team) {
                final isSelected = selectedTeams.contains(team);
                return ListTile(
                  title: Text(team.teamName, style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor2
                  ),),
                  trailing: GestureDetector(
                    child: Icon(
                      isSelected ? Icons.remove_circle : Icons.add_circle,
                      color: isSelected ? AppColors.primaryColor2 : AppColors.secondaryColor2,
                    ),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedTeams.remove(team);
                        } else {
                          selectedTeams.add(team);
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 150,
                child: RoundButton(
                  title: "Add",
                  onPressed: () async {
                    List<String> selectedUserIds = selectedUsers.map((user) => user.userId).toList();
                    List<String> selectedTeamIds = selectedTeams.map((team) => team.teamId!).toList();

                    // Prepare the request body
                    Map<String, dynamic> requestBody = {
                      'id': widget.task.taskId, // Update with the appropriate field name for the task ID
                      'assigned_users': selectedUserIds,
                      'assigned_teams': selectedTeamIds,
                    };

                    print("TaskIds: ${widget.task.taskId}");
                    // Make the API call to update the task
                    await updateTask(widget.task.taskId!, selectedUserIds, selectedTeamIds);

                    // Close the modal
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

