import 'package:Taskapp/common_widgets/round_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fetch_user_model.dart';
import '../utils/app_colors.dart';


class UserSuggestionTextField extends StatefulWidget {
  final TextEditingController controller;
  final Function(List<String> mentionedUserIds) onPressed;

  UserSuggestionTextField({
    required this.controller,
    required this.onPressed,
  });
  @override
  _UserSuggestionTextFieldState createState() => _UserSuggestionTextFieldState();
}

class _UserSuggestionTextFieldState extends State<UserSuggestionTextField> {
  List<String> suggestedUsers = [];
  List<String> mentionedUserIds = [];
  bool showSuggestions = false;

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Fetch user suggestions when the widget is initialized
  }

  Future<void> fetchUsers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

      if (orgId == null) {
        // If the user hasn't switched organizations, use the organization ID obtained during login time
        orgId = prefs.getString('org_id') ?? "";
      }

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      final response = await http.get(
        Uri.parse('http://43.205.97.189:8000/api/UserAuth/getOrgUsers?org_id=$orgId'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody != null && responseBody.isNotEmpty) {
          final List<dynamic> data = jsonDecode(responseBody);
          final List<String> users = data.map((userJson) => User.fromJson(userJson).userName).toList();

          setState(() {
            suggestedUsers = users;
          });
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

  Future<String> getUserIdByUsername(String username) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId = prefs.getString(
          "selectedOrgId"); // Get the selected organization ID

      if (orgId == null) {
        // If the user hasn't switched organizations, use the organization ID obtained during login time
        orgId = prefs.getString('org_id') ?? "";
      }

      print("OrgId: $orgId");


      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      print("OrgId: $orgId");

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 48.0), // Added padding from bottom
      margin: EdgeInsets.only(bottom: 20.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add Comments",style: TextStyle(
              color: AppColors.secondaryColor2,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),),
            SizedBox(height: 10,),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextFormField(
                decoration: InputDecoration(
                    hintText: "Write your Comments",
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.secondaryColor2,
                        width: 1.2,
                      ),
                    )
                ),
                // controller: _commentController,
                onChanged: (text) {
                  if (text.endsWith('@')) {
                    setState(() {
                      showSuggestions = true;
                    });
                  } else {
                    setState(() {
                      showSuggestions = false;
                    });
                  }
                },
              ),
            ),
            if (showSuggestions)
              ListView.builder(
                shrinkWrap: true,
                itemCount: suggestedUsers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(suggestedUsers[index]),
                    onTap: () {
                      final currentText =widget.controller.text;
                      final cursorPosition =
                          widget.controller.selection.base.offset;
                      final newText = currentText.substring(0, cursorPosition) + suggestedUsers[index] + ' ' +
                          currentText.substring(cursorPosition);

                      setState(() {
                        widget.controller.text = newText;
                        mentionedUserIds.add(suggestedUsers[index]);
                        showSuggestions = false;
                      });
                    },
                  );
                },
              ),
            SizedBox(height: 20,),
            RoundGradientButton(
              title: "Send",
              onPressed: () async {
                String commentText = widget.controller.text;
                print("Comment Text: $commentText");

                List<String> mentionedUserIdsList = []; // Create a list to store user IDs

                for (String mentionedUser in mentionedUserIds) {
                  print("Mentioned User: @$mentionedUser");
                }

                String commentTextWithoutMentions = commentText;
                for (String mentionedUser in mentionedUserIds) {
                  commentTextWithoutMentions = commentTextWithoutMentions.replaceAll('@$mentionedUser', '');
                }
                commentTextWithoutMentions = commentTextWithoutMentions.trim(); // Remove unnecessary spaces

                print("Comment Text without Mentions: $commentTextWithoutMentions");

                for (String mentionedUser in mentionedUserIds) {
                  try {
                    String userId = await getUserIdByUsername(mentionedUser);
                    mentionedUserIdsList.add(userId); // Store user ID in the list
                    print("Mentioned User: @$mentionedUser ($userId)");
                  } catch (e) {
                    print("Error getting user ID for $mentionedUser: $e");
                  }
                }
                print("Mentioned User IDs List: $mentionedUserIdsList");
                widget.onPressed(mentionedUserIdsList);
              },
            ),
          ],
        ),
      ),
    );
  }
}
