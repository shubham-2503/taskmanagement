import 'dart:convert';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/common_widgets/round_textfield.dart';
import 'package:Taskapp/view/teams/editTeam.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/fetch_user_model.dart';
import '../../models/teams.dart';
import '../../utils/app_colors.dart';
import 'createTeams.dart';

class TeamsFormedScreen extends StatefulWidget {
  @override
  State<TeamsFormedScreen> createState() => _TeamsFormedScreenState();
}

class _TeamsFormedScreenState extends State<TeamsFormedScreen> {
  late List<MyTeam> _teams = [];
  List<User> _selectedUsers = [];
  late List<MyTeam> filteredTeams = [];


  void initState() {
    super.initState();
    fetchMyTeams();
    filteredTeams = _teams;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<String>> fetchUserNames() async {
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

      if (storedData == null || storedData.isEmpty) {
        print('Stored token is null or empty. Cannot make API request.');
        throw Exception('Failed to fetch user names: Stored token is null or empty.');
      }

      final response = await http.get(
        Uri.parse('http://43.205.97.189:8000/api/UserAuth/getOrgUsers?org_id=$orgId'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<String> userNames = data
            .map((userJson) => userJson['userName'] as String? ?? "")
            .toList();
        return userNames;
      } else {
        print('Failed to fetch user names: StatusCode: ${response.statusCode}');
        throw Exception('Failed to fetch user names');
      }
    } catch (e) {
      print('Error fetching user names: $e');
      throw Exception('Failed to fetch user names');
    }
  }

  Future<void> fetchMyTeams() async {
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
        final List<MyTeam> teams = responseData.map((teamJson) {
          return MyTeam.fromJson(teamJson as Map<String, dynamic>);
        }).toList();

        // Print the team names and users for testing
        for (MyTeam team in teams) {
          print('Team Name: ${team.teamName}');
          print('Users: ${team.users}');
          print('Total Members: ${team.users!.length}');
        }

        setState(() {
          _teams = teams; // Update the _teams list with the fetched data
          filteredTeams = List.from(_teams); // Set _filteredTeams to a copy of _teams
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

  Future<void> updateTeamWithMembers(String teamId,List<String> userIds,) async {
    try {
      print("TeamIds: $teamId");
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

      // Prepare the data for the request
      final Map<String, dynamic> requestBody = {
        "user_id": userIds,
      };

      final response = await http.patch(
        Uri.parse("http://43.205.97.189:8000/api/Team/team/$teamId?org_id=$orgId"),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print("API response: ${response.body}");
      print("StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        print('Team updated successfully with new members.');
        String message = "Team updated successfully with new members";
        _showDialog(message);
        // After successful update, fetch the latest teams data
        await fetchMyTeams();
      } else {
        print('Failed to update team with new members.');
        String message = "Failed to update team with new members.";
        _showDialog(message);
      }
    } catch (e) {
      print('Error updating team with new members and name: $e');
      String message = "Error updating team with new members: $e";
      _showDialog(message);
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Ok"),
          ),
        ],
      ),
    );
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

  void filterTeams(String query) {
    setState(() {
      if (query.length >= 3) {
        print("Filtering with query: $query");
        filteredTeams = _teams.where((team) =>
            team.teamName.toLowerCase().contains(query.toLowerCase())).toList();
      } else {
        // Filter with an empty query or a query with less than 3 characters
        filteredTeams = _teams.toList();
      }
    });
  }

  void _deleteTeam(String teamId,int index) async {
    try {
      // Show a confirmation dialog for deleting the task
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this team?'),
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
                    String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

                    if (orgId == null) {
                      // If the user hasn't switched organizations, use the organization ID obtained during login time
                      orgId = prefs.getString('org_id') ?? "";
                    }

                    print("OrgId: $orgId");


                    if (orgId == null) {
                      throw Exception('orgId not found locally');
                    }

                    final response = await http.delete(
                      Uri.parse('http://43.205.97.189:8000/api/Team/team/$teamId?org_id=$orgId'),
                      headers: {
                        'accept': '*/*',
                        'Authorization': "Bearer $storedData",
                      },
                    );

                    print("Delete API response: ${response.body}");
                    print("Delete StatusCode: ${response.statusCode}");

                    if (response.statusCode == 200) {

                      _teams.removeWhere((team) => team.teamId == teamId);
                      setState(() {});

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Thank You'),
                            content: Text("Team deleted successfully."),
                            actions: [
                              InkWell(
                                  onTap: () async {
                                    Navigator.pop(context,true);
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
                      /* setState(() {
                        // Remove the deleted team from the list
                        _teams.removeWhere((team) => team.teamId == teamId);
                      });*/
                    } else {
                      print('Failed to delete team.');
                      // Handle other status codes, if needed
                    }
                  } catch (e) {
                    print('Error deleting task: $e');
                  }
                },
                child: Text('Delete'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error showing delete confirmation dialog: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('My Teams',style:TextStyle(fontSize:19)),
        ],
      ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(height: 50,width: 150,child:  RoundTextField(
              onChanged: (query) => filterTeams(query), hintText: 'Search',
              icon: "assets/images/search_icon.png",
            ),),
          )
        ],),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _teams.length, // Use _filteredTeams here
                  itemBuilder: (context, index) {
                    MyTeam team = _teams[index];
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 2),
                          padding: EdgeInsets.symmetric(
                              vertical: 8, horizontal: 9),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                AppColors.primaryColor2.withOpacity(0.3),
                                AppColors.primaryColor1.withOpacity(0.3)
                              ]),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 150,
                                        child: Text(
                                          team.teamName.length >30
                                              ? team.teamName.substring(0,30) + '...'
                                              : team.teamName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: AppColors.secondaryColor2,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'No. of Members: ',
                                            style: TextStyle(
                                                color: AppColors
                                                    .blackColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight
                                                    .bold),
                                          ),
                                          Text(
                                            team.users!.length.toString(),
                                            style: TextStyle(
                                                color:
                                                AppColors.secondaryColor2,
                                                fontSize: 14,
                                                fontWeight: FontWeight
                                                    .bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 30,
                          right: 8,
                          child: Column(
                            children: [
                              Row(children: [
                                IconButton(
                                    onPressed: () async {
                                      _showViewTeamDialog(team); // Pass both team and userNames
                                    },
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      color: AppColors.secondaryColor2,
                                    )),
                                IconButton(
                                  onPressed: () async {
                                    bool? changesMade = await showModalBottomSheet<bool>(
                                      context: context,
                                      builder: (context) {
                                        return EditTeamPage(team: team,);
                                      },
                                    );

                                    // If changes were made, fetch teams again
                                    if (changesMade == true) {
                                      await fetchMyTeams();
                                    }
                                  },
                                  icon: Icon(Icons.edit, color: AppColors.secondaryColor2),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: AppColors.secondaryColor2,
                                  ),
                                  onPressed: () {
                                    _deleteTeam(team.teamId!,index);
                                  },
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ],
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
          _navigateToCreateTeamScreen();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<List<String>> fetchTeamUserIds() async {
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

    final response = await http.get(
      Uri.parse('http://43.205.97.189:8000/api/Team/teamUsers?org_id=$orgId'),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      },
    );


    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> users = jsonData['users'];
      return users.map((user) => user['user_id']).cast<String>().toList();
    } else {
      throw Exception('Failed to fetch team users');
    }
  }

  String findUserIdByUserName(String userName) {
    User? user = _selectedUsers.firstWhere((user) => user.userName == userName,);
    return user?.userId ?? '';
  }

  void _navigateToCreateTeamScreen() async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TeamCreationPage()),
    );

    if (shouldRefresh == true) {
      // Refresh the data by calling the fetchMyTeams API
      fetchMyTeams();
    }
  }

  Future<String> getUserIdByUsername(String username) async {
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

  void _showViewTeamDialog(MyTeam team) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display the current team name
                Center(
                  child: Text(
                    '${team.teamName}',
                    style: TextStyle(
                        color: AppColors.secondaryColor2,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16),
                // Display the current team members
                Text(
                  'Team Members:',
                  style: TextStyle(
                      color: AppColors.primaryColor2,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                ...team.users!.map((user) => ListTile(
                  title: Text(
                    user,
                    style: TextStyle(
                        color: AppColors.primaryColor2,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}
