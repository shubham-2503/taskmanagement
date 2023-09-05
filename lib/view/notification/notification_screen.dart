import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  static String routeName = "/NotificationScreen";

  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List notificationArr = [];
  String? selectedOption = "All";
  List<Map<String, dynamic>> filteredNotifications = [];

  Future<List<dynamic>> fetchNotifications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');
    String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

    if (orgId == null) {
      // If the user hasn't switched organizations, use the organization ID obtained during login time
      orgId = prefs.getString('org_id') ?? "";
    }

    print("OrgId: $orgId");

    if (orgId.isEmpty) {
      throw Exception('orgId not found locally');
    }


    final response = await http.get(
      Uri.parse('http://43.205.97.189:8000/api/Notification/getNotifications?org_id=$orgId'),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      },
    );

    print("Code: ${response.statusCode}");
    print("Body: ${response.body}");
    if (response.statusCode == 200) {
      return json.decode(response.body)['notification'];
    } else {
      print('API Error: Status Code ${response.statusCode}, Response Body: ${response.body}');
      throw Exception('Failed to load notifications');
    }
  }

  // Create a function to filter notifications based on category
  List<Map<String, dynamic>> filterNotificationsByCategory(String category) {
    int notificationsToShowPerCategory = 5;
    int notificationsShown = 0;

    for (var nObj in notificationArr) {
      String avatarText = nObj['title'].split(' ')[0].toUpperCase();

      if (avatarText == category && notificationsShown < notificationsToShowPerCategory) {
        filteredNotifications.add(nObj);
        notificationsShown++;
      }
    }
    return filteredNotifications;
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications().then((notifications) {
      setState(() {
        notificationArr = notifications;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          centerTitle: true,
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.lightGrayColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/icons/back_icon.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          ),
          title: const Text(
            "Notification",
            style: TextStyle(
                color: AppColors.blackColor,
                fontSize: 16,
                fontWeight: FontWeight.w700),
          ),
        ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        itemCount: notificationArr.length,
        itemBuilder: (context, index) {
          var nObj = notificationArr[index];
          DateTime createdDateTime = DateTime.parse(nObj['createdDate']);

          String avatarText = nObj['title'].split(' ')[0].toUpperCase();
          // nObj['title'].substring(1, 2).toLowerCase();
          String formattedDate = DateFormat.yMd().format(createdDateTime); // Format for date
          String formattedTime = DateFormat.jm().format(createdDateTime); // Format for time

          return Padding(
            padding: const EdgeInsets.only(bottom: 10), // Adjust the spacing as needed
            child: Card(
              elevation: 2, // Adjust the elevation as needed
              child: Stack(
                children: [
                  ListTile(
                    // Your existing ListTile content
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              nObj['createdBy'],
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.secondaryColor2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ":",
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.secondaryColor2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              width: 180,
                              child: Text(
                                nObj['body'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.blackColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4), // Add spacing between body and created date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.secondaryColor2,
                              ),
                            ),
                            Spacer(),
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.secondaryColor2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor2, // Customize the background color
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(6),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        avatarText,
                        style: TextStyle(
                          color: Colors.white, // Customize the text color
                          fontSize: 12, // Customize the font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
