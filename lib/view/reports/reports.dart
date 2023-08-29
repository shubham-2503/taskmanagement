import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Providers/filterProvider.dart';
import '../../models/report_model.dart';
import '../../utils/app_colors.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

import 'appliedFilterModal.dart';
import 'myFilter.dart';

class ReportScreen extends StatefulWidget {
  final VoidCallback refreshCallback;

  const ReportScreen({super.key, required this.refreshCallback});
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Task> filteredTasks = [];
  List<Task> tasks = []; // Define the Task class structure accordingly
  List<Project> projects = [];
  List<Project> filteredProjects = [];
  int totalTaskCount = 0;
  int completedTaskCount = 0;
  int pendingTaskCount = 0;
  int noProgressTaskCount = 0;
  int totalProjectCount = 0;
  int completedProjectCount = 0;
  int noProgressProjectCount = 0;
  int offTrackProjectCount = 0;

  final projectMap = <String, double>{
    "Completed": 0,
    "Pending": 0,
    "Off-Track": 0,
  };

  final legendsLabels = <String, String>{
    "Completed": "Completed legend",
    "Pending": "Pending legend",
    "Off-Track": "No Progress legend",
  };

  final dataMap = <String, double>{
    "Completed": 0,
    "Pending": 0,
    "No Progress": 0,
  };

  final colorList = <Color>[
    const Color(0xFF17C1E8),
    const Color(0xFFCB0C9F),
    const Color(0xFF8392AB),
  ];

  ChartType? _chartType = ChartType.disc;
  bool _showCenterText = true;
  double? _ringStrokeWidth = 32;
  double? _chartLegendSpacing = 32;
  bool _showLegends = false;

  int key = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<dynamic> fetchTaskReportData() async {
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

    final url = Uri.parse('http://43.205.97.189:8000/api/Common/taskReport?org_id=$orgId');

    final headers = {
      'Authorization': 'Bearer $storedData',
    };

    try {
      final response = await http.get(url, headers: headers);

      print("Status: ${response.statusCode}");
      print("body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        print("Failed to fetch the Task Report: ${response.statusCode}");
        throw Exception('Failed to fetch the Task Report');
      }
    } catch (e) {
      print("Failed to fetch the Task Report: $e");
      throw Exception('Failed to fetch the Task Report');
    }
  }

