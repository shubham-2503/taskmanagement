import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/teams.dart';
import 'package:http/http.dart' as http;

class TeamsApiService {
  static Future<List<Team>> fetchTeams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');
    String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

    if (orgId == null) {
      // If the user hasn't switched organizations, use the organization ID obtained during login time
      orgId = prefs.getString('org_id') ?? "";
    }

    print("OrgId: $orgId");


    if (orgId == null) {
      throw Exception('orgId not found locally');
    }

    final apiUrl = 'http://43.205.97.189:8000/api/Team/team?orgId=$orgId';
    final headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $storedData',
    };

    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      // Assuming your response contains a list of teams
      final teamsList = jsonData['teams'] as List<dynamic>;
      return teamsList.map((teamJson) => Team.fromJson(teamJson)).toList();
    } else {
      throw Exception('Failed to fetch teams');
    }
  }

  static Future<void> createTeam(String teamName, List<String> users) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');
    String? orgId = prefs.getString("selectedOrgId");

    if (orgId == null) {
      orgId = prefs.getString('org_id') ?? "";
    }

    print("OrgId: $orgId");

    if (orgId == null) {
      throw Exception('orgId not found locally');
    }

    final apiUrl = 'http://43.205.97.189:8000/api/Team/team?orgId=$orgId';
    final headers = {
      'accept': '*/*',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $storedData',
    };

    final body = jsonEncode({
      "name": teamName,
      "user_id": users,
    });

    final response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Team created successfully.');
    } else {
      throw Exception('Failed to create team');
    }
  }

  static Future<void> updateTeam(String teamId, String newTeamName, List<String> userIds,) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId = prefs.getString("selectedOrgId");

      if (orgId == null) {
        orgId = prefs.getString('org_id') ?? "";
      }

      print("OrgId: $orgId");

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      if (storedData == null || storedData.isEmpty) {
        print('Stored token is null or empty. Cannot make API request.');
        throw Exception('Failed to update team: Stored token is null or empty.');
      }

      final Map<String, dynamic> requestBody = {
        "name": newTeamName,
        "user_id": userIds,
      };

      final response = await http.patch(
        Uri.parse("http://43.205.97.189:8000/api/Team/team/$teamId?org_id=$orgId"),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print("API response: ${response.body}");
      print("StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        print('Team updated successfully with new members and name.');
        // You can return any relevant data if needed.
      } else {
        throw Exception('Failed to update team with new members and name.');
      }
    } catch (e) {
      print('Error updating team with new members and name: $e');
      throw Exception('Error updating team with new members and name: $e');
    }
  }

  static Future<void> deleteTeam(String teamId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId = prefs.getString("selectedOrgId");

      if (orgId == null) {
        orgId = prefs.getString('org_id') ?? "";
      }

      print("OrgId: $orgId");

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      final response = await http.delete(
        Uri.parse('http://43.205.97.189:8000/api/Team/team/$teamId?org_id=$orgId'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
        },
      );

      print("Delete API response: ${response.body}");
      print("Delete StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        print('Team deleted successfully.');
        // You can return any relevant data if needed.
      } else {
        throw Exception('Failed to delete team.');
      }
    } catch (e) {
      print('Error deleting team: $e');
      throw Exception('Error deleting team: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchTeamUsers(String orgId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId = prefs.getString("selectedOrgId");

      if (orgId == null) {
        orgId = prefs.getString('org_id') ?? "";
      }

      print("OrgId: $orgId");

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      final apiUrl = 'http://43.205.97.189:8000/api/Team/teamUsers?org_id=$orgId';
      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      print("Fetch team users API response: ${response.body}");
      print("Fetch team users StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        // Assuming your response contains a list of team users
        final teamUsersList = jsonData as List<dynamic>;
        return teamUsersList.map((userJson) => userJson as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to fetch team users.');
      }
    } catch (e) {
      print('Error fetching team users: $e');
      throw Exception('Error fetching team users: $e');
    }
  }

}
