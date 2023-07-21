import 'dart:convert';
import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_widgets/round_button.dart';
import '../../common_widgets/round_textfield.dart';
import '../../utils/app_colors.dart';
import 'package:http/http.dart' as http;

class InviteTeammatesScreen extends StatefulWidget {
  const InviteTeammatesScreen({Key? key}) : super(key: key);

  @override
  _InviteTeammatesScreenState createState() => _InviteTeammatesScreenState();
}

class _InviteTeammatesScreenState extends State<InviteTeammatesScreen> {
  List<Teammate> teammates = [];
  List<Map<String, String>> _roles = [];

  @override
  void initState() {
    super.initState();
    fetchRoles(); // Fetch the roles when the screen initializes
  }

  Future<void> fetchRoles() async {
    try {
      final url = Uri.parse('http://43.205.97.189:8000/api/Platform/getRoles');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> rolesData = json.decode(response.body);
        setState(() {
          _roles = rolesData.map<Map<String, String>>((role) {
            return {
              'id': role['id'].toString(),
              'name': role['name'].toString(),
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to fetch roles');
      }
    } catch (e) {
      print('API Error: $e');
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    // Email regex pattern
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+(\.[a-zA-Z]+)?$');

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    // Phone number regex pattern
    final phoneRegex = RegExp(
        r'^\+[1-9]{1}[0-9]{3,14}$'); // Country code followed by 10 digits

    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  void _addTeammateRow() {
    setState(() {
      teammates.add(Teammate());
    });
  }

  void _inviteTeammate() async {
    try {
      // Get the token or user ID from local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      List<Map<String, dynamic>> requestBody = [];

      for (var teammate in teammates) {
        String name = teammate.nameController.text;
        String email = teammate.emailController.text;
        String phone = teammate.phoneController.text;
        String? roleId = teammate.selectedRole;

        Map<String, dynamic> teammateData = {
          'email': email,
          'role_id': roleId,
          'name': name,
          'mobile': phone,
        };

        requestBody.add(teammateData);
      }

      final Uri url = Uri.parse('http://43.205.97.189:8000/api/User/inviteUsers');
      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $storedData',
        },
        body: jsonEncode(requestBody),
      );

      print(jsonEncode(requestBody));
      print('API Response: ${response.body}');
      print('StatusCode: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Invitation successful, handle the response if needed
        print('Invitation successful');
      } else {
        // Invitation failed
        final responseData = response.body;
        // Handle the error and display an error message to the user
        print('Invitation failed: $responseData');
      }
    } catch (e) {
      print('API Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.deepPurple),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Invite a Teammate',
                    style: TextStyle(
                      color: AppColors.secondaryColor2,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Center(
                  child: Text(
                    "Collaborate with your team to work efficiently",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                SingleChildScrollView(
                  child: Column(
                    children: teammates.map((teammate) {
                      return Column(
                        children: [
                          RoundTextField(
                            hintText: "Name",
                            icon: "assets/icons/name.png",
                            textInputType: TextInputType.text,
                            textEditingController: teammate.nameController,
                          ),
                          SizedBox(height: 20,),
                          RoundTextField(
                            hintText: "Email",
                            icon: "assets/icons/message_icon.png",
                            textInputType: TextInputType.emailAddress,
                            textEditingController: teammate.emailController,
                            validator: validateEmail,
                          ),
                          SizedBox(height: 20,),
                          RoundTextField(
                            hintText: "Phone Number",
                            icon: "assets/icons/pho.png",
                            textInputType: TextInputType.phone,
                            textEditingController: teammate.phoneController,
                            validator: validatePhoneNumber,
                          ),
                          SizedBox(width: 10), // Add spacing between the fields
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.lightGrayColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: teammate.selectedRole,
                              decoration: InputDecoration(
                                labelText: 'Role',
                                // ...
                              ),
                              items: _roles.map<DropdownMenuItem<String>>((Map<String, String> role) {
                                return DropdownMenuItem<String>(
                                  value: role['id']!,
                                  child: Text(role['name']!),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  teammate.selectedRole = newValue;
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _addTeammateRow,
                      icon: Icon(Icons.add),
                    ),
                    Text("ADD MORE TEAMMATES"),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 150,
                      child: RoundButton(title: "Invite Teammates", onPressed: _inviteTeammate),
                    ),
                    SizedBox(height: 10,),
                    SizedBox(
                      height: 40,
                      width: 90,
                      child: RoundButton(
                        title: "Skip For\nNow",
                        onPressed: () {
                          if (ModalRoute.of(context)?.settings.name != '/DashboardScreen') {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Teammate {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String? selectedRole;
}
