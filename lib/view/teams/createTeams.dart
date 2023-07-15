import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/round_textfield.dart';
import '../../utils/app_colors.dart';

class Team {
  String teamName;
  String description;
  String teamLeader;
  DateTime createdOn;

  Team({
    required this.teamName,
    required this.description,
    required this.teamLeader,
    required this.createdOn,
  });
}

class TeamCreationPage extends StatefulWidget {
  @override
  _TeamCreationPageState createState() => _TeamCreationPageState();
}

class _TeamCreationPageState extends State<TeamCreationPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _teamNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _teamMembersController;


  @override
  void initState() {
    super.initState();
    _teamNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _teamMembersController = TextEditingController();
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _descriptionController.dispose();
    _teamMembersController.dispose();
    super.dispose();
  }

  void _createTeam() {
    if (_formKey.currentState!.validate()) {
      Team newTeam = Team(
        teamName: _teamNameController.text,
        description: _descriptionController.text,
        teamLeader: _teamMembersController.text,
        createdOn: DateTime.now(),

      );

      // Do something with the new team, such as saving it to a database or displaying it.

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Team Created'),
            content: Text('Team "${newTeam.teamName}" has been created successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  List<Team> teams = [newTeam]; // You can maintain a list of teams
                  _resetForm();
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
    _descriptionController.clear();
    _teamMembersController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Center(child: Text('Create Team',style: TextStyle(
                      color: AppColors.secondaryColor2,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  ),),
                  ),
                  SizedBox(height: 30,),
                  RoundTextField(hintText: "Team Name",
                    icon: "assets/images/title.jpeg",
                    onChanged: (value) {
                      setState(() {
                        _teamNameController.text = value;
                      });
                    },
                  ),
                  SizedBox(height: 20,),
                  RoundTextField(
                    hintText: "Task Description",
                    icon: "assets/images/des.png",
                    textInputType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {
                        _descriptionController.text = value;
                      });
                    },
                  ),
                  SizedBox(height: 20,),
                  RoundTextField(
                    hintText: "Members",
                    icon: "assets/images/pers.png",
                    textInputType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {
                        _teamMembersController.text = value;
                      });
                    },
                  ),
                  SizedBox(height: 25.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                          height: 40,
                          width: 100,
                          child: RoundButton(title: "Create\nTeam", onPressed: _createTeam)),
                      SizedBox(height: 16.0),
                      SizedBox(
                          height: 40,
                          width: 100,
                          child: RoundButton(title: "Reset", onPressed:_resetForm)),
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
