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
  bool _isLoading = false;
  Map<String, List<String>> selectedMembers = {};
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
      print("Updated teams");
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
    List<String> selectedMembers = List.from(widget.team.users);

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
                    widget.team.users = _usercontroller.text.isNotEmpty ? _usercontroller.text.split(', ') : []; // Update the task's assignedTo
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

  Future<void> _handleSaveChanges() async {
    if (_usercontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one member'),
        ),
      );
      return; // Do not proceed if members are not selected
    }

    setState(() {
      _isLoading = true; // Set loading state to true
    });

    List<String> selectedMembers = _usercontroller.text.split(', ');
    // Create a list to store user IDs and team IDs
    List<User> existingUsers = await fetchUsers();
    List<String> selectedMemberIds = [];
    // Function to get or create user ID from username
    String getOrCreateUserId(String userName) {
      for (User user in existingUsers) {
        if (user.userName == userName) {
          return user.userId;
        }
      }
      return '';
    }

    // Populate selectedMemberIds and selectedTeamIds
    for (String memberName in selectedMembers) {
      String memberId = getOrCreateUserId(memberName);
      selectedMemberIds.add(memberId);
    }

    print("User IDs: $selectedMemberIds");
    String newTeamName = _nameController.text;
    await updateTeamNameAndMembers(widget.team.teamId!, newTeamName, selectedMemberIds);

    setState(() {
      _isLoading = false; // Set loading state to false
    });

    Navigator.pop(context, true);
    Navigator.pop(context, true);
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
              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  height: 50,
                  width: 200,
                  child: _isLoading // Check the loading state
                      ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor2,
                    ),
                    onPressed: null, // Disable the button when loading
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Loading...', style: TextStyle(color:AppColors.secondaryColor2)),
                        SizedBox(width: 10),
                        CircularProgressIndicator(color: AppColors.secondaryColor2),
                      ],
                    ),
                  )
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor2,
                    ),
                    onPressed: _handleSaveChanges,
                    child: Text("Save Changes", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}