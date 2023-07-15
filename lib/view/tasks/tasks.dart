import 'package:Taskapp/view/tasks/editTask.dart';
import 'package:Taskapp/view/tasks/taskDetails.dart';
import 'package:flutter/material.dart';
import '../../common_widgets/round_button.dart';
import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';
import '../../utils/app_colors.dart';

enum ViewOption {
  Table,
  Board,
}

enum ReviewOption {
  All,
  Open,
  InProgress,
  Transferred,
  Completed,
}

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  ViewOption? selectedViewOption = ViewOption.Board;
  ReviewOption? selectedReviewOption = ReviewOption.All;
  List<Task> filteredMyTasks = [];
  List<Task> filteredTeamTasks = [];
  static const int MyTasks = 0;
  static const int TeamTasks = 1;
  int _selectedType = MyTasks;
  List<String> selectedFilters = [];
  bool _expanded = false;

  List<Task> mytasks = [
    Task(
      title: 'Task 1',
      project: 'Alpha',
      assignedTo: 'John',
      assignedTeam: 'Team A',
      status: 'In Progress',
      description: 'This is Task 1 assigned to John',
      reviewOption: ReviewOption.InProgress,
      priority: 'High',
    ),
    Task(
      title: 'Task 2',
      project: 'Gamma',
      assignedTo: 'John',
      assignedTeam: 'Team B',
      status: 'Open',
      description: 'This is Task 2 assigned to John',
      reviewOption: ReviewOption.Open,
      priority: 'Medium',
    ),
    // Add more dummy tasks if needed
  ];

  List<Task> teamTasks = [
    Task(
      title: 'Task 1',
      project: 'Alpha',
      assignedTo: 'Emily',
      assignedTeam: 'Team A',
      status: 'In Progress',
      description: 'This is Task 1 assigned to John',
      reviewOption: ReviewOption.InProgress,
      priority: 'High',
    ),
    Task(
      title: 'Task 2',
      project: 'Gamma',
      assignedTo: 'John',
      assignedTeam: 'Team B',
      status: 'Open',
      description: 'This is Task 2 assigned to John',
      reviewOption: ReviewOption.Open,
      priority: 'Medium',
    ),
    Task(
      title: 'Task 3',
      project: 'Project C',
      assignedTo: 'Johnson',
      assignedTeam: 'Team A',
      status: 'In Progress',
      description: 'This is Task 3 assigned to Alice',
      reviewOption: ReviewOption.InProgress,
      priority: 'High',
    ),
    Task(
      title: 'Task 4',
      project: 'Project B',
      assignedTo: 'Bob',
      assignedTeam: 'Team B',
      status: 'Completed',
      description: 'This is Task 4 assigned to Bob',
      reviewOption: ReviewOption.Completed,
      priority: 'Low',
    ),
  ];

  List<Task> filteredTasks = [];

  void filterTasks() {
    if (selectedReviewOption == ReviewOption.All) {
      filteredMyTasks = List.from(mytasks);
      filteredTeamTasks = List.from(teamTasks);
    } else {
      filteredMyTasks = mytasks
          .where((task) => task.reviewOption == selectedReviewOption)
          .toList();
      filteredTeamTasks = teamTasks
          .where((task) => task.reviewOption == selectedReviewOption)
          .toList();
    }
    filteredTasks = filteredTasks.where((task) {
      bool matchesFilter = true;
      for (String filter in selectedFilters) {
        if (!task.title.contains(filter) &&
            !task.project.contains(filter) &&
            !task.assignedTo.contains(filter) &&
            !task.status.contains(filter) &&
            !task.description.contains(filter)) {
          matchesFilter = false;
          break;
        }
      }
      return matchesFilter;
    }).toList();

    // Function to get the priority value
    int getPriorityValue(String priority) {
      switch (priority) {
        case 'Critical':
          return 0;
        case 'High':
          return 1;
        case 'Medium':
          return 2;
        case 'Low':
          return 3;
        default:
          return 4; // For any other values, maintain their original order
      }
    }

    filteredTasks.sort((a, b) {
      int priorityA = getPriorityValue(a.priority);
      int priorityB = getPriorityValue(b.priority);

      return priorityA.compareTo(priorityB);
    });

    filteredTasks.sort((a, b) => a.project.compareTo(b.project));
  }

  void _showDialog() {
    List<bool> _checkboxValues = [false, false];
    List<bool> _checkstatusValues = [false, false, false, false];
    List<bool> _checkpriorityValues = [false, false, false];
    bool _statusExpanded = false;
    bool _priorityExpanded = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Center(child: Text('Sort By')),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    CheckboxListTile(
                      value: _checkboxValues[0],
                      onChanged: (value) {
                        setState(() {
                          _checkboxValues[0] = value!;
                          _statusExpanded = value; // Expand or collapse the sub-options
                        });
                      },
                      title: Text(
                        'Status',
                        style: TextStyle(
                          color: AppColors.secondaryColor2,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (_statusExpanded) ...[
                      SizedBox(height: 8),
                      CheckboxListTile(
                        value: _checkstatusValues[0],
                        onChanged: (value) {
                          setState(() {
                            _checkstatusValues[0] = value!;
                          });
                        },
                        title: Text(
                          'Completed',
                          style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      CheckboxListTile(
                        value: _checkstatusValues[1],
                        onChanged: (value) {
                          setState(() {
                            _checkstatusValues[1] = value!;
                          });
                        },
                        title: Text(
                          'Transferred',
                          style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      CheckboxListTile(
                        value: _checkstatusValues[2],
                        onChanged: (value) {
                          setState(() {
                            _checkstatusValues[2] = value!;
                          });
                        },
                        title: Text(
                          'In Progress',
                          style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      CheckboxListTile(
                        value: _checkstatusValues[3],
                        onChanged: (value) {
                          setState(() {
                            _checkstatusValues[3] = value!;
                          });
                        },
                        title: Text(
                          'Open',
                          style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 4),
                    CheckboxListTile(
                      value: _checkboxValues[1],
                      onChanged: (value) {
                        setState(() {
                          _checkboxValues[1] = value!;
                          _priorityExpanded =
                              value; // Expand or collapse the sub-options
                        });
                      },
                      title: Text(
                        'Priority',
                        style: TextStyle(
                          color: AppColors.secondaryColor2,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (_priorityExpanded) ...[
                      SizedBox(height: 8),
                      CheckboxListTile(
                        value: _checkpriorityValues[0],
                        onChanged: (value) {
                          setState(() {
                            _checkpriorityValues[0] = value!;
                          });
                        },
                        title: Text(
                          'High',
                          style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      CheckboxListTile(
                        value: _checkpriorityValues[1],
                        onChanged: (value) {
                          setState(() {
                            _checkpriorityValues[1] = value!;
                          });
                        },
                        title: Text(
                          'Medium',
                          style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      CheckboxListTile(
                        value: _checkpriorityValues[2],
                        onChanged: (value) {
                          setState(() {
                            _checkpriorityValues[2] = value!;
                          });
                        },
                        title: Text(
                          'Low',
                          style: TextStyle(
                            color: AppColors.grayColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
                TextButton(
                  child: Text('Apply'),
                  onPressed: () {
                    // Handle the selected options
                    bool statusSelected = _checkboxValues[0];
                    bool prioritySelected = _checkboxValues[1];
                    List<String> selectedStatusOptions = [];
                    List<String> selectedPriorityOptions = [];

                    if (statusSelected) {
                      if (_checkstatusValues[0]) {
                        selectedStatusOptions.add('Completed');
                      }
                      if (_checkstatusValues[1]) {
                        selectedStatusOptions.add('Transferred');
                      }
                      if (_checkstatusValues[2]) {
                        selectedStatusOptions.add('In Progress');
                      }
                      if (_checkstatusValues[3]) {
                        selectedStatusOptions.add('Open');
                      }
                    }

                    if (prioritySelected) {
                      if (_checkpriorityValues[0]) {
                        selectedPriorityOptions.add('High');
                      }
                      if (_checkpriorityValues[1]) {
                        selectedPriorityOptions.add('Medium');
                      }
                      if (_checkpriorityValues[2]) {
                        selectedPriorityOptions.add('Low');
                      }
                    }

                    // Perform necessary actions based on the selected options
                    print('Selected Status Options: $selectedStatusOptions');
                    print(
                        'Selected Priority Options: $selectedPriorityOptions');

                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    filterTasks();
  }

  @override
  Widget build(BuildContext context) {
    filterTasks();
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Task Overview",
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                )
              ],
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.transparent),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildDropdownViewOption(),
                      SizedBox(width: 10),
                      buildDropdownReviewOption(),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _expanded = !_expanded;
                          });
                          _showDialog();
                        },
                        child: Icon(Icons.filter_list),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: 65,
                    width: 130,
                    child: _selectedType == MyTasks
                        ? RoundButton(
                            title: "My Tasks",
                            onPressed: () {
                              setState(() {
                                _selectedType = MyTasks;
                              });
                            },
                          )
                        : RoundGradientButton(
                            title: "My Tasks",
                            onPressed: () {
                              setState(() {
                                _selectedType = MyTasks;
                              });
                            },
                          )),
                SizedBox(
                  width: 8,
                ),
                SizedBox(
                    height: 65,
                    width: 130,
                    child: _selectedType == TeamTasks
                        ? RoundButton(
                            title: "Team\nTasks",
                            onPressed: () {
                              setState(() {
                                _selectedType = TeamTasks;
                              });
                            },
                          )
                        : RoundGradientButton(
                            title: "Team\nTasks",
                            onPressed: () {
                              setState(() {
                                _selectedType = TeamTasks;
                              });
                            },
                          )),
              ],
            ),
            SizedBox(height: 15),
            if (_selectedType == MyTasks)
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: filteredMyTasks.length,
                  itemBuilder: (context, index) {
                    Task task = filteredMyTasks[index];
                    if (selectedViewOption == ViewOption.Table)
                      return TaskTable(
                        title: task.title,
                        assignedTo: task.assignedTo,
                        status: task.status,
                        project: task.project,
                        priority: task.priority,
                      );
                    if (selectedViewOption == ViewOption.Board)
                      return TaskCard(
                        title: task.title,
                        assignedTo: task.assignedTo,
                        status: task.status,
                        description: task.description,
                        project: task.project,
                        priority: task.priority,
                      );
                  },
                ),
              ),
            if (_selectedType == TeamTasks)
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: filteredTeamTasks.length,
                  itemBuilder: (context, index) {
                    Task task = filteredTeamTasks[index];
                    if (selectedViewOption == ViewOption.Table)
                      return TaskTable(
                        title: task.title,
                        assignedTo: task.assignedTo,
                        status: task.status,
                        project: task.project,
                        priority: task.priority,
                      );
                    if (selectedViewOption == ViewOption.Board)
                      return TaskCard(
                        title: task.title,
                        assignedTo: task.assignedTo,
                        status: task.status,
                        description: task.description,
                        project: task.project,
                        priority: task.priority,
                      );
                  },
                ),
              ),
          ]),
        ),
      ),
    );
  }

  Widget buildDropdownViewOption() {
    return DropdownButton<ViewOption>(
      value: selectedViewOption,
      onChanged: (ViewOption? newValue) {
        setState(() {
          selectedViewOption = newValue!;
        });
      },
      items: ViewOption.values
          .map<DropdownMenuItem<ViewOption>>((ViewOption option) {
        return DropdownMenuItem<ViewOption>(
          value: option,
          child: Text(
            option.toString().split('.').last,
            style: TextStyle(
                color: AppColors.blackColor,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
        );
      }).toList(),
    );
  }

  Widget buildDropdownReviewOption() {
    return DropdownButton<ReviewOption>(
      value: selectedReviewOption,
      onChanged: (ReviewOption? newValue) {
        setState(() {
          selectedReviewOption = newValue!;
          filterTasks();
        });
      },
      items: ReviewOption.values
          .map<DropdownMenuItem<ReviewOption>>((ReviewOption option) {
        return DropdownMenuItem<ReviewOption>(
          value: option,
          child: Text(
            option.toString().split('.').last,
            style: TextStyle(
                color: AppColors.blackColor,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
        );
      }).toList(),
    );
  }
}

class TaskTable extends StatefulWidget {
  final String title;
  final String project;
  final String assignedTo;
  final String status;
  final String priority;

  TaskTable({
    required this.title,
    required this.project,
    required this.assignedTo,
    required this.status,
    required this.priority,
  });

  @override
  _TaskTableState createState() => _TaskTableState();
}

class _TaskTableState extends State<TaskTable> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return Table(
              border: TableBorder.all(color: Colors.black, width: 1.2),
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Title',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'AssignedTo',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                  TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(widget.title),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(widget.assignedTo),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            widget.status,
                            style: TextStyle(
                              color: _getStatusColor(widget.status),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return Colors.green;
      case 'Closed':
        return Colors.red;
      case 'To Do':
        return Colors.blueAccent;
      default:
        return Colors.orange;
    }
  }
}

class Task {
  final String title;
  final String project;
  final String assignedTo;
  final String assignedTeam;
  final String status;
  final String description;
  final ReviewOption reviewOption;
  final String priority;

  Task({
    required this.title,
    required this.project,
    required this.assignedTo,
    required this.assignedTeam,
    required this.status,
    required this.description,
    required this.reviewOption,
    required this.priority,
  });
}

class TaskCard extends StatefulWidget {
  final String title;
  final String project;
  final String assignedTo;
  final String status;
  final String description;
  final String priority;

  TaskCard({
    required this.title,
    required this.project,
    required this.assignedTo,
    required this.status,
    required this.description,
    required this.priority,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  TextEditingController commentController = TextEditingController();
  List<String> comments = [];
  TextEditingController _mentionController = TextEditingController();


  void _editTask() {
    // Navigate to the edit task screen with the current task data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskPage(
          initialTitle: widget.title,
          initialProject: widget.project,
          initialAssignedTo: widget.assignedTo,
          initialStatus: widget.status,
          initialDescription: widget.description,
          initialPriority: widget.priority,
        ),
      ),
    );
  }

  void _deleteTask() {
    // Show a confirmation dialog for deleting the task
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            SizedBox(
                width: 80,
                height: 30,
                child: RoundButton(
                    title: "Cancel",
                    onPressed: () {
                      Navigator.of(context).pop();
                    })),
            SizedBox(
                width: 70,
                height: 30,
                child: RoundButton(
                    title: "Delete",
                    onPressed: () {
                      Navigator.of(context).pop();
                    })),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color priorityColor;
    switch (widget.status) {
      case 'In Progress':
        statusColor =
            Colors.green; // Replace with the desired hexadecimal color code
        break;
      case 'Completed':
        statusColor = Colors.red; // Example using RGB color
        break;
      case 'Open':
        statusColor = Colors.blueAccent; // Example using RGB color
        break;
      case 'transferred':
        statusColor = Colors.orange; // Example using RGB color
        break;
      default:
        statusColor = AppColors.secondaryColor2;
        break;
    }
    switch (widget.priority) {
      case 'High':
        priorityColor = Colors.red; // Set color for High priority
        break;
      case 'Low':
        priorityColor = Colors.green; // Set color for Low priority
        break;
      case 'Critical':
        priorityColor = Colors.purple; // Set color for Critical priority
        break;
      case 'Medium':
      default:
        priorityColor =
            Colors.orange; // Set color for Medium priority or default
        break;
    }

    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.primaryColor2.withOpacity(0.3),
              AppColors.primaryColor1.withOpacity(0.3)
            ]),
            borderRadius: BorderRadius.circular(15),
          ),
          child: SingleChildScrollView(
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Project: ',
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        widget.project,
                        style: TextStyle(
                          color: AppColors.grayColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 30,
                        child: RoundButton(
                            title: "Edit\nTask", onPressed: _editTask),
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      SizedBox(
                        width: 70,
                        height: 30,
                        child: RoundButton(
                            title: "Delete\nTask", onPressed: _deleteTask),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 8.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    widget.priority,
                    style: TextStyle(
                        color: priorityColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 4.0),
                      Text(
                        widget.assignedTo,
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Status : ",
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Text(
                widget.description,
                style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 30,
                    width: 100,
                    child: RoundButton(
                        title: "Comments",
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                contentPadding: EdgeInsets.fromLTRB(16.0, 12.0,
                                    16.0, 16.0), // Adjust content padding
                                title: Text('Task Details'),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(widget.title),
                                    Text(widget.description),
                                    SizedBox(height: 14.0),
                                    Text(
                                      'Comments:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8.0),
                                    Column(
                                      children: [
                                        CommentWidget(
                                          commenter: 'John',
                                          comment: 'This is a comment',
                                          timestamp: 'July 6, 2023',
                                          addSubCommentCallback:
                                              (String subComment) {
                                            // Handle adding the sub-comment to the main comment
                                            // You can perform any necessary actions with the sub-comment text here
                                            print(
                                                'Added sub-comment: $subComment');
                                          },
                                        ),
                                        SizedBox(height: 16.0),
                                        Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: CommentWidget(
                                            commenter: 'Alice',
                                            comment: 'This is a sub-comment',
                                            timestamp: 'July 7, 2023',
                                            addSubCommentCallback:
                                                (String subComment) {
                                              // Handle adding the sub-comment to the main comment
                                              // You can perform any necessary actions with the sub-comment text here
                                              print(
                                                  'Added sub-comment: $subComment');
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.0),
                                    RoundTextField(
                                      hintText: "Add comments",
                                      icon: "assets/images/comments.png",
                                      textInputType: TextInputType.text,
                                      onChanged: (value) {
                                        if (value.contains('@')) {
                                          String mentionedUser = value.substring(value.indexOf('@') + 1);
                                          // TODO: Implement logic to search for suggested users based on the mentionedUser value
                                          // You can use a FutureBuilder or any other method to fetch and display the suggested users
                                          List<String> suggestedUsers = ['Samridhi', 'Aman']; // Dummy list of suggested users

                                          // Show suggestions if there are any
                                          if (suggestedUsers.isNotEmpty) {
                                            showUserSuggestions(context, mentionedUser, suggestedUsers, _mentionController);
                                          }

                                          _mentionController.text = value;
                                        }
                                      },
                                    ),
                                    SizedBox(height: 12.0),
                                    Center(
                                      child: SizedBox(
                                        height: 30,
                                        width: 70,
                                        child: RoundButton(
                                            title: "Send", onPressed: () {
                                              Navigator.pop(context);
                                        }),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        }),
                  ),
                  SizedBox(
                    width: 100,
                    height: 30,
                    child: RoundButton(title: "View More", onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> TaskDetailsScreen(
                        projectName: widget.project,
                        taskTitle: widget.title,
                        assignee: widget.assignedTo,
                        status:widget.status,
                      ),));
                    }),
                  ),
                ],
              )
            ]),
          ),
        ));
  }

  void showUserSuggestions(BuildContext context, String query, List<String> suggestedUsers,TextEditingController _mentionController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          insetPadding: EdgeInsets.symmetric(vertical: 10),
          title: Text('User Suggestions'),
          content: Container(
            width: 300, // Adjust the width value as needed
            height: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: suggestedUsers.length,
                    itemBuilder: (BuildContext context, int index) {
                      final user = suggestedUsers[index];
                      return ListTile(
                        title: Text(user),
                        onTap: () {
                          // Replace the text in the comment field with the selected user
                          _mentionController.text = user;
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CommentWidget extends StatefulWidget {
  final String commenter;
  final String comment;
  final String timestamp;
  final Function(String) addSubCommentCallback;

  CommentWidget({
    required this.commenter,
    required this.comment,
    required this.timestamp,
    required this.addSubCommentCallback,
  });

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool isAddingSubComment = false;
  TextEditingController subCommentController = TextEditingController();
  List<String> subComments = [];

  @override
  void dispose() {
    subCommentController.dispose();
    super.dispose();
  }

  void toggleAddSubComment() {
    setState(() {
      isAddingSubComment = !isAddingSubComment;
    });
  }

  void addSubComment() {
    String subCommentText = subCommentController.text;
    if (subCommentText.isNotEmpty) {
      widget.addSubCommentCallback(subCommentText);
      subCommentController.clear();
      toggleAddSubComment();
    }
  }

  void openSubCommentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Sub-Comment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: subCommentController,
                decoration: InputDecoration(
                  labelText: 'Sub-Comment',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      addSubComment();
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Send'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.commenter,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4.0),
            Text(widget.timestamp),
          ],
        ),
        SizedBox(height: 4.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.comment),
            if (!isAddingSubComment)
              GestureDetector(
                onTap: (){},
                child: Text(
                  'Reply',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        ]),
      ],
    );
  }
}
