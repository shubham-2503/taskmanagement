import 'dart:convert';

import 'package:Taskapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/role_model.dart';


class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userProfileData;

  EditProfileScreen({required this.userProfileData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController(text: '');
  TextEditingController _mobileController = TextEditingController(text: '');
  List<Role> _roles = [];
  String _selectedRoleId = '';

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userProfileData['name'];
    _emailController = TextEditingController(text: widget.userProfileData['email'] ?? '');
    _mobileController = TextEditingController(text: widget.userProfileData['mobile'] ?? '');
    fetchRoles();
    _selectedRoleId = widget.userProfileData['role_id']?.toString() ?? '';
  }


  Future<void> fetchRoles() async {
    try {
      final url = Uri.parse('http://43.205.97.189:8000/api/Platform/getRoles');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> rolesData = json.decode(response.body);
        setState(() {
          _roles = rolesData.map<Role>((role) => Role.fromJson(role)).toList();
          _selectedRoleId = widget.userProfileData['role_id'].toString();
        });
      } else {
        throw Exception('Failed to fetch roles');
      }
    } catch (e) {
      print('API Error: $e');
    }
  }

  void _saveChanges() {
    String updatedName = _nameController.text;
    String updatedEmail = _emailController.text;
    String updatedMobile = _mobileController.text;
    String updatedRoleId = _selectedRoleId ?? ""; // Use null-aware operator to provide default value


    // Instead of modifying directly, create a new User object
    Map<String, dynamic> updatedUser = {
      'name': updatedName,
      'email': updatedEmail,
      'mobile': updatedMobile,
      'role_id': updatedRoleId,
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Profile Updated'),
        content: Text('Your profile has been updated successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, updatedUser); // Pass the updated user data here
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

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
              // Container(
              //   decoration: BoxDecoration(
              //     color: AppColors.lightGrayColor,
              //     borderRadius: BorderRadius.circular(15),
              //   ),
              //   child: DropdownButtonFormField<String>(
              //     value: _selectedRoleId,
              //     onChanged: (String? newValue) {
              //       setState(() {
              //         _selectedRoleId = newValue ?? ""; // Use null-aware operator to provide default value
              //       });
              //     },
              //     items: [
              //       // Add a default option with null value
              //       DropdownMenuItem<String>(
              //         value: null,
              //         child: Text('Select Role'),
              //       ),
              //       // Add the roles as dropdown items
              //       ..._roles.map<DropdownMenuItem<String>>((Role role) {
              //         return DropdownMenuItem<String>(
              //           value: role.id,
              //           child: Text(role.name),
              //         );
              //       }).toList(),
              //     ],
              //     decoration: InputDecoration(
              //       labelText: 'Role',
              //       border: OutlineInputBorder(),
              //     ),
              //   ),
              // ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

