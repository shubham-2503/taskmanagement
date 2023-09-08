import 'dart:convert';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/common_widgets/round_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../View_model/fetchApiSrvices.dart';
import '../../../models/fetch_user_model.dart';
import '../../../models/project_model.dart';
import '../../../models/project_team_model.dart';
import '../../../utils/app_colors.dart';

class EditMyProject extends StatefulWidget {
  final Project project;
  const EditMyProject({super.key, required this.project});

  @override
  State<EditMyProject> createState() => _EditMyProjectState();
}

class _EditMyProjectState extends State<EditMyProject> {
  DateTime dueDate = DateTime.now();
  late Project project; // Define the Project variable
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController _activeController = TextEditingController();
  String _selectedStatus = "";
  List<dynamic> statuses = [];
  late String activeText;
  List<User> users = [];
  List<Team> teams = [];

  String getActiveText(bool? isActive) {
    if (isActive != null) {
      return isActive ? "Active" : "Inactive";
    } else {
      return "No value";
    }
  }

  Future<void> updateProject(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');
    final String projectId = widget.project.id; // Replace with actual project ID
    final String apiUrl = 'http://43.205.97.189:8000/api/Project/updateProject/$projectId';

    DateTime endDate = DateTime.parse(dateController.text!).toUtc();
    String? endDateString = endDate.toIso8601String();
    List<User> users = await fetchUsers();
    List<Team> teams = await fetchTeams();

    List<String> selectedMembers = List<String>.from((project.users ?? []).map((user) => user.userName));
    List<String> selectedTeams = List<String>.from((project.teams ?? []).map((team) => team.teamName));

    print("selectedTeams: $selectedTeams");
    print("selectedMembers: $selectedMembers");

    List<String> selectedMemberIds = [];
    for (String memberName in selectedMembers) {
      // Assuming you have a way to map member names to their IDs
      String memberId = getUserIdFromName(memberName, users); // Replace with actual logic
      selectedMemberIds.add(memberId);
    }

    List<String> selectedTeamIds = [];
    for (String teamName in selectedTeams) {
      // Assuming you have a way to map team names to their IDs
      String teamId = getTeamIdFromName(teamName, teams); // Replace with actual logic
      selectedTeamIds.add(teamId);
    }

    print("selectedTeamsIdds: $selectedTeamIds");
    print("selectedMembersids: $selectedMemberIds");


    final Map<String, dynamic> updatedProjectData = {
      "name": titleController.text,
      "description": descriptionController.text,
      "end_date": endDateString, // Replace with the actual end date
      "status": _selectedStatus,
      "active": activeText == "Active",
      "team_id":selectedTeamIds, // Replace with the actual team IDs
      "user_id": selectedMemberIds, // Replace with the actual user IDs
    };

    final headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $storedData',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(updatedProjectData),
      );

      if (response.statusCode == 200) {
        // Update successful
        final responseData = json.decode(response.body);
        print('Projects updated successfully: ${responseData['message']}');
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
                  onPressed: () async{
                    Navigator.pop(context); // Close the dialog
                    Navigator.pop(context);
                    Navigator.of(context).pop(true);
                    await fetchProjectDetails();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        print('Project updated successfully');
      } else {
        print('API Error: Status Code ${response.statusCode}');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to update Projects. Please try again later.'),
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
        // Handle error scenario
      }
    } catch (e) {
      print('Exception in updateProject: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Oops'),
            content: Text('Exception in UpdateProjects'),
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
  void initState() {
    super.initState();
    project = widget.project;
    _selectedStatus = project.status;
    activeText = getActiveText(project.active);
    _activeController.text = activeText;
    titleController.text = project.name;
    descriptionController.text = project.description ?? " ";
    dateController.text = formatDate(dueDate);
    fetchProjectDetails();
    fetchStatusData();
  }

  Future<void> fetchProjectDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://43.205.97.189:8000/api/Task/taskDetails?taskId=${widget.project.id}',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          final projectJson = data.firstWhere(
                (project) => project['id'] == widget.project.id,
            orElse: () => null,
          );

          if (projectJson != null) {
            final projectDetail = Project.fromJson(projectJson);

            setState(() {
              project = projectDetail;
            });
          }
        }
      } else {
        print('API Error: Status Code ${response.statusCode}');
        // Handle error scenario
      }
    } catch (e) {
      print('Exception in fetchProjectDetails: $e');
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
                (status) => status['name'] == project.status,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Project"),
      ),
      body: project != null
          ? Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text("Title",
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
                // Padding(
                //   padding: EdgeInsets.only(left: 10),
                //   child: Text("Description",
                //     style: TextStyle(
                //       color: AppColors.secondaryColor2,
                //       fontSize: 14,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                // Padding(
                //   padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                //   child: RoundTextField(
                //     hintText: project != null ? project.description : "No descriptions",
                //   ),
                // ),
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
                SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text("Active",
                        style: TextStyle(
                          color: AppColors.secondaryColor2,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 65,),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.only(left: 15, right: 65),
                        child: DropdownButton<String>(
                          value: activeText, // The selected value ("Active" or "Inactive")
                          onChanged: (newValue) {
                            setState(() {
                              activeText = newValue!;
                              _activeController.text = activeText; // Update the text field value
                            });
                          },
                          items: <String>['Active', 'Inactive']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30,),
                Center(
                  child: SizedBox(
                    height: 40,
                    width: 120,
                    child: RoundButton(title: "Update Project", onPressed: (){
                      updateProject(context);
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          : Center(
        child: CircularProgressIndicator(), // Show loading indicator while fetching
      ),
    );
  }
}

String formatDate(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd')
      .format(dateTime); // Format to show only the date
}
