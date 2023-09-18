import 'dart:convert';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/common_widgets/round_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../View_model/fetchApiSrvices.dart';
import '../../models/fetch_user_model.dart';
import '../../models/project_team_model.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import 'package:intl/intl.dart';

class EditCreatedByTask extends StatefulWidget {
  final Task task;
  const EditCreatedByTask({super.key, required this.task});

  @override
  State<EditCreatedByTask> createState() => _EditCreatedByTaskState();
}

class _EditCreatedByTaskState extends State<EditCreatedByTask> {
  DateTime dueDate = DateTime.now();
  Map<String, String> teamId = {}; // Map to store team IDs to names
  Map<String, String> memberId = {}; // Map to store member IDs to names
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController assignedToController = TextEditingController();
  TextEditingController assignedTeamController = TextEditingController();
  late Task task;
  List<dynamic> priorities = [];
  List<dynamic> statuses = [];
  String _priority = ""; // Initialize with an empty string
  String _selectedStatus = "";
  List<User> users = [];
  List<Team> teams = [];
  List<String> selectedMembers = [];
  List<String> selectedTeams = [];

  Future<void> updateTasks(String taskId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId =
      prefs.getString("selectedOrgId"); // Get the selected organization ID

      if (orgId == null) {
        // If the user hasn't switched organizations, use the organization ID obtained during login time
        orgId = prefs.getString('org_id') ?? "";
      }

      print("OrgId: $orgId");

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      final url = 'http://43.205.97.189:8000/api/Task/editTasks';

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
        'Content-Type': 'application/json',
      };

      DateTime endDate = DateTime.parse(dateController.text!).toUtc();
      String? endDateString = endDate.toIso8601String();
      List<User> users = await fetchUsers();
      List<Team> teams = await fetchTeams();

      List<String> selectedMembers = assignedToController.text.split(',');
      List<String> selectedTeams = assignedTeamController.text.split(',');

      print("selectedTeams: $selectedTeams");
      print("selectedMember: $selectedMembers");

      List<String> selectedMemberIds = [];
      for (String memberName in selectedMembers) {
        String memberId = getUserIdFromName(memberName, users); // Make sure this function works correctly
        if (memberId != null) {
          selectedMemberIds.add(memberId);
        }
      }

      List<String> selectedTeamIds = [];
      for (String teamName in selectedTeams) {
        String teamId = getTeamIdFromName(teamName, teams); // Make sure this function works correctly
        if (teamId != null) {
          selectedTeamIds.add(teamId);
        }
      }

      print("selectedTeamIds: $selectedTeamIds");
      print("selectedMemberIds: $selectedMemberIds");

      final body = jsonEncode({
        "task_id": taskId,
        "name": titleController.text.toString(),
        "description": descriptionController.text.toString(),
        "assigned_user": selectedMemberIds,
        "assigned_team": selectedTeamIds,
        "priority": _priority,
        "status": _selectedStatus,
        "end_date": endDateString,
        "project_id": null,
      });

      final response =
      await http.patch(Uri.parse(url), headers: headers, body: body);
      print("StatusCode: ${response.statusCode}");
      print("Body: ${response.body}");
      print("Response: ${jsonDecode(body)}");

      if (response.statusCode == 200) {
        // Update successful
        final responseData = json.decode(response.body);
        print('Tasks updated successfully: ${responseData['message']}');
        // Handle the response data as needed
        setState(() {});
        // Optionally, you can show a success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Changes Saved'),
              content: Text('Your changes have been updated successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    Navigator.pop(context);
                    Navigator.of(context).pop(true);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Update failed
        print('Error updating tasks: ${response.statusCode}');
        // Show an error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to update tasks. Please try again later.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle exceptions
      print('Error updating tasks: $e');
      // Show an error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content:
            Text('An unexpected error occurred. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    task = widget.task;
    _priority = task.priority;
    _selectedStatus = task.status;
    titleController.text = task.taskName;
    assignedToController.text = task.assignedTo?.join(', ') ?? '';
    assignedTeamController.text = task.assignedTeam?.join(', ') ?? '';
    descriptionController.text = task.description ?? " ";
    dateController.text = formatDate(dueDate);
    fetchTaskDetails(); // Call fetchTaskDetails to initialize 'task'
    fetchStatusData(); // Initialize statuses and _selectedStatus
    fetchPriorities(); // Initialize priorities and _priority
  }

  Future<void> fetchTaskDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://43.205.97.189:8000/api/Task/taskDetails?taskId=${widget.task.taskId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          // Find the task with a matching ID
          final taskJson = data.firstWhere(
                (task) => task['id'] == widget.task.taskId,
            orElse: () => null,
          );

          if (taskJson != null) {
            final taskDetail = Task.fromJson(taskJson);

            setState(() {
              task = taskDetail;
            });
          }
        }
      } else {
        print('API Error: Status Code ${response.statusCode}');
        // Handle error scenario
      }
    } catch (e) {
      print('Exception in fetchTaskDetails: $e');
      // Handle exception
    }
  }

  Future<void> fetchStatusData() async {
    try {
      List<dynamic> fetchedStatuses = await ApiServices.fetchStatusData();
      setState(() {
        statuses = fetchedStatuses;
        // Check if statuses list is not empty
        if (statuses.isNotEmpty) {
          // Find the status in the list that matches the task's status
          Map<String, dynamic> taskStatus = statuses.firstWhere(
                (status) => status['name'] == task.status,
            orElse: () =>
            statuses[0], // Default to the first status if not found
          );
          // Set _selectedStatus to the matched status ID
          _selectedStatus = taskStatus['id'].toString();
        }
      });
    } catch (e) {
      print('Error fetching statuses: $e');
      // Handle error if necessary
    }
  }

  void fetchPriorities() async {
    final response = await http
        .get(Uri.parse('http://43.205.97.189:8000/api/Platform/getPriorities'));

    if (response.statusCode == 200) {
      setState(() {
        priorities = json.decode(response.body);

        // Find the priority in the list that matches the task's priority name
        Map<String, dynamic> taskPriority = priorities.firstWhere(
              (priority) => priority['name'] == task.priority,
          orElse: () =>
          priorities[0], // Default to the first priority if not found
        );
        _priority = taskPriority['id'];
      });
    } else {
      print('Failed to fetch priorities');
    }
  }

  Future<List<User>> fetchUsers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
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

      final response = await http.get(
        Uri.parse(
            'http://43.205.97.189:8000/api/UserAuth/getOrgUsers?org_id=$orgId'),
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

          // Process the teams data as needed
          // For example, you can store them in a state variable or display them in a dropdown menu

          // Print the team names for testing
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

  Future<List<Team>> fetchTeams() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
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

      final response = await http.get(
        Uri.parse(
            'http://43.205.97.189:8000/api/Team/myTeams?org_id=$orgId'), // Update the API endpoint URL
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
          try {
            final List<dynamic> data = jsonDecode(responseBody);
            if (data != null) {
              final List<Team> teams = data
                  .map((teamJson) =>
                  Team.fromJson(teamJson as Map<String, dynamic>))
                  .toList();

              for (var team in teams) {
                print("Team Name: ${team.teamName}");
                print("Team ID: ${team.id}");
                print("Users: ${team.users}");
                print("----------------------");
              }

              return teams;
            }
          } catch (e) {
            print('Response Body: $responseBody');
            print('Error decoding JSON: $e');
          }
        }
      } else {
        print('Error: ${response.statusCode}');
      }
      return teams;
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch teams');
    }
  }

  Future<void> _showTeamsDropdown(BuildContext context) async {
    List<Team> teams = await fetchTeams();
    List<String> selectedTeams = assignedTeamController.text.isNotEmpty ? assignedTeamController.text.split('\n') : List.from(task.assignedTeam);;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Teams'),
              content: SingleChildScrollView(
                child: Column(
                  children: teams.map((team) {
                    bool isSelected = selectedTeams.contains(team.teamName);

                    return ListTile(
                      title: Text(team.teamName),
                      trailing: isSelected
                          ? Icon(Icons.cancel, color: Colors.red)
                          : Icon(Icons.add_circle, color: Colors.green),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedTeams.remove(team.teamName);
                          } else {
                            selectedTeams.add(team.teamName);
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
                    assignedTeamController.text = selectedTeams.join(', ');
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

  Future<void> _showMembersDropdown(BuildContext context) async {
    List<User> allUsers = await fetchUsers();
    List<String> selectedMembers = List.from(task.assignedTo);

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
                    assignedToController.text = selectedMembers.join(', ');
                    task.assignedTo = assignedToController.text.isNotEmpty ? assignedToController.text.split(', ') : []; // Update the task's assignedTo
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

  String getUserIdFromName(String name, List<User> users) {
    User? user = users.firstWhere(
          (user) => user.userName == name,
    );
    return user?.userId ?? ''; // Return an empty string if user not found
  }

  String getTeamIdFromName(String name, List<Team> teams) {
    Team? team = teams.firstWhere(
          (team) => team.teamName == name,
    );
    return team?.id ?? ''; // Return an empty string if team not found
  }

  @override
  Widget build(BuildContext context) {
    if (task == null) {
      // Handle loading state
      return CircularProgressIndicator(); // Or show a loading indicator
    }
    print("TaskId: ${widget.task.taskId}");
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Title",
                style: TextStyle(
                  color: AppColors.secondaryColor2,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: RoundTextField(
                hintText: "Title",
                icon: "assets/images/title.jpeg",
                textEditingController: titleController,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Description",
                style: TextStyle(
                  color: AppColors.secondaryColor2,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: RoundTextField(
                hintText: "Task Description",
                icon: "assets/images/des.png",
                textInputType: TextInputType.text,
                textEditingController: descriptionController,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Members",
                style: TextStyle(
                  color: AppColors.secondaryColor2,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: RoundTextField(
                hintText: "AssigneeMembers",
                icon: "assets/images/des.png",
                textInputType: TextInputType.text,
                isReadOnly: true,
                textEditingController: assignedToController,
                onTap: (){
                  _showMembersDropdown(context);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Teams",
                style: TextStyle(
                  color: AppColors.secondaryColor2,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: RoundTextField(
                hintText: "AssigneeTeams",
                icon: "assets/images/des.png",
                textInputType: TextInputType.text,
                isReadOnly: true,
                textEditingController: assignedTeamController,
                onTap: (){
                  _showTeamsDropdown(context);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Due Date",
                style: TextStyle(
                  color: AppColors.secondaryColor2,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: GestureDetector(
                onTap: () {
                  DatePicker.showDatePicker(
                    context,
                    showTitleActions: true,
                    onConfirm: (date) {
                      dueDate = date;
                      dateController.text = formatDate(
                          dueDate); // Assuming `formatDate` function formats the `DateTime` to a string
                    },
                    currentTime: dueDate,
                  );
                },
                child: AbsorbPointer(
                  child: RoundTextField(
                    textEditingController: dateController,
                    hintText: "Due Date",
                    icon: "assets/icons/calendar_icon.png",
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Priority",
                style: TextStyle(
                  color: AppColors.secondaryColor2,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 65),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGrayColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 15,
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Priority",
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: AppColors.grayColor,
                    ),
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Image.asset(
                        "assets/images/pri.png",
                        width: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  items: priorities.map((priority) {
                    return DropdownMenuItem<String>(
                      value: priority['id'],
                      child: Text(priority['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _priority = value!;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Status",
                style: TextStyle(
                  color: AppColors.secondaryColor2,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 65),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGrayColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 15,
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Status",
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Image.asset(
                        "assets/images/pri.png",
                        width: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  items: statuses.map<DropdownMenuItem<String>>((status) {
                    return DropdownMenuItem<String>(
                      value: status['id']
                          .toString(), // Assuming 'id' is of type String or can be converted to String
                      child: Text(status['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 30,
                  width: 120,
                  child: RoundButton(
                      title: "Update Task",
                      onPressed: () async {
                        // Task updatedTask = Task(
                        //   taskId: widget.task.taskId,
                        //   taskName: titleController.text.toString(),
                        //   description: descriptionController.text.toString(),
                        //   dueDate: formatDate(dueDate),
                        //   assignedTo: List.from(_selectedMembers),
                        //   assignedTeam: List.from(_selectedTeams),
                        //   priority: _priority,
                        //   status: _selectedStatus,
                        // );
                        // print("${task.taskId}");
                        // print("${task.taskName}");
                        // print("${task.dueDate}");
                        // print("$_selectedStatus");
                        // print("$_priority");
                        // print("${task.taskId}");
                        updateTasks(task.taskId!);
                      }),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd')
        .format(dateTime); // Format to show only the date
  }

  Future<String> getUserIdByUsername(String username) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId =
      prefs.getString("selectedOrgId"); // Get the selected organization ID

      if (orgId == null) {
        // If the user hasn't switched organizations, use the organization ID obtained during login time
        orgId = prefs.getString('org_id') ?? "";
      }

      print("OrgId: $orgId");

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      final response = await http.get(
        Uri.parse(
            'http://43.205.97.189:8000/api/UserAuth/getOrgUsers?org_id=$orgId'),
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
}