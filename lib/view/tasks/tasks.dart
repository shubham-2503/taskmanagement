import 'dart:convert';
import 'package:Taskapp/Providers/taskProvider.dart';
import 'package:Taskapp/view/tasks/myTasks.dart';
import 'package:Taskapp/view/tasks/teamTask.dart';
import 'package:Taskapp/view/tasks/widgets/mytasksFilter_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_widgets/round_textfield.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/filter_options_modal.dart';
import '../dashboard/dashboard_screen.dart';
import 'createdbyMe.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin{
  String selectedOption = 'MyTask';
  late TabController _tabController;

  void refreshScreen() {
    setState(() {}); // This triggers a rebuild of the widget
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            selectedOption = 'MyTask';
            break;
          case 1:
            selectedOption = 'TeamTask';
            break;
          case 2:
            selectedOption = 'CreatedByMe';
            break;
        }
      });
    });
    fetchAndRefreshTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  Map<String, String?> selectedFilters = {};

  Widget getCategoryWidget() {
    switch (selectedOption) {
      case 'MyTask':
        return MyTaskScreen(refreshCallback: refreshScreen, selectedFilters: selectedFilters,);
      case 'TeamTask':
        return TeamTaskScreen(refreshCallback: refreshScreen, selectedFilters: selectedFilters,);
      case 'CreatedByMe':
        return CreatedByMe(refreshCallback: refreshScreen, selectedFilters: selectedFilters,);
      default:
        return MyTaskScreen(refreshCallback: refreshScreen, selectedFilters: selectedFilters,);
    }
  }

  Future<void> fetchAndRefreshTasks() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId = prefs.getString("selectedOrgId");
      if (orgId == null) {
        orgId = prefs.getString('org_id') ?? "";
      }

      Uri createdByMeUri =
      Uri.parse('http://43.205.97.189:8000/api/Task/createdByMe?org_id=$orgId');
      Uri myTasksUri =
      Uri.parse('http://43.205.97.189:8000/api/Task/myTasks?org_id=$orgId');
      Uri teamsTaskUri =
      Uri.parse('http://43.205.97.189:8000/api/Task/teamsTask?org_id=$orgId');

      if (selectedFilters.containsKey('start_date')) {
        final startDate = selectedFilters['start_date'];
        print('startDate: $startDate'); // Add this line for debugging
        if (startDate != null) {
          createdByMeUri = createdByMeUri.replace(queryParameters: {
            ...createdByMeUri.queryParameters,
            'start_date': startDate,
          });
          myTasksUri = myTasksUri.replace(queryParameters: {
            ...myTasksUri.queryParameters,
            'start_date': startDate,
          });
          teamsTaskUri = teamsTaskUri.replace(queryParameters: {
            ...teamsTaskUri.queryParameters,
            'start_date': startDate,
          });
        }
      }

      if (selectedFilters.containsKey('end_date')) {
        final endDate = selectedFilters['end_date'];
        print('dueDate: $endDate'); // Add this line for debugging
        if (endDate != null) {
          createdByMeUri = createdByMeUri.replace(queryParameters: {
            ...createdByMeUri.queryParameters,
            'due_Date': endDate,
          });
          myTasksUri = myTasksUri.replace(queryParameters: {
            ...myTasksUri.queryParameters,
            'due_Date': endDate,
          });
          teamsTaskUri = teamsTaskUri.replace(queryParameters: {
            ...teamsTaskUri.queryParameters,
            'due_Date': endDate,
          });
        }
      }

      if (selectedFilters.containsKey('priority')) {
        createdByMeUri = createdByMeUri.replace(queryParameters: {
          ...createdByMeUri.queryParameters,
          'priority': selectedFilters['priority']!,
        });
        myTasksUri = myTasksUri.replace(queryParameters: {
          ...myTasksUri.queryParameters,
          'priority': selectedFilters['priority']!,
        });
        teamsTaskUri = teamsTaskUri.replace(queryParameters: {
          ...teamsTaskUri.queryParameters,
          'priority': selectedFilters['priority']!,
        });
      }

      if (selectedFilters.containsKey('status')) {
        createdByMeUri = createdByMeUri.replace(queryParameters: {
          ...createdByMeUri.queryParameters,
          'status': selectedFilters['status']!,
        });
        myTasksUri = myTasksUri.replace(queryParameters: {
          ...myTasksUri.queryParameters,
          'status': selectedFilters['status']!,
        });
        teamsTaskUri = teamsTaskUri.replace(queryParameters: {
          ...teamsTaskUri.queryParameters,
          'status': selectedFilters['status']!,
        });
      }

      final createdByMeResponse = await http.get(
        createdByMeUri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $storedData'},
      );

      final myTasksResponse = await http.get(
        myTasksUri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $storedData'},
      );

      final teamsTaskResponse = await http.get(
        teamsTaskUri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $storedData'},
      );

      print('API Error: ${createdByMeResponse.statusCode}, ${myTasksResponse.statusCode}, ${teamsTaskResponse.statusCode}');
      print("Api response: ${createdByMeResponse.body}. ${myTasksResponse.body},${teamsTaskResponse.body}");

      if (createdByMeResponse.statusCode == 200 &&
          myTasksResponse.statusCode == 200 &&
          teamsTaskResponse.statusCode == 200) {
        final List<dynamic> createdByMeData =
        jsonDecode(createdByMeResponse.body);
        final List<dynamic> myTasksData = jsonDecode(myTasksResponse.body);
        final List<dynamic> teamsTaskData =
        jsonDecode(teamsTaskResponse.body);

        final List<Task> tasks = [
          ...createdByMeData.map((data) => Task.fromJson(data)),
          ...myTasksData.map((data) => Task.fromJson(data)),
          ...teamsTaskData.map((data) => Task.fromJson(data)),
        ];

        // Create a new map with the updated values
        Map<String, String?> updatedFilters = Map.from(selectedFilters);

        final taskProvider =
        Provider.of<TaskProvider>(context, listen: false);
        taskProvider.setTasks(tasks);

        setState(() {
          selectedFilters = updatedFilters; // Update the selectedFilters map
        });
      } else {
        print(
            'API Error: ${createdByMeResponse.statusCode}, ${myTasksResponse.statusCode}, ${teamsTaskResponse.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DashboardScreen()));
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: AppColors.primaryColor2,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(height: 50,width: 150,child:  RoundTextField(
                onChanged: (query) {}, hintText: 'Search',
                icon: "assets/images/search_icon.png",
              ),),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Text(
                  'My Task',
                  style: TextStyle(
                    color: AppColors.secondaryColor2, // Change the text color as needed
                    fontSize: 13, // Change the font size as needed
                    fontWeight: FontWeight.bold, // Change the font weight as needed
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Team Task',
                  style: TextStyle(
                    color: AppColors.secondaryColor2, // Change the text color as needed
                    fontSize: 13, // Change the font size as needed
                    fontWeight: FontWeight.bold, // Change the font weight as needed
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Created By Me',
                  style: TextStyle(
                    color: AppColors.secondaryColor2, // Change the text color as needed
                    fontSize: 13, // Change the font size as needed
                    fontWeight: FontWeight.bold, // Change the font weight as needed
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Consumer2<TaskProvider,TasksFilterNotifier>(
          builder: (context, taskProvider,filterProvider, child) {
            final tasks = taskProvider.tasks; // Get the list of tasks from TaskProvider
            final selectedFilters = filterProvider.selectedFilters;
            return Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        MyTaskScreen(refreshCallback: refreshScreen, selectedFilters: selectedFilters),
                        TeamTaskScreen(refreshCallback: refreshScreen, selectedFilters: selectedFilters),
                        CreatedByMe(refreshCallback: refreshScreen, selectedFilters: selectedFilters),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  Map<String, String?> selectedOption = await showModalBottomSheet(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return FilterOptionsModal(
                                        onApplyFilters: (Map<String, String?> selectedFilters) {
                                          print("Selected Filters: $selectedFilters");
                                          filterProvider.updateFilters(selectedFilters); // Update filters using Provider
                                          refreshScreen();
                                          setState(() {
                                            fetchAndRefreshTasks();
                                          });
                                        },
                                      );
                                    },
                                  );
                                  if (selectedOption != null) {
                                    print("SelectedOption: $selectedOption");
                                  }
                                },
                                icon: Icon(Icons.filter_alt_sharp, color: AppColors.secondaryColor2),
                              ),
                              Text(
                                "Filters",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondaryColor2,
                                ),
                              ),
                              SizedBox(width: 10,),
                              if (selectedFilters.isNotEmpty) // Show only if filters are selected
                                SelectedFiltersDisplay(
                                  selectedFilters: selectedFilters,
                                  onRemoveFilter: (filterKey) {
                                    setState(() {
                                      selectedFilters.remove(filterKey); // Remove the filter
                                      Navigator.pushReplacement(context, PageRouteBuilder(
                                        pageBuilder: (_, __, ___) => TaskScreen(), // Replace with your screen widget
                                        transitionsBuilder: (_, anim, __, child) {
                                          return FadeTransition(
                                            opacity: anim,
                                            child: child,
                                          );
                                        },
                                      ));
                                    });
                                    // Call your function to update tasks based on filters
                                    fetchAndRefreshTasks();
                                  },
                                ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );},),
      ),
    );
  }
}

class SelectedFiltersDisplay extends StatelessWidget {
  final Map<String, String?> selectedFilters;
  final Function(String) onRemoveFilter;

  SelectedFiltersDisplay({
    required this.selectedFilters,
    required this.onRemoveFilter,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> filterWidgets = [];

    // Loop through the selected filters and create a display widget for each
    selectedFilters.forEach((key, value) {
      if (value != null && value.isNotEmpty) { // Check if value is not null and not empty
        filterWidgets.add(
          Container(
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$value',
                  style: TextStyle(fontSize: 12),
                ),
                IconButton(
                  onPressed: () {
                    onRemoveFilter(key); // Call the callback to remove the filter
                  },
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
        );
      }
    });
    return Row(
      children: filterWidgets,
    );
  }
}