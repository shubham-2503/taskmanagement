import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fetch_user_model.dart';
import '../models/project_team_model.dart';

class UpdateApiServices {
  static Future<String> updateProject(
      String projectId,
      String title,
      String assignedTo,
      String? assignedTeam,
      String status,
      String dueDate,
      List<User> users,
      List<Team> teams,
      ) async {
    try {
      List<String> assignedMembers = users.map((user) => user.userId).toList();
      List<String> assignedTeams = teams.map((team) => team.id).toList();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      final url = 'http://43.205.97.189:8000/api/Project/updateProject/$projectId?status=$status';

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        "name": title,
        "start_date": "2023-07-27T14:45:52.257Z",
        "end_date": dueDate,
        "team_id": assignedTeams,
        "user_id": assignedMembers,
      });

      final response = await http.patch(Uri.parse(url), headers: headers, body: body);
      print("StatusCode: ${response.statusCode}");
      print("Body: ${response.body}");
      print("Response: ${jsonDecode(body)}");

      if (response.statusCode == 200) {
        // Update successful
        final responseData = json.decode(response.body);
        print('Project updated successfully: ${responseData['message']}');
        return responseData['message'];
      } else {
        print('Error updating project: ${response.statusCode}');
        // Optionally, you can show an error dialog to inform the user about the update failure
        throw 'Failed to update project. Please try again later.';
      }
    } catch (e) {
      print('Error updating project: $e');
      // Optionally, you can show an error dialog to inform the user about the update failure
      throw 'An unexpected error occurred. Please try again later.';
    }
  }

  Future<void> editProfile(Map<String, dynamic> userData) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      final url = Uri.parse('http://43.205.97.189:8000/api/User/editProfile');
      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
        'Content-Type': 'application/json',
      };

      final response = await http.patch(
        url,
        headers: headers,
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        print("Profile updated successfully!");
        // Show a success message or handle the result as needed
      } else {
        print("Failed to update profile. Status code: ${response.statusCode}");
        // Show an error message or handle the error as needed
      }
    } catch (error) {
      print('Error updating profile: $error');
      // Show an error message or handle the error as needed
    }
  }
}