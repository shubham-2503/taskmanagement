import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../View_model/teamApiServices.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _teamNameController = TextEditingController();
    fetchUsers();
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
      String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

      if (orgId == null) {
        // If the user hasn't switched organizations, use the organization ID obtained during login time
        orgId = prefs.getString('org_id') ?? "";
      }

      print("OrgId: $orgId");

      if (orgId.isEmpty) {
        throw Exception('orgId not found locally');
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

  void _showMembersDropdown(BuildContext context) async {
    List<User> allUsers = await fetchUsers();

    List<String> selectedIds = _selectedMembers.toList(); // Store the initial selected ids

    final selectedUserIds = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Members'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: allUsers.map((user) {
                        bool isSelected = selectedIds.contains(user.userId);

                        return ListTile(
                          title: Text(user.userName),
                          trailing: isSelected
                              ? Icon(Icons.remove_circle, color: AppColors.primaryColor2)
                              : Icon(Icons.add_circle, color: AppColors.secondaryColor2),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedIds.remove(user.userId);
                              } else {
                                selectedIds.add(user.userId);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
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
      },
    );

    if (selectedUserIds != null) {
      _selectedMembers = selectedUserIds;
      List<String> selectedMembersText = _selectedMembers
          .map((id) => allUsers.firstWhere((user) => user.userId == id).userName.toString())
          .toList();
      _assigneeMembersController.text = selectedMembersText.join(', ');
    }
  }

  Future<void> _createTeam(BuildContext context) async {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final storedData = prefs.getString('jwtToken');
        String? orgId = prefs.getString("selectedOrgId");

        if (orgId == null) {
          orgId = prefs.getString('org_id') ?? "";
        }

        print("OrgId: $orgId");

        if (orgId == null) {
          throw Exception('orgId not found locally');
        }

        final apiUrl = 'http://43.205.97.189:8000/api/Team/team?orgId=$orgId';
        final headers = {
          'accept': '*/*',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $storedData',
        };

        final body = jsonEncode({
          "name": _teamNameController.text.toString(),
          "user_id": _selectedMembers,
        });

        print("DAta: $body");

        final response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);
        print("code: ${response.statusCode}");
        print("Body: ${response.body}");

        if (response.statusCode == 200) {
          print('Team created successfully.');
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Thank you'),
                content: Text("Team created successfully"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context,true);
                      Navigator.pop(context,true);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          throw Exception('Failed to create team');
        }
      } catch (e) {
        print('Error: $e');
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Oops'),
              content: Text("Error while creating team"),
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

  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _teamNameController.clear();
    _selectedMembers.clear();
    setState(() {
      _assigneeMembersController.clear();
    });
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
                  GestureDetector(
                    onTap: () async {
                      _showMembersDropdown(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      height: MediaQuery.of(context).size.height * 0.10,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrayColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person),
                          SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              children: _assigneeMembersController.text.isNotEmpty
                                  ? [
                                Container(
                                  // Adjust the width to your needs
                                  // or remove it to let the Chip expand naturally
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  child: Chip(
                                    label: Text(
                                      _assigneeMembersController.text,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    deleteIcon: Icon(Icons.clear, size: 12),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedMembers = [];
                                        _assigneeMembersController.clear();
                                      });
                                    },
                                  ),
                                ),
                              ]
                                  : [],
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          onPressed: (){
                            if( _teamNameController.text.isNotEmpty && _selectedMembers.isNotEmpty ) {
                              _createTeam(context);
                            }
                            else{
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Oops'),
                                    content: Text("Please add required fields."),
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
                          },
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
