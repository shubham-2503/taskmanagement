import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fetch_user_model.dart';
import '../models/project_team_model.dart';
import '../utils/app_colors.dart';
import 'package:http/http.dart' as http;

List<User> _selectedUsers = [];

void showViewMembersDialog(BuildContext context, String assignedToUsers, String assignedTeam,String taskId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display the "Assigned To" users
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assigned To User:',
                    style: TextStyle(
                      color: AppColors.secondaryColor2,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(onPressed: (){
                    _showUserListBottomSheet(context, taskId);
                  }, icon: Icon(Icons.add_circle,color: AppColors.secondaryColor2,))
                ],
              ),
              ListTile(
                title: InkWell(
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Wrap(
                        spacing: 4,
                        children: assignedToUsers.isNotEmpty
                            ? [
                          for (var userName in assignedToUsers.split(','))
                            FutureBuilder<String>(
                              future: getUserIdByUsername(userName.trim()),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  String userId = snapshot.data ?? '';
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Chip(
                                      label: Text(
                                        userName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.secondaryColor2,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      deleteIcon: Icon(Icons.clear, size: 10),
                                      onDeleted: () {
                                        _deleteUser(context, taskId, userId);
                                      },
                                    ),
                                  );
                                }
                              },
                            ),
                        ]
                            : [],// Show the selected priority name chip when priorityController is not empty
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              if (assignedTeam.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assigned Team:',
                      style: TextStyle(
                        color: AppColors.secondaryColor2,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListTile(
                      title: InkWell(
                        onTap: () {},
                        child:  Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Wrap(
                              spacing: 4,
                              children: assignedToUsers.isNotEmpty
                                  ? [
                                for (var teamName in assignedTeam.split(','))
                                  FutureBuilder<String>(
                                    future: getUserIdByUsername(teamName.trim()),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        String teamId = snapshot.data ?? '';
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Chip(
                                            label: Text(
                                              teamName,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.secondaryColor2,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            deleteIcon: Icon(Icons.clear, size: 10),
                                            onDeleted: () {
                                              _deleteTeam(context, taskId, teamId);
                                            },
                                          ),
                                        );
                                      }
                                    },
                                  ),
                              ]
                                  : [],// Show the selected priority name chip when priorityController is not empty
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    },
  );
}

String findTeamIdByTeamName(List<Team> teams, String teamName) {
  Team? team = teams.firstWhere((team) => team.teamName == teamName,);
  return team?.id ?? '';
}

Future<List<Team>> fetchMyTeams() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');
    final String? orgId = prefs.getString('selectedOrgId');

    if (orgId == null) {
      throw Exception('orgId not found locally');
    }

    print("OrgId: $orgId");

    final response = await http.get(
      Uri.parse('http://43.205.97.189:8000/api/Team/teamUsers?org_id=$orgId'),
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
      final List<Team> teams = responseData.map((teamJson) {
        return Team.fromJson(teamJson as Map<String, dynamic>);
      }).toList();

      return teams;
    }

    print('Failed to fetch teams');
    throw Exception('Failed to fetch teams');
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to fetch teams');
  }
}

String findUserIdByUserName(String userName) {
  User? user = _selectedUsers.firstWhere((user) => user.userName == userName,);
  return user?.userId ?? '';
}


Future<String> getUserIdByUsername(String username) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');
    final String? orgId = prefs.getString('selectedOrgId');

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

    print('API Response: ${response.body}');
    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> users = jsonDecode(response.body);
      final user = users.firstWhere(
            (user) => user['name'].toLowerCase() == username.toLowerCase(),
        orElse: () => null,
      );

      if (user != null) {
        final String userId = user['id'];
        return userId;
      } else {
        // User not found with the given username
        throw Exception('User not found');
      }
    } else {
      // Failed to fetch users from the API
      throw Exception('Failed to fetch users');
    }
  } catch (e) {
    // Handle any exceptions that may occur during the API call
    print('Error: $e');
    throw Exception('Failed to get userId by username');
  }
}

Future<List<User>> fetchUsers() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');
    final String? orgId = prefs.getString('selectedOrgId');

    if (orgId == null) {
      throw Exception('orgId not found locally');
    }

    print("OrgId: $orgId");

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
        final List<User> users =
        data.map((userJson) => User.fromJson(userJson)).toList();

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