  Future<void> fetchData() async {
    print("APi calls");
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

    final Url =
        'http://43.205.97.189:8000/api/Common/taskReport?org_id=$orgId'; // Replace with your API base URL

    final queryParams = {
      'org_id': orgId,
    };

    // Print the query parameters in JSON format
    final queryParamsJson = jsonEncode(queryParams);
    print('Query Parameters: $queryParamsJson');

    final url = Uri.parse(Url).replace(queryParameters: queryParams);

    final headers = {
      'Authorization':
          'Bearer $storedData', // Add the Authorization header with the JWT token
    };

    try {
      final response = await http.get(
        url,
        headers: headers, // Include the headers in the request
      );
      print("StatusCode: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        List<Task> tasks = [];
        if (jsonData['tasks'] != null && jsonData['tasks'] is List) {
          for (var taskData in jsonData['tasks']) {
            Task task = Task(
              id: taskData['taskId'] ?? '',
              taskName: taskData['task_name'] ?? '',
              status: taskData['status'] ?? '',
              createdBy: taskData['created_by'] ?? '',
              description: taskData['description'] ?? '',
              priority: taskData['priority'] ?? '',
              dueDate: taskData['dueDate'] != null
                  ? DateTime.parse(taskData['dueDate'])
                  : DateTime.now(),
            );
            tasks.add(task);
          }
        }

        List<Project> projects = [];
        if (jsonData['projects'] != null && jsonData['projects'] is List) {
          for (var projectData in jsonData['projects']) {
            Project project = Project(
                id: projectData['id'] ?? '',
                taskName: projectData['task_name'] ?? '',
                createdBy: projectData['created_by'] ?? '',
                status: projectData['status'] ?? '',
                dueDate: projectData['dueDate'] != null
                    ? DateTime.parse(projectData['dueDate'])
                    : DateTime.now(),
                type: projectData['type'] ?? '');
            projects.add(project);
          }
        }

        int totalTaskCount = tasks.length;
        int completedTaskCount =
            tasks.where((task) => task.status == 'Completed').length;
        int pendingTaskCount =
            tasks.where((task) => task.status == 'ToDo').length;
        int noProgressTaskCount =
            tasks.where((task) => task.status == 'InProgress').length;

        int totalProjectCount = projects.length;
        int completedProjectCount =
            projects.where((project) => project.status == 'Completed').length;
        int offTrackProjectCount =
            projects.where((project) => project.status == 'ToDo').length;
        int noProgressProjectCount =
            projects.where((project) => project.status == 'InProgress').length;

        // Update the projectMap with calculated values
        projectMap["Completed"] = completedProjectCount.toDouble();
        projectMap["Pending"] =
            noProgressProjectCount.toDouble(); // Calculate the pending count
        projectMap["Off-Track"] =
            offTrackProjectCount.toDouble(); // Calculate the off-track count

        // Update the projectMap with calculated values
        dataMap["Completed"] = completedTaskCount.toDouble();
        dataMap["Pending"] =
            pendingTaskCount.toDouble(); // Calculate the pending count
        dataMap["No Progress"] =
            noProgressTaskCount.toDouble(); // Calculate the off-track count

        setState(() {
          this.totalTaskCount = totalTaskCount;
          this.completedTaskCount = completedTaskCount;
          this.pendingTaskCount = pendingTaskCount;
          this.noProgressTaskCount = noProgressTaskCount;

          this.totalProjectCount = totalProjectCount;
          this.completedProjectCount = completedProjectCount;
          this.offTrackProjectCount = offTrackProjectCount;
          this.noProgressProjectCount = noProgressProjectCount;

          tasks = tasks; // Assign the fetched tasks to the widget's tasks list
          filteredTasks = tasks;
          projects =
              projects; // Assign the fetched projects to the widget's projects list
          filteredProjects = projects;
        });
      } else if (response.statusCode == 401) {
        print("Failed to fetched the Reports: ${response.statusCode}");
      } else if (response.statusCode == 403) {
        // Handle forbidden error
        print("Failed to fetched the Reports: ${response.statusCode}");
      } else {
        // Handle other errors
        print("Failed to fetched the Reports: ${response.statusCode}");
      }
    } catch (e) {
      // Handle network or other errors
      print("Failed to fetched the Reports: $e");
    }
  }

