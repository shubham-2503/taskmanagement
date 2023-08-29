// import 'package:Taskapp/common_widgets/round_button.dart';
// import 'package:Taskapp/models/task_model.dart';
// import 'package:Taskapp/view/tasks/editCreatetasks.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import '../../utils/app_colors.dart';
//
// class TaskDetailsModal extends StatefulWidget {
//   final Task task;
//
//   TaskDetailsModal({required this.task});
//
//   @override
//   State<TaskDetailsModal> createState() => _TaskDetailsModalState();
// }
//
// class _TaskDetailsModalState extends State<TaskDetailsModal> {
//
//   void _deleteTask(String taskId) async {
//     try {
//       // Show a confirmation dialog for deleting the project
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Confirm Delete'),
//             content: Text('Are you sure you want to delete this task?'),
//             actions: [
//               TextButton(
//                 child: Text('Cancel'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//               TextButton(
//                 onPressed: () async {
//                   Navigator.of(context).pop();
//                   try {
//                     SharedPreferences prefs =
//                     await SharedPreferences.getInstance();
//                     final storedData = prefs.getString('jwtToken');
//                     String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID
//
//                     if (orgId == null) {
//                       // If the user hasn't switched organizations, use the organization ID obtained during login time
//                       orgId = prefs.getString('org_id') ?? "";
//                     }
//
//                     print("OrgId: $orgId");
//
//                     if (orgId == null) {
//                       throw Exception('orgId not found locally');
//                     }
//
//                     final response = await http.delete(
//                       Uri.parse(
//                           'http://43.205.97.189:8000/api/Task/tasks/$taskId'),
//                       headers: {
//                         'accept': '*/*',
//                         'Authorization': "Bearer $storedData",
//                       },
//                     );
//
//                     print("Delete API response: ${response.body}");
//                     print("Delete StatusCode: ${response.statusCode}");
//
//                     if (response.statusCode == 200) {
//                       showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return AlertDialog(
//                             title: Text('Thank You'),
//                             content: Text("Task deleted successfully."),
//                             actions: [
//                               InkWell(
//                                 onTap: () {
//                                   Navigator.pop(context,true);
//                                   Navigator.pop(context,true);
//                                 },
//                                 child: Text(
//                                   "OK",
//                                   style: TextStyle(
//                                       color: AppColors.blackColor, fontSize: 20),
//                                 ),
//                               )
//                             ],
//                           );
//                         },
//                       );
//                       print('Task deleted successfully.');
//                       setState(() {
//                         Navigator.pop(context);
//                         Navigator.pop(context, true); // Sending a result back to the previous screen
//                       });
//
//                     } else {
//                       print('Failed to delete task.');
//                       // Handle other status codes, if needed
//                     }
//                   } catch (e) {
//                     print('Error deleting task: $e');
//                   }
//                 },
//                 child: Text('Delete'),
//               ),
//             ],
//           );
//         },
//       ).then((value) {
//
//       });
//     } catch (e) {
//       print('Error showing delete confirmation dialog: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       height: double.infinity,
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               "Task Name",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.secondaryColor2),
//             ),
//             SizedBox(height: 10,),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Colors.grey,
//                   width: 1.0,
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       "${widget.task.taskName}",
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               "Description",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.secondaryColor2),
//             ),
//             SizedBox(height: 10,),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Colors.grey,
//                   width: 1.0,
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       "${widget.task.description}",
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               "Due Date",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.secondaryColor2),
//             ),
//             SizedBox(height: 10,),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Colors.grey,
//                   width: 1.0,
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       "${formatDate(widget.task.dueDate)}",
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               "Status",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.secondaryColor2),
//             ),
//             SizedBox(height: 10,),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Colors.grey,
//                   width: 1.0,
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       "${widget.task.status}",
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               "Priority",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.secondaryColor2),
//             ),
//             SizedBox(height: 10,),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Colors.grey,
//                   width: 1.0,
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       "${widget.task.priority}",
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(height: 30,width: 70,child: RoundButton(
//                   onPressed: (){
//                     Navigator.push(context, MaterialPageRoute(builder: (context)=>EditCreatedByTask(task: widget.task)));
//                   },
//                   title: "Edit",
//                 ),),
//                 SizedBox(width: 50,),
//                 SizedBox(height: 30,width: 70,child: RoundButton(
//                   onPressed: (){
//                     _deleteTask("${widget.task.taskId}");
//                   },
//                   title: "Delete",
//                 ),),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// String formatDate(String? dateString) {
//   print('Raw Date String: $dateString');
//   if (dateString == null || dateString.isEmpty) {
//     return 'N/A'; // Return "N/A" for null or empty date strings
//   }
//   try {
//     final dateTime = DateTime.parse(dateString);
//     final formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
//     return formattedDate;
//   } catch (e) {
//     print('Error parsing date: $e');
//     return 'Invalid Date'; // Return a placeholder for invalid date formats
//   }
// }
//
//
