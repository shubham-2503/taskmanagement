import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/view/tasks/tasks.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../common_widgets/round_textfield.dart';
import '../../utils/app_colors.dart';

class TaskCreationScreen extends StatefulWidget {
  @override
  _TaskCreationScreenState createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  late String _projectName;
  late String _taskTitle;
  late String _taskDescription;
  late String _organizationName;
  late String _attachment = '';
  late Set<String> _selectedMembers;
  late Set<String> _selectedTeams;
  DateTime? _startDate;
  DateTime? _endDate;
  late String _priority;
  TextEditingController _attachmentController = TextEditingController();
  bool _showTeams = false;
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

  List<String> _teams = [
    'Owner 1',
    'Owner 2',
    'Owner 3',
    'Owner 4',
  ];

  List<String> _priorities = [
    "Critical",
    'Low',
    'Medium',
    'High',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTeams = {};
    _selectedMembers = {}; // Set the initial value
    _priority = _priorities[0]; // Set the initial value
    _attachmentController.text = _attachment;
  }

  void openFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false, // Allow only a single file selection
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        setState(() {
          _attachment = file.path ?? '';
          _attachmentController.text = _attachment;
        });
      }
    } on PlatformException catch (e) {
      print('Error while picking the file: $e');
    }
  }

  void _showMembersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Assignee Members'),
          content: ListView.builder(
            shrinkWrap: true,
            itemCount: _members.length,
            itemBuilder: (context, index) {
              final member = _members[index];
              return CheckboxListTile(
                title: Text(member),
                value: _selectedMembers.contains(member),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedMembers.add(member);
                    } else {
                      _selectedMembers.remove(member);
                    }
                  });
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showTeamsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Assignee Teams'),
          content: ListView.builder(
            shrinkWrap: true,
            itemCount: _teams.length,
            itemBuilder: (context, index) {
              final team = _teams[index];
              return CheckboxListTile(
                title: Text(team),
                value: _selectedTeams.contains(team),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedTeams.add(team);
                    } else {
                      _selectedTeams.remove(team);
                    }
                  });
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Text(
          'Task Creation',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 15,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      RoundTextField(
                        hintText: "Project Name",
                        icon: "assets/icons/naa.png",
                        textInputType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {
                            _projectName = value;
                          });
                        },
                      ),
                      SizedBox(height: 16.0),
                      RoundTextField(
                        hintText: "Organization Name",
                        icon: "assets/icons/name.png",
                        textInputType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {
                            _organizationName = value;
                          });
                        },
                      ),
                      SizedBox(height: 16.0),
                      RoundTextField(
                        hintText: "Task Title",
                        icon: "assets/images/title.jpeg",
                        textInputType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {
                            _taskTitle = value;
                          });
                        },
                      ),
                      SizedBox(height: 16.0),
                      RoundTextField(
                        hintText: "Task Description",
                        icon: "assets/images/des.png",
                        textInputType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {
                            _taskDescription = value;
                          });
                        },
                      ),
                      SizedBox(height: 16.0),
                      RoundTextField(
                        hintText: "Attachment",
                        icon: "assets/images/att.png",
                        onTap: openFilePicker,
                        isReadOnly: true,
                        onChanged: (value) {
                          setState(() {
                            _attachmentController.text = value;
                          });
                        },
                      ),
                      SizedBox(height: 16.0),
                      RoundTextField(hintText: "Assignee Members", icon: "assets/images/pers.png",onTap: (){
                        _showMembersDialog();
                      },),
                      SizedBox(height: 16.0),
                      RoundTextField(hintText: "Assignee Teams", icon: "assets/images/pers.png",
                        onTap: (){
                          _showTeamsDialog();
                        },
                      ),
                      SizedBox(height: 16.0),
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
                      SizedBox(height: 16.0),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightGrayColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _priority,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: "Priority",
                              hintStyle: TextStyle(
                                  fontSize: 12, color: AppColors.grayColor),
                            icon: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Image.asset("assets/images/pri.png",width: 20,color: Colors.grey,),
                            ),
                          ),
                          items: _priorities.map((priority) {
                            return DropdownMenuItem<String>(
                              value: priority,
                              child: Text(priority),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _priority = value!;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 30.0),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     createTask();
                      //   },
                      //   child: Text('Create Task'),
                      //   style: ElevatedButton.styleFrom(
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(16.0),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                          height: 40,
                          width: 100,
                          child: RoundButton(title: "Create Task", onPressed: createTask))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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

  void createTask() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Fetch the user name from shared preferences
    // String? createdBy = prefs.getString('name');
    //
    // // If the user name is not available, you can handle it accordingly
    // if (createdBy == null) {
    //   print('User name not found');
    //   return;
    // }

    // Create a unique ID for the task
    String taskId = DateTime.now().millisecondsSinceEpoch.toString();

    // Get the current timestamp
    DateTime currentTimestamp = DateTime.now();

    // Format the timestamp as a string
    String creationTimestamp = currentTimestamp.toIso8601String();

    // Save the remaining fields using SharedPreferences
    await prefs.setString('attachment', _attachment);
    // await prefs.setString('selectedOwner', _selectedMembers);
    await prefs.setString('startDate', _startDate?.toIso8601String() ?? '');
    await prefs.setString('endDate', _endDate?.toIso8601String() ?? '');
    await prefs.setString('priority', _priority);
    await prefs.setString('taskId', taskId);
    await prefs.setString('creationTimestamp', creationTimestamp);

    // Create a map to represent the task
    Map<String, dynamic> taskData = {
      'id': taskId,
      'PName': _projectName,
      'title': _taskTitle,
      'description': _taskDescription,
      'attachment': _attachment,
      'owner': _selectedMembers,
      'startDate': _startDate != null ? _startDate!.toIso8601String() : null,
      'endDate': _endDate != null ? _endDate!.toIso8601String() : null,
      'priority': _priority,
      // 'createdBy': createdBy,// Set the 'createdBy' field
      'creationTimestamp': creationTimestamp,
    };

    // Save the task data to shared preferences
    List<String> tasks = prefs.getStringList('tasks') ?? [];
    tasks.add(taskId);
    prefs.setStringList('tasks', tasks);
    prefs.setStringList(
      'task_$taskId',
      taskData.entries.map((entry) => '${entry.key}:${entry.value}').toList(),
    );

    // Print the task details
    print('Creating task...');
    print('Title: $_taskTitle');
    print("PName: $_projectName");
    print('Description: $_taskDescription');
    print('Attachment: $_attachment');
    print('AssignedTo: $_selectedTeams');
    print('Owner: $_selectedMembers');
    print('Start Date: ${_startDate?.toIso8601String()}');
    print('End Date: ${_endDate?.toIso8601String()}');
    print('Priority: $_priority');
    // print('Created By: $createdBy');
    print('Creation Timestamp: $creationTimestamp');
    print('Task ID: $taskId');

    // Proceed to the next screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskScreen(),
      ),
    );
  }
}