  Future<void> _downloadReport(BuildContext context) async {
    try {
      final reportData = await fetchTaskReportData();
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

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text(reportData.toString()), // Adjust as per your report structure
            );
          },
        ),
      );

      // Save the PDF file
      final directory = await getTemporaryDirectory();
      final filePath = path.join(directory.path, 'report.pdf');
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Show a confirmation dialog
      final confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Download Report'),
          content: Text('Are you sure you want to download the report?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Yes'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        // Download the report using the export API endpoint
        final exportResponse = await http.post(
          Uri.parse('http://43.205.97.189:8000/api/Export/reportExport'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $storedData'},
          body: jsonEncode(reportData),
        );

        print("Status: ${exportResponse.statusCode}");
        print("body: ${exportResponse.body}");

        if (exportResponse.statusCode == 200) {
          final exportFilePath = path.join(directory.path, 'exported_report.pdf');
          final exportFile = File(exportFilePath);
          await exportFile.writeAsBytes(exportResponse.bodyBytes);

          // Show a dialog with a download link for the exported report
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Download Exported Report'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('The exported report has been downloaded.'),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        OpenFile.open(exportFile.path);
                        // OpenFile.open(file.path);
                      },
                      child: Text('Open Exported Report'),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          print('Failed to export report: ${exportResponse.statusCode}');
        }
      }
    } catch (e) {
      print('Error downloading report: $e');
    }
  }

  void _shareReport() {}

  @override
  Widget build(BuildContext context) {
    // print("Reports Section:");
    final chart = Container(
      height: 150,
      width: 400,
      child: PieChart(
        key: ValueKey(key),
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: _chartLegendSpacing!,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: _chartType!,
        centerText: _showCenterText ? "Tasks" : null,
        ringStrokeWidth: _ringStrokeWidth!,
        chartValuesOptions: ChartValuesOptions(
          showChartValues: true,
        ),
        legendOptions: LegendOptions(showLegends: false),
      ),
    );
    final chart2 = Container(
      height: 150,
      width: 400,
      child: PieChart(
        key: ValueKey(key),
        dataMap: projectMap,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: _chartLegendSpacing!,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: _chartType!,
        centerText: _showCenterText ? "Projects" : null,
        ringStrokeWidth: _ringStrokeWidth!,
        legendOptions: LegendOptions(showLegends: false),
      ),
    );

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.primaryColor1,
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
            ),
            iconTheme: IconThemeData(
              color: AppColors.primaryColor2,
            ),
            title: Text(
              "Reports",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.secondaryColor2,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontStyle: FontStyle.italic),
            ),
            actions: [
              IconButton(
                onPressed: ()async {
                  await _downloadReport(context);
                },
                icon: Icon(
                  Icons.download,
                  color: AppColors.secondaryColor2,
                ),
              ),
              IconButton(
                onPressed: _shareReport,
                icon: Icon(
                  Icons.share,
                  color: AppColors.secondaryColor2,
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: SingleChildScrollView(
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final appliedFilters = await showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) => MyFilterOptionsModal(),
                      );

                      if (appliedFilters != null) {
                        print(appliedFilters);
                        await showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return SeparateSectionsModal(data: appliedFilters);
                          },
                        );
                      }
                    },
                    child: Image.asset(
                      "assets/images/menu.png",
                      width: 40,
                      height: 40,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              SingleChildScrollView(
                  child: Column(children: [
                SizedBox(
                  height: 50,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            "Task Information",
                            style: TextStyle(
                                color: AppColors.secondaryColor2,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                fontStyle: FontStyle.italic),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 170,
                            margin: EdgeInsets.only(left: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xffE1E3E9),
                                border:
                                    Border.all(color: const Color(0xffE1E3E9))),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Total Tasks",
                                      style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: const Color(0xffE1E3E9),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      child: Center(
                                        child: Text(totalTaskCount.toString()),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Divider(
                                  height: 0,
                                  color: AppColors.blackColor,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Completed\nTask",
                                      style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: const Color(0xffDEE5FF),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      child: Center(
                                        child:
                                            Text(completedTaskCount.toString()),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Divider(
                                  height: 0,
                                  color: AppColors.blackColor,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Pending Tasks",
                                      style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: const Color(0xffDEE5FF),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      child: Center(
                                        child:
                                            Text(pendingTaskCount.toString()),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Divider(
                                  height: 0,
                                  color: AppColors.blackColor,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "No Progress",
                                      style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: const Color(0xffDEE5FF),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      child: Center(
                                        child: Text(
                                            noProgressTaskCount.toString()),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        children: [
                          Text(
                            "Project Information",
                            style: TextStyle(
                                color: AppColors.secondaryColor2,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                fontStyle: FontStyle.italic),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 170,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            margin: EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xffE1E3E9),
                                border:
                                    Border.all(color: const Color(0xffE1E3E9))),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Total Projects",
                                      style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: const Color(0xffE1E3E9),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      child: Center(
                                        child:
                                            Text(totalProjectCount.toString()),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Divider(
                                  height: 0,
                                  color: AppColors.blackColor,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Completed\nProjects",
                                      style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: const Color(0xffDEE5FF),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      child: Center(
                                        child: Text(
                                            completedProjectCount.toString()),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Divider(
                                  height: 0,
                                  color: AppColors.blackColor,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Off Track",
                                      style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: const Color(0xffDEE5FF),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      child: Center(
                                        child: Text(
                                            offTrackProjectCount.toString()),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Divider(
                                  height: 0,
                                  color: AppColors.blackColor,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "No Progress",
                                      style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: const Color(0xffDEE5FF),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      child: Center(
                                        child: Text(
                                            noProgressProjectCount.toString()),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Reports",
                  style: TextStyle(
                      color: AppColors.secondaryColor2,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      fontStyle: FontStyle.italic),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 50,
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 55),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(dataMap.length, (index) {
                        final key = dataMap.keys.elementAt(index);
                        return Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorList[index],
                              ),
                            ),
                            Text(
                              '$key',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            if (index != dataMap.length - 1)
                              SizedBox(width: 10),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                LayoutBuilder(
                  builder: (_, constraints) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 32, horizontal: 10),
                            child: Column(
                              children: [
                                Text(
                                  "Tasks Reports",
                                  style: TextStyle(
                                      color: AppColors.primaryColor2,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic),
                                ),
                                chart,
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 32, horizontal: 10),
                            child: Column(
                              children: [
                                Text(
                                  "Project Reports",
                                  style: TextStyle(
                                      color: AppColors.primaryColor2,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic),
                                ),
                                chart2,
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 20),
                //         if (filteredTasks.isNotEmpty)
                //           Column(
                //             crossAxisAlignment: CrossAxisAlignment.center,
                //             children: [
                //               ExpansionTile(
                //                 title: Text("Task Reports", style: TextStyle(
                //                   color: AppColors.secondaryColor1,
                //                   fontWeight: FontWeight.w600,
                //                   fontSize: 15,
                //                   fontStyle: FontStyle.italic,
                //                 ),),
                //                 children: [
                //               SizedBox(height: 10),
                //               ListView.builder(
                //                 shrinkWrap: true,
                //                 itemCount: filteredTasks.length,
                //                 itemBuilder: (context, index) {
                //                   final task = filteredTasks[index];
                //                   Color statusColor = Colors.grey; // Default color
                //                   switch (task.status) {
                //                     case 'InProgress':
                //                       statusColor = Colors.blue;
                //                       break;
                //                     case 'Completed':
                //                       statusColor = Colors.red;
                //                       break;
                //                     case 'ToDo':
                //                       statusColor = AppColors.primaryColor2;
                //                       break;
                //                     case 'transferred':
                //                       statusColor = Colors.black54;
                //                       break;
                //                   // Add more cases for different statuses if needed
                //                   }
                //                   return Card(
                //                     child: ListTile(
                //                       title: Center(
                //                         child: Text(
                //                           "Task: ${task.taskName}",
                //                           style: TextStyle(
                //                             color: AppColors.secondaryColor2,
                //                             fontSize: 15,
                //                             fontWeight: FontWeight.bold,
                //                           ),
                //                         ),
                //                       ),
                //                       subtitle: Row(
                //                         children: [
                //                           Text(formatDate(task.dueDate)),
                //                           Spacer(),
                //                           Text(task.createdBy),
                //                         ],
                //                       ),
                //                     ),
                //                   );
                //                 },
                //               ),
                //             ],
                //           ),
                //         SizedBox(height: 20),
                //         if (filteredProjects.isNotEmpty)
                //           Column(
                //             crossAxisAlignment: CrossAxisAlignment.center,
                //             children: [
                //               ExpansionTile(
                //                 title: Text("Project Reports", style: TextStyle(
                //                   color: AppColors.secondaryColor1,
                //                   fontWeight: FontWeight.w600,
                //                   fontSize: 15,
                //                   fontStyle: FontStyle.italic,
                //                 ),),
                //                 children: [
                //               SizedBox(height: 10),
                //               ListView.builder(
                //                 shrinkWrap: true,
                //                 itemCount: filteredProjects.length,
                //                 itemBuilder: (context, index) {
                //                   final project = filteredProjects[index];
                //                   Color statusColor = Colors.grey; // Default color
                //                   switch (project.status) {
                //                     case 'InProgress':
                //                       statusColor = Colors.blue;
                //                       break;
                //                     case 'Completed':
                //                       statusColor = Colors.red;
                //                       break;
                //                     case 'ToDo':
                //                       statusColor = AppColors.primaryColor2;
                //                       break;
                //                     case 'transferred':
                //                       statusColor = Colors.black54;
                //                       break;
                //                   // Add more cases for different statuses if needed
                //                   }
                //                   return Card(
                //                     child: ListTile(
                //                       title: Center(child: Text("Project: ${project.taskName}",style: TextStyle(
                //                         color: AppColors.secondaryColor2,
                //                         fontSize: 15,fontWeight: FontWeight.bold
                //                       ),)),
                //                       subtitle: Row(
                //                         children: [
                //                           Text(formatDate(project.dueDate)),
                //                           Spacer(),
                //                           Text(project.createdBy,),
                //                         ],
                //                       ),
                //                     ),
                //                   );
                //                 },
                //               ),
                //             ],
                //           ),
                //       ])
                // ])
              ]))
            ]),
          ),
        ));
  }
}

String formatDate(DateTime date) {
  final formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(date);
}
