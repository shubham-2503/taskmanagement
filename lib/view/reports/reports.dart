import 'dart:io';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/common_widgets/round_gradient_button.dart';
import 'package:f_datetimerangepicker/f_datetimerangepicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pie_chart/pie_chart.dart';
import '../../utils/app_colors.dart';
import 'package:path/path.dart' as path;

enum ReportType {
  Day,
  Weekly,
  Monthly,
  Yearly,
}

enum ViewType {
  Timeline,
  Board,
  Table,
}

enum CategoryType{
  MyReports,
  TeamReports,
}

enum LegendShape{
  circle,
  rectangle,
}

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  ReportType _selectedReportType = ReportType.Day;
  CategoryType _selectedCategoryType = CategoryType.MyReports;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  final projectMap = <String, double>{
    "Completed": 15,
    "Pending": 15,
    "Off-Track": 7,
  };

  final legendsLabels = <String, String>{
    "Completed": "Completed legend",
    "Pending": "Pending legend",
    "Off-Track": "No Progress legend",
  };

  final dataMap = <String, double>{
    "Completed": 15,
    "Pending": 15,
    "No Progress": 7,
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

  Widget _buildReportTypeText() {
    switch (_selectedReportType) {
      case ReportType.Day:
        return Text(
          "Day Reports",
          style: TextStyle(
            color: AppColors.secondaryColor2,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            fontStyle: FontStyle.italic,
          ),
        );
      case ReportType.Weekly:
        return Text(
          "Weekly Reports",
          style: TextStyle(
            color: AppColors.secondaryColor2,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            fontStyle: FontStyle.italic,
          ),
        );
      case ReportType.Monthly:
        return Text(
          "Monthly Reports",
          style: TextStyle(
            color: AppColors.secondaryColor2,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            fontStyle: FontStyle.italic,
          ),
        );
      case ReportType.Yearly:
        return Text(
          "Yearly Reports",
          style: TextStyle(
            color: AppColors.secondaryColor2,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            fontStyle: FontStyle.italic,
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }


  Future<void> _downloadReport() async {
    final pdf = pw.Document();

    // Add content to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text('This is the report content'),
          );
        },
      ),
    );

    // Save the PDF file
    final directory = await getTemporaryDirectory();
    final filePath = path.join(directory.path, 'report.pdf');
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Show a dialog with a download link
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Download Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('The report has been downloaded.'),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  OpenFile.open(file.path);
                },
                child: Text('Open Report'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareReport() {
    // Add logic to share the report
    // You can use a package like 'share' to share the report file or content
  }

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(
                color: AppColors.secondaryColor2,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontStyle: FontStyle.italic),
          ),
          actions: [
            IconButton(
              onPressed: _downloadReport,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    height: 35,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: AppColors.primaryG),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CategoryType>(
                        value: _selectedCategoryType,
                        items: CategoryType.values
                            .map((name) => DropdownMenuItem(
                          value: name,
                          child: Text(
                            name.toString().split('.').last,
                            style: const TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 14,
                            ),
                          ),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryType = value!;
                          });
                        },
                        icon: Icon(
                          Icons.expand_more,
                          color: AppColors.whiteColor,
                        ),
                        hint: Text(
                          "My Reports",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          height: 35,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: AppColors.primaryG),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ReportType>(
                              value: _selectedReportType,
                              items: ReportType.values
                                  .map((name) => DropdownMenuItem(
                                        value: name,
                                        child: Text(
                                          name.toString().split('.').last,
                                          style: const TextStyle(
                                            color: AppColors.blackColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedReportType = value!;
                                });
                              },
                              icon: Icon(
                                Icons.expand_more,
                                color: AppColors.blackColor,
                              ),
                              hint: Text(
                                "Day",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(width: 10,),
                  SizedBox(
                    height: 35,
                    width: 70,
                    child: RoundButton(title: "Filter", onPressed: (){
                      DateTimeRangePicker(
                          startText: "From",
                          endText: "To",
                          doneText: "Yes",
                          cancelText: "Cancel",
                          interval: 5,
                          initialStartTime: DateTime.now(),
                          initialEndTime: DateTime.now().add(Duration(days: 20)),
                          mode: DateTimeRangePickerMode.dateAndTime,
                          minimumTime: DateTime.now().subtract(Duration(days: 5)),
                          maximumTime: DateTime.now().add(Duration(days: 25)),
                          use24hFormat: true,
                          onConfirm: (start, end) {
                            print("Start: $start");
                            print("End: $end");
                          }).showPicker(context);
                    }),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              SingleChildScrollView(
                child: Column(
                    children: [
                      _buildReportTypeText(),
                     SizedBox(height: 50,),
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
                            SizedBox(height: 10,),
                            Container(
                              width: 170,
                              margin: EdgeInsets.only(left: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color(0xffE1E3E9),
                                  border: Border.all(color: const Color(0xffE1E3E9))),
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
                                            borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        child: Center(
                                          child: Text("10"),
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
                                            borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        child: Center(
                                          child: Text("0"),
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
                                            borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        child: Center(
                                          child: Text("6"),
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
                                            borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        child: Center(
                                          child: Text("6"),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 20,),
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
                          SizedBox(height: 10,),
                          Container(
                            width: 170,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                            margin: EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xffE1E3E9),
                                border: Border.all(color: const Color(0xffE1E3E9))),
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
                                          borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      child: Center(
                                        child: Text("10"),
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
                                          borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      child: Center(
                                        child: Text("0"),
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
                                          borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      child: Center(
                                        child: Text("6"),
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
                                          borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      child: Center(
                                        child: Text("6"),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ],),
                    ],
                  ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    Text("Reports",
                      style: TextStyle(
                          color: AppColors.secondaryColor2,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          fontStyle: FontStyle.italic),),
                      SizedBox(height: 20,),
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
                                  if (index != dataMap.length - 1) SizedBox(width: 10),
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
                                  margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 10),
                                  child: Column(
                                    children: [
                                      Text("Tasks Reports",
                                        style: TextStyle(
                                            color: AppColors.primaryColor2,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            fontStyle: FontStyle.italic),),
                                      chart,
                                    ],
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 3,
                                fit: FlexFit.tight,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 10),
                                  child: Column(
                                    children: [
                                      Text("Project Reports",
                                        style: TextStyle(
                                            color: AppColors.primaryColor2,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            fontStyle: FontStyle.italic),),
                                      chart2,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ])
              )]),
              ),
    ));
  }
}