void _showUserListBottomSheet(BuildContext context,String taskId) async {

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return FutureBuilder<List<User>>(
            future: fetchUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                List<User> userList = snapshot.data ?? [];
                return Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select User',
                        style: TextStyle(
                          color: AppColors.secondaryColor2,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: userList.length,
                          itemBuilder: (context, index) {
                            User user = userList[index];
                            bool isSelected = _selectedUsers.contains(user);
                            return ListTile(
                              title: Text(
                                user.userName,
                                style: TextStyle(
                                  color: AppColors.primaryColor2,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  isSelected
                                      ? Icons.remove_circle
                                      : Icons.add_circle,
                                  color: AppColors.secondaryColor2,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedUsers.remove(user);
                                    } else {
                                      _selectedUsers.add(user);
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      // Display the selected users
                      if (_selectedUsers.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.secondaryColor2,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Users:',
                                style: TextStyle(
                                  color: AppColors.secondaryColor2,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: _selectedUsers.map((user) {
                                  return Chip(
                                    label: Text(user.userName),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedUsers.remove(user);
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      );
    },
  );
}


void _deleteUser(BuildContext context,String taskId,String userId) async {
  print("taskId: $taskId");
  print("UserId: $userId");
  try {
    // Show a confirmation dialog for deleting the task
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this task User?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  final storedData = prefs.getString('jwtToken');
                  final String? orgId = prefs.getString('selectedOrgId');

                  if (orgId == null) {
                    throw Exception('orgId not found locally');
                  }

                  print("OrgId: $orgId");

                  final response = await http.delete(
                    Uri.parse('http://43.205.97.189:8000/api/Task/deleteTaskUser?task_id=$taskId&user_id=$userId'),
                    headers: {
                      'accept': '*/*',
                      'Authorization': "Bearer $storedData",
                    },
                  );

                  print("Delete API response: ${response.body}");
                  print("Delete StatusCode: ${response.statusCode}");

                  if (response.statusCode == 200) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Thank You'),
                          content: Text("User deleted successfully."),
                          actions: [
                            InkWell(
                                onTap: () async {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "OK",
                                  style: TextStyle(
                                      color: AppColors.blackColor,
                                      fontSize: 20),
                                ))
                          ],
                        );
                      },
                    );
                    print('User deleted successfully.');
                    // Perform any necessary tasks after successful deletion
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('OOPs'),
                          content: Text("Failed to delete User."),
                          actions: [
                            InkWell(
                                onTap: () async {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "OK",
                                  style: TextStyle(
                                      color: AppColors.blackColor,
                                      fontSize: 20),
                                ))
                          ],
                        );
                      },
                    );
                    print('Failed to delete User.${response.statusCode}');
                    // Handle other status codes, if needed
                  }
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('OOPs'),
                        content: Text("Error deleting User: $e"),
                        actions: [
                          InkWell(
                              onTap: () async {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text(
                                "OK",
                                style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 20),
                              ))
                        ],
                      );
                    },
                  );
                  print('Error deleting User: $e');
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('OOPs'),
          content: Text("Error showing delete confirmation dialog: $e"),
          actions: [
            InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  "OK",
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 20),
                ))
          ],
        );
      },
    );
    print('Error showing delete confirmation dialog: $e');
  }
}

void _deleteTeam(BuildContext context,String taskId,String teamId) async {
  print("taskId: $taskId");
  print("teamId: $teamId");
  try {
    // Show a confirmation dialog for deleting the task
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this task User?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  final storedData = prefs.getString('jwtToken');
                  final String? orgId = prefs.getString('selectedOrgId');

                  if (orgId == null) {
                    throw Exception('orgId not found locally');
                  }

                  print("OrgId: $orgId");

                  final response = await http.delete(
                    Uri.parse('http://43.205.97.189:8000/api/Task/deleteTaskTeam?task_id=$taskId&team_id_id=$teamId'),
                    headers: {
                      'accept': '*/*',
                      'Authorization': "Bearer $storedData",
                    },
                  );

                  print("Delete API response: ${response.body}");
                  print("Delete StatusCode: ${response.statusCode}");

                  if (response.statusCode == 200) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Thank You'),
                          content: Text("Team deleted successfully."),
                          actions: [
                            InkWell(
                                onTap: () async {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "OK",
                                  style: TextStyle(
                                      color: AppColors.blackColor,
                                      fontSize: 20),
                                ))
                          ],
                        );
                      },
                    );
                    print('Team deleted successfully.');
                    // Perform any necessary tasks after successful deletion
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('OOPs'),
                          content: Text("Failed to delete Team."),
                          actions: [
                            InkWell(
                                onTap: () async {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "OK",
                                  style: TextStyle(
                                      color: AppColors.blackColor,
                                      fontSize: 20),
                                ))
                          ],
                        );
                      },
                    );
                    print('Failed to delete Team.${response.statusCode}');
                    // Handle other status codes, if needed
                  }
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('OOPs'),
                        content: Text("Error deleting Team: $e"),
                        actions: [
                          InkWell(
                              onTap: () async {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text(
                                "OK",
                                style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 20),
                              ))
                        ],
                      );
                    },
                  );
                  print('Error deleting Team: $e');
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('OOPs'),
          content: Text("Error showing delete confirmation dialog: $e"),
          actions: [
            InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  "OK",
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 20),
                ))
          ],
        );
      },
    );
    print('Error showing delete confirmation dialog: $e');
  }
}

