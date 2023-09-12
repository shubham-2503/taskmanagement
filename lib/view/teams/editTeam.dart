import 'dart:convert';
import 'package:Taskapp/common_widgets/round_textfield.dart';
import 'package:Taskapp/models/teams.dart';
import 'package:http/http.dart' as http;
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/fetch_user_model.dart';
import '../../utils/app_colors.dart';

class EditTeamPage extends StatefulWidget {
  final MyTeam team;
  EditTeamPage({required this.team});

  @override
  _EditTeamPageState createState() => _EditTeamPageState();
}

class _EditTeamPageState extends State<EditTeamPage> {
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _usercontroller = TextEditingController();
  late List<MyTeam> _teams = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team.teamName);
    _usercontroller = TextEditingController(
      text: widget.team.users != null ? widget.team.users!.join(", ") : "",
    );
  }

  void dispose(){
    super.dispose();
    _nameController.dispose();
    _usercontroller.dispose();
  }

  Future<void> updateTeamNameAndMembers(String teamId, String newTeamName,List<String> users) async {
    try {
      print("users: $users");
      print("TeamIds: $teamId");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

      if (orgId == null) {
        orgId = prefs.getString('org_id') ?? "";
      }

      print("OrgId: $orgId");


      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      // Prepare the data for the request
      final Map<String, dynamic> requestBody = {
        "name": newTeamName,
        "user_id" : users,
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
      print("Decode Data: $requestBody");

      if (response.statusCode == 200) {
        String message = "Team updated successfully name.";
        _showDialog(message);
        print('Team updated successfully with name.');
      } else {
        String message = "Failed to update team name.";
        _showDialog(message);
        print('Failed to update team name.');
      }
    } catch (e) {
      String message = "Error updating team name: $e";
      _showDialog(message);
      print('Error updating team name: $e');
    }
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

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text("Ok"),
          ),
        ],
      ),
    );
  }

  Future<void> _showMembersDropdown(BuildContext context) async {
    List<User> allUsers = await fetchUsers();
    List<String> selectedMembers = List.from(widget.team.users!);

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Members'),
              content: SingleChildScrollView(
                child: Column(
                  children: allUsers.map((user) {
                    bool isSelected = selectedMembers.contains(user.userName);

                    return ListTile(
                      title: Text(user.userName),
                      trailing: isSelected
                          ? Icon(Icons.remove_circle, color: Colors.red)
                          : Icon(Icons.add_circle, color: Colors.green),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedMembers.remove(user.userName);
                          } else {
                            selectedMembers.add(user.userName);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Done'),
                  onPressed: () {
                    _usercontroller.text = selectedMembers.join(', ');
                    widget.team.users = _usercontroller.text.isNotEmpty ? _usercontroller.text.split(', ') : [];
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Team'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
              SizedBox(height: 8),
              Text("Members",style: TextStyle(
                  color:
                  AppColors.secondaryColor2,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),),
              SizedBox(height: 8),
              RoundTextField(hintText: "Members",textEditingController: _usercontroller,isReadOnly: true,
              onTap: (){
                _showMembersDropdown(context);
              },),
              // SingleChildScrollView(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       ...widget.team.users!.map((user) => ListTile(
              //         title: Text(
              //           user,
              //           style: TextStyle(
              //               color: AppColors.primaryColor2,
              //               fontSize: 14,
              //               fontWeight: FontWeight.bold),
              //         ),
              //         trailing: IconButton(
              //             icon: Icon(
              //               Icons.remove_circle,
              //               color: AppColors.secondaryColor2,
              //             ),
              //             onPressed: () async {
              //               try {
              //                 // Show a confirmation dialog for deleting the task
              //                 showDialog(
              //                   context: context,
              //                   builder: (BuildContext context) {
              //                     return AlertDialog(
              //                       title: Text('Confirm Delete'),
              //                       content: Text('Are you sure you want to delete this User?'),
              //                       actions: [
              //                         TextButton(
              //                           child: Text('Cancel'),
              //                           onPressed: () {
              //                             Navigator.of(context).pop();
              //                           },
              //                         ),
              //                         TextButton(
              //                           onPressed: () async {
              //                             Navigator.of(context).pop();
              //                             try {
              //                               SharedPreferences prefs = await SharedPreferences.getInstance();
              //                               final storedData = prefs.getString('jwtToken');
              //                               String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID
              //
              //                               if (orgId == null) {
              //                                 // If the user hasn't switched organizations, use the organization ID obtained during login time
              //                                 orgId = prefs.getString('org_id') ?? "";
              //                               }
              //
              //                               print("OrgId: $orgId");
              //
              //
              //                               if (orgId == null) {
              //                                 throw Exception('orgId not found locally');
              //                               }
              //
              //                               final String teamId = widget.team.teamId!;
              //                               final String userName = user; // Replace 'user' with the actual userName of the user you want to delete
              //
              //                               final userId = await getUserIdByUsername(user); // Make the userId nullable
              //
              //                               print("Userid: $userId");
              //
              //                               // Get the teamId and userId of the user to delete
              //                               final String apiUrl = "http://43.205.97.189:8000/api/Team/deleteTeamUser?teamId=${widget.team.teamId}&userId=$userId&org_id=$orgId";
              //
              //                               // Prepare the query parameters
              //                               final Map<String, String> queryParams = {
              //                                 "teamId": teamId,
              //                                 "userId":userId,
              //                               };
              //
              //                               print("Body: $queryParams"); // Print the request body to debug
              //
              //                               // Make the HTTP DELETE request
              //                               final response = await http.delete(
              //                                 Uri.parse(apiUrl),
              //                                 headers: {
              //                                   'accept': '*/*',
              //                                   'Authorization': "Bearer $storedData",
              //                                   // Add any necessary authorization or authentication headers here
              //                                 },
              //                                 body: json.encode(queryParams), // Convert the queryParams to JSON
              //                               );
              //
              //                               print("Response Body: ${response.body}");
              //                               print("Statuscode: ${response.statusCode}");
              //
              //                               // Check the response status and handle accordingly
              //                               if (response.statusCode == 200) {
              //                                 // Deletion successful
              //                                 print("User deleted successfully.");
              //                                 _showDialog("User deleted Successfully");
              //
              //                               } else if (response.statusCode == 401) {
              //                                 // Unauthorized
              //                                 print("Unauthorized to perform the delete operation.");
              //                               } else if (response.statusCode == 403) {
              //                                 // Forbidden
              //                                 print("Forbidden to perform the delete operation.");
              //                               } else {
              //                                 // Handle other response status codes if needed
              //                                 print("An error occurred: ${response.statusCode}");
              //                               }
              //                             } catch (e) {
              //                               print("Error: $e");
              //                             }
              //                           },
              //                           child: Text('Delete'),
              //                         ),
              //                       ],
              //                     );
              //                   },
              //                 );
              //               } catch (e) {
              //                 print('Error showing delete confirmation dialog: $e');
              //               }
              //             }
              //         ),
              //       )),
              //       Row(
              //         children: [
              //           IconButton(
              //             icon: Icon(Icons.add_circle, color: AppColors.primaryColor2),
              //             onPressed: () {
              //               _showUserSelectionModal(widget.team);
              //             },
              //           ),
              //           Text("Add Members",
              //             style: TextStyle(
              //                 color: AppColors.secondaryColor2,
              //                 fontSize: 12,
              //                 fontWeight: FontWeight.bold),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(height: 20,),
              Center(
                child: SizedBox(
                    height: 50,
                    width: 150,
                    child: RoundButton(title: "Save Changes", onPressed: ()async{
                      List<String> usernames = _usercontroller.text.split(', ');

                      // Convert usernames to user IDs
                      List<String> userIds = [];
                      for (String username in usernames) {
                        String userId = await getUserIdByUsername(username);
                        userIds.add(userId);
                      }

                      print("User IDs: $userIds");
                      String newTeamName = _nameController.text;
                      await updateTeamNameAndMembers(widget.team.teamId!, newTeamName,userIds);
                      Navigator.pop(context,true);
                      Navigator.pop(context,true);
                    })),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
