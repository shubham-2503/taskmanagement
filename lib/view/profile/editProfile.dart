import 'dart:convert';
import 'package:Taskapp/View_model/updateApiSevices.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/role_model.dart';
import '../../utils/app_colors.dart';


class EditProfileScreen extends StatefulWidget {
  final String orgId;
  EditProfileScreen({required this.orgId});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController(text: '');
  TextEditingController _mobileController = TextEditingController(text: '');
  TextEditingController _roleController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
  }

  List<Role> _roles = [];
  String _selectedRoleId = '';

  Future<Map<String, dynamic>> fetchUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');
    String? orgId =
    prefs.getString("selectedOrgId"); // Get the selected organization ID

    if (orgId == null) {
      // If the user hasn't switched organizations, use the organization ID obtained during login time
      orgId = prefs.getString('org_id') ?? "";
    }

    print("OrgId: $orgId");

    if (orgId.isEmpty) {
      throw Exception('orgId not found locally');
    }

    final url = 'http://43.205.97.189:8000/api/User/myProfile?org_id=$orgId';

    final headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $storedData',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    print("StatusCode: ${response.statusCode}");
    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      if (responseData.isNotEmpty) {
        // Get the first organization as the default organization
        final Map<String, dynamic> userProfileData =
        responseData[0] as Map<String, dynamic>;
        final String userIds = userProfileData['user_id'];
        return userProfileData;
      }
    }

    // Return an empty map if there's an error or no data
    return {};
  }

  // Future<void> fetchRoles() async {
  //   try {
  //     final url = Uri.parse('http://43.205.97.189:8000/api/Platform/getRoles');
  //     final response = await http.get(url);
  //
  //     if (response.statusCode == 200) {
  //       final List<dynamic> rolesData = json.decode(response.body);
  //       setState(() {
  //         _roles = rolesData.map<Role>((role) => Role.fromJson(role)).toList();
  //         _selectedRoleId = getRoleIdFromName()!; // Set the selected role ID initially
  //       });
  //     } else {
  //       throw Exception('Failed to fetch roles');
  //     }
  //   } catch (e) {
  //     print('API Error: $e');
  //   }
  // }

  String? getRoleIdFromName(String? roleName) {
    Role? selectedRole = _roles.firstWhere((role) => role.name == roleName,);
    return selectedRole?.id;
  }

  // void _saveChanges() {
  //   String updatedName = _nameController.text;
  //   String updatedEmail = _emailController.text;
  //   String updatedMobile = _mobileController.text;
  //   String updatedRoleId =getRoleIdFromName(_roleController.text)!; // Use null-aware operator to provide default value
  //
  //   // Instead of modifying directly, create a new User object
  //   Map<String, dynamic> updatedUser = {
  //     'name': updatedName,
  //     'email': updatedEmail,
  //     'mobile': updatedMobile,
  //     'role_id': updatedRoleId,
  //     'user_id': widget.id, // Assuming 'user_id' is present in userProfileData
  //   };
  //
  //   // Call the editProfile API function with the updated user data
  //   try {
  //     UpdateApiServices updateApiServices = UpdateApiServices();
  //     updateApiServices.editProfile(updatedUser);
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Text('Profile Updated'),
  //         content: Text('Your profile has been updated successfully.'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               Navigator.pop(context, updatedUser); // Pass the updated user data here
  //             },
  //             child: Text('OK'),
  //           ),
  //         ],
  //       ),
  //     );
  //   } catch (error) {
  //     print('Error updating profile: $error');
  //     // Handle the error and show an error message if necessary
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(labelText: 'Mobile'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _roleController,
                decoration: InputDecoration(labelText: 'Role'),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed:(){},
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

