import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/teams.dart';
import '../models/user.dart';

class ApiRepo{
  bool isLoging=false;

  //base url
  static const  String  baseUrl="http://43.205.97.189:8000";

  //API List of string define Here
  static  Uri loginAPI= Uri.parse("$baseUrl/api/UserAuth/login");
  static  Uri verifyOtpAPI= Uri.parse("$baseUrl/api/UserAuth/verifyOtp");
  static  String resendOtpAPI= "$baseUrl/api/UserAuth/resendOtp";
  static  Uri forgotPasswordLink= Uri.parse("$baseUrl/api/UserAuth/forgotPassword");
  static  String  getOrgUser="$baseUrl/api/UserAuth/getOrgUsers?jwttOken=";
  static  Uri  createInviteAPI= Uri.parse("$baseUrl/api/User/inviteUsers");
  static  Uri registrationAPI= Uri.parse("$baseUrl/api/User/registration");
  static  Uri  addorganizationAPI= Uri.parse("$baseUrl/api/Organization/organizationRegistration");
  static  String  getteamUsers="$baseUrl/api/Team/teamUsers?jwttOken=";
  static  String  getmyteams="$baseUrl/api/Team/myTeams?jwttOken=";
  static String updateteamAPI="$baseUrl/api/Team/team/?teamId=";
  static String myProjectTaskAPI="$baseUrl/api/Task/teamsTask?jwttOken=";
  static String teamTaskAPI="$baseUrl/api/Task/myProjectTask?jwttOken=";
  static String myTaskAPI="$baseUrl/api/Task/myTasks?jwttOken=";
  static String editTaskAPI="$baseUrl/api/Task/editTasks/?task_id=";
  static  Uri  createtasksAPI= Uri.parse("$baseUrl/api/Task/tasks");
  static  Uri  addSubscriptionAPI= Uri.parse("$baseUrl/api/Subscription/addSubscription");
  static  Uri  upgradeSubscriptionAPI= Uri.parse("$baseUrl/api/Subscription/upgradeSubscription");
  static String teamProjectAPI="$baseUrl/api/Project/myTeamProjects?jwttOken=";
  static String myProjectAPI="$baseUrl/api/Project/myProjects?jwttOken=";
  static String editProjectAPI="$baseUrl/api/Project/updateProject?project_id=";
  static  Uri  createProjectAPI= Uri.parse("$baseUrl/api/Project/addProjects");
  static String getProjectUserAPI="$baseUrl/api/Project/getProjectUsers";

  // General method for POST requests
  static Future<http.Response> postRequest(Uri url, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    try {
      final response = await http.post(url, headers: headers, body: body);
      return response;
    } catch (e) {
      throw Exception('Error during POST request: $e');
    }
  }

  // General method for GET requests
  static Future<http.Response> getRequest(Uri url, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(url, headers: headers);
      return response;
    } catch (e) {
      throw Exception('Error during GET request: $e');
    }
  }

  Future<List<User>> fetchUsers() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      final response = await http.get(
        Uri.parse('http://43.205.97.189:8000/api/UserAuth/getOrgUsers'),
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
          final List<User> users = data.map((userJson) => User.fromJson(userJson)).toList();

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
    List<Team> teams = [];
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      final response = await http.get(
        Uri.parse('http://43.205.97.189:8000/api/Team/teamUsers'), // Update the API endpoint URL
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
                  .map((teamJson) => Team.fromJson(teamJson as Map<String, dynamic>))
                  .toList();

              for (var team in teams) {
                print("Team Name: ${team.name}");
                print("Team ID: ${team.id}");
                print("Users: ${team.users}");
                print("----------------------");
              }

              return teams;
            }
          } catch (e) {
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

}