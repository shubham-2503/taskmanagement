import 'dart:convert';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/common_widgets/round_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../View_model/fetchApiSrvices.dart';
import '../../common_widgets/date_widget.dart';
import '../../models/fetch_user_model.dart';
import '../../models/project_team_model.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import 'package:intl/intl.dart';

class EditMyTask extends StatefulWidget {
  final Task task;
  const EditMyTask({super.key, required this.task});

  @override
  State<EditMyTask> createState() => _EditMyTaskState();
}

class _EditMyTaskState extends State<EditMyTask> {
  late Task task;
  List<dynamic> statuses = [];
  String _selectedStatus = "";
  List<User> users = [];
  List<Team> teams = [];
  List<String> _selectedMembers = [];
  List<String> _selectedTeams = [];

  @override
  void initState() {
    super.initState();
    task = widget.task;
    _selectedStatus = task.status;
    fetchTaskDetails(); // Call fetchTaskDetails to initialize 'task'
    fetchStatusData(); // Initialize statuses and _selectedStatus
  }

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

      List<User> users = await fetchUsers();
      List<Team> teams = await fetchTeams();

      List<String> selectedMembers = task.assignedTo;
      List<String> selectedTeams = task.assignedTeam;

      List<String> selectedMemberIds = [];
      for (String memberName in selectedMembers) {
        // Assuming you have a way to map member names to their IDs
        String memberId =
        getUserIdFromName(memberName, users); // Replace with actual logic
        selectedMemberIds.add(memberId);
      }

      List<String> selectedTeamIds = [];
      for (String teamName in selectedTeams) {
        // Assuming you have a way to map team names to their IDs
        String teamId =
        getTeamIdFromName(teamName, teams); // Replace with actual logic
        selectedTeamIds.add(teamId);
      }

      print("selectedTeamsIdds: $selectedTeamIds");
      print("selectedMembersids: $selectedMemberIds");

      final body = jsonEncode({
        "task_id": taskId,
        "assigned_user": selectedMemberIds,
        "assigned_team": selectedTeamIds,
        "status": _selectedStatus,
        "project_id": null,
      });

      final response =
      await http.patch(Uri.parse(url), headers: headers, body: body);
      print("StatusCode: ${response.statusCode}");
      print("Body: ${response.body}");
      print("Response: ${jsonDecode(body)}");

      if (mounted) {
        // Check if the widget is still mounted
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
                content:
                Text('Failed to update tasks. Please try again later.'),
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
    } catch (e) {
      // Handle exceptions
      if (mounted) {
        // Check if the widget is still mounted
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
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
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
            padding: EdgeInsets.only(left: 15, right: 10,top: 20),
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
                      updateTasks(widget.task.taskId!);
                    }),
              ),
            ),
          )
        ],
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
