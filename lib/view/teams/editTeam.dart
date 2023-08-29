import 'dart:convert';
import 'package:Taskapp/common_widgets/round_textfield.dart';
import 'package:http/http.dart' as http;
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/fetch_user_model.dart';
import '../../utils/app_colors.dart';

class EditTeamPage extends StatefulWidget {
  final String teamId;
  final String? name;
  final List<String>? users;

  EditTeamPage({required this.teamId, this.name, this.users});

  @override
  _EditTeamPageState createState() => _EditTeamPageState();
}

class _EditTeamPageState extends State<EditTeamPage> {
  late TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
  }

  void dispose(){
    super.dispose();
    _nameController.dispose();
  }

  Future<void> updateTeamName(String teamId, String newTeamName) async {
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

      // Prepare the data for the request
      final Map<String, dynamic> requestBody = {
        "name": newTeamName,
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
        print('Team updated successfully with name.');
        String message = "Team updated successfully name.";
        _showDialog(message);
      } else {
        print('Failed to update team name.');
        String message = "Failed to update team name.";
        _showDialog(message);
      }
    } catch (e) {
      print('Error updating team name: $e');
      String message = "Error updating team name: $e";
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
              Navigator.pop(context);
            },
            child: Text("Ok"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
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
              SizedBox(height: 20,),
              Center(
                child: SizedBox(
                    height: 50,
                    width: 150,
                    child: RoundButton(title: "Save Changes", onPressed: ()async{
                      String newTeamName = _nameController.text;
                      await updateTeamName(widget.teamId, newTeamName);
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
