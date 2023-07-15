import 'dart:async';
import 'package:Taskapp/common_widgets/round_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:search_choices/search_choices.dart';

import '../../common_widgets/round_button.dart';
import '../../utils/app_colors.dart';

class ProjectCreationScreen extends StatefulWidget {
  @override
  _ProjectCreationScreenState createState() => _ProjectCreationScreenState();
}

class _ProjectCreationScreenState extends State<ProjectCreationScreen> {
  late String _projectTitle;
  late String _projectDocuments;
  List<String> _teams = ["Testing Team","Abc Team","Wesoftek Team","Development Team","Test1 Team","Test2 Team"];
  late String _selectedTeam = _teams[0];
  late String _attachment = '';
  DateTime? _startDate;
  DateTime? _endDate;
  bool value = false;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _documentsController = TextEditingController();
  List<String> _members = [
    "James",
    "Willam",
    "Naoh",
    "benjamin",
    "Michael",
    "Oliver",
    "Mia",
    "Emily",
    "john",
    "Sarah"
  ];
  late String _selectedMembers = _members[0];



  void openFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false, // Allow only a single file selection
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        setState(() {
          _attachment = file.path ?? '';
          _documentsController.text = _attachment;
        });
      }
    } on PlatformException catch (e) {
      print('Error while picking the file: $e');
    }
  }
  // Future<List<String>?> fetchMembers() async {
  //   final response = await http.get(
  //     Uri.parse('https://parseapi.back4app.com/classes/Complete_List_Names?limit=10'),
  //     headers: {
  //       "X-Parse-Application-Id": "zsSkPsDYTc2hmphLjjs9hz2Q3EXmnSxUyXnouj1I",
  //       "X-Parse-Master-Key": "4LuCXgPPXXO2sU5cXm6WwpwzaKyZpo3Wpj4G4xXK",
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final jsonData = json.decode(response.body);
  //     final List<dynamic>? results = jsonData['results'];
  //
  //     if (results != null && results.isNotEmpty) {
  //       List<String> members = results.map<String>((member) => member['Name'] as String).toList();
  //       return members;
  //     } else {
  //       return null; // Return null when there are no results
  //     }
  //   } else {
  //     return null; // Return null in case of an HTTP error
  //   }
  // }


  @override
  void dispose() {
    _titleController.dispose();
    _documentsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _documentsController = TextEditingController();

    // fetchMembers().then((members) {
    //   setState(() {
    //     _members = members!;
    //     _selectedMember = _members.isNotEmpty ? _members[0] : '';
    //   });
    // }).catchError((error) {
    //   print('Failed to fetch members: $error');
    // });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Project',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: constraints.maxHeight,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      RoundTextField(hintText: "Title",
                          icon: "assets/images/title.jpeg",
                        onChanged: (value) {
                          setState(() {
                            _projectTitle = value;
                          });
                        },
                        textEditingController: _titleController,
                      ),
                      SizedBox(height: 20.0),
                      RoundTextField(
                        hintText: "Documents",
                        icon: "assets/images/att.png",
                        onTap: openFilePicker,
                        isReadOnly: true,
                        onChanged: (value) {
                          setState(() {
                            _documentsController.text = value;
                          });
                        },
                        textEditingController: _documentsController,
                      ),
                      SizedBox(height: 20.0),
                      Text("Assigned To"),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightGrayColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SearchChoices.single(
                          items: _members.map((String assigneeType) {
                            bool isSelected = _selectedMembers == assigneeType;
                            return DropdownMenuItem<String>(
                              value: assigneeType,
                              child: Row(
                                children: [
                                  Text(assigneeType),
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value != null && value) {
                                          _selectedMembers = assigneeType;
                                        } else {
                                          _selectedMembers = '';
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          value: _selectedMembers,
                          hint: 'Select Members',
                          searchHint: 'Search Members',
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedMembers = newValue!;
                            });
                          },
                          isExpanded: true,
                          style: TextStyle(color: Colors.black),
                          underline: Container(
                            height: 1,
                            color: Colors.black,
                          ),
                          iconEnabledColor: Colors.black,
                          displayClearIcon: true,
                          // onChangedAndDisplayOtherItems: true,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text("Assigned Team"),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightGrayColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SearchChoices.single(
                          items: _teams.map((String teamType) {
                            bool isSelected = _selectedTeam == teamType;
                            return DropdownMenuItem<String>(
                              value: teamType,
                              child: Row(
                                children: [
                                  Text(teamType),
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value != null) {
                                          _selectedTeam = value ? teamType : '';
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          value: _selectedTeam,
                          hint: 'Select Team',
                          searchHint: 'Search Team',
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedTeam = newValue!;
                            });
                          },
                          isExpanded: true,
                          style: TextStyle(color: Colors.black),
                          underline: Container(
                            height: 1,
                            color: Colors.black,
                          ),
                          iconEnabledColor: Colors.black,
                          displayClearIcon: true,
                          // onChangedAndDisplayOtherItems: true,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        children: [
                          Expanded(
                            child: RoundTextField(
                              hintText: "Start Date",
                              icon: "assets/icons/calendar_icon.png",
                              isReadOnly: true,
                              onTap: (){
                                _selectStartDate(context);
                              },
                              textEditingController: TextEditingController(
                                text: _startDate != null
                                    ? DateFormat('yyyy-MM-dd')
                                    .format(_startDate!)
                                    : '',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectStartDate(context);
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: RoundTextField(
                              hintText: "End Date",
                              icon: "assets/icons/calendar_icon.png",
                              isReadOnly: true,
                              onTap: (){
                                _selectEndDate(context);
                              },
                              textEditingController: TextEditingController(
                                text: _endDate != null
                                    ? DateFormat('yyyy-MM-dd').format(_endDate!)
                                    : '',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectStartDate(context);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.0),
                      SizedBox(
                          height: 40,
                          width: 90,
                          child: RoundButton(title: "Create Task", onPressed: createProject))
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void createProject() {
    // Perform any necessary validation before creating the project
    if (_titleController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please enter a project title.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Create the project with the provided details
    // You can add your logic here to store the project data or perform any other actions
    // Show the "Thank You" page for a few seconds
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thank You'),
          content: RichText(
            text: TextSpan(
              text: 'Your project ',
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: _titleController.text.isNotEmpty ? _titleController.text : '',
                  style: TextStyle(
                    color: Colors.black, // Set the desired color here
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                TextSpan(
                  text: ' has been successfully created.',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Delay the navigation back to the previous screen
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Close the "Thank You" page

      setState(() {
        _projectTitle = _titleController.text;
        _projectDocuments = _documentsController.text;
        _selectedTeam = _selectedTeam;
        _startDate = _startDate;
        _endDate = _endDate;
        _titleController.text = '';
        _documentsController.text = '';
      });

      // Print the project details
      print('Creating project...');
      print('Title: $_projectTitle');
      print('Documents: $_projectDocuments');
      print('Start Date: ${_startDate?.toIso8601String()}');
      print('End Date: ${_endDate?.toIso8601String()}');

      // Pass the project details back to the previous screen
      Navigator.of(context).pop<Map<String, dynamic>?>({
        'projectTitle': _projectTitle,
      });
    });
  }
}
