import 'package:Taskapp/common_widgets/round_gradient_button.dart';
import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:search_choices/search_choices.dart';

import '../../common_widgets/round_button.dart';
import '../../common_widgets/round_textfield.dart';
import '../../utils/app_colors.dart';

class InviteTeammatesScreen extends StatefulWidget {
  const InviteTeammatesScreen({Key? key}) : super(key: key);

  @override
  _InviteTeammatesScreenState createState() => _InviteTeammatesScreenState();
}

class _InviteTeammatesScreenState extends State<InviteTeammatesScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  String? _selectedRole;
  List<String> _roles = ['Admin', 'Manager', 'Employee'];
  int _teammateRowCount = 1;

  void _addTeammateRow() {
    setState(() {
      _nameController.text = '';
      _emailController.text = '';
      _phoneController.text = '';
      _selectedRole = null;
      _teammateRowCount++;
    });
  }

  void _inviteTeammate() {
    String name = _nameController.text;
    String email = _emailController.text;
    String phone = _phoneController.text;
    String role = _selectedRole ?? '';

    // Perform the invitation logic here
    print('Inviting teammate:');
    print('Name: $name');
    print('Email: $email');
    print('Phone: $phone');
    print('Role: $role');

    // Clear the text field and reset the selected role
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _emailController.clear();
    setState(() {
      _selectedRole = null;
    });
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
                      fontStyle: FontStyle.italic
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Center(child: Text("Collaborate with your team to work efficiently",style: TextStyle(
                    color: Colors.black87,
                    fontSize: 10,
                    fontWeight: FontWeight.w500
                ),)),
                SizedBox(height: 16),
                SingleChildScrollView(
                  child: Column(
                    children: List.generate(_teammateRowCount, (index) {
                      return Column(
                        children: [
                          RoundTextField(
                            hintText: "Name",
                            icon: "assets/icons/name.png",
                            textInputType: TextInputType.text,
                          ),
                          SizedBox(height: 20,),
                          RoundTextField(
                              hintText: "Email",
                              icon: "assets/icons/message_icon.png",
                              textInputType: TextInputType.emailAddress),
                          SizedBox(height: 20,),
                          RoundTextField(
                            hintText: "Phone Number",
                            icon: "assets/icons/pho.png",
                            textInputType: TextInputType.phone,
                          ),
                          SizedBox(width: 10), // Add spacing between the fields
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.lightGrayColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: InputDecoration(
                                labelText: 'Role',
                                // ...
                              ),
                              items: _roles.map((String role) {
                                return DropdownMenuItem<String>(
                                  value: role,
                                  child: Text(role),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedRole = newValue;
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    }),
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
                        width: 90,
                        child: RoundButton(title: "Create\nTeam", onPressed: _inviteTeammate)),
                    SizedBox(height: 10,),
                    SizedBox(
                      height: 40,
                      width: 90,
                      child: RoundButton(title: "Skip For\nNow", onPressed: (){
                        if (ModalRoute.of(context)?.settings.name != '/DashboardScreen') {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
                        }
                      }),
                    )
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
