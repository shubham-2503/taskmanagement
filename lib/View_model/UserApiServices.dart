import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_invitation_modal.dart';

class ApiService {
  static Future<List<UserInvitationStatus>> fetchUserInvitationStatus() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
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


      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      final url = Uri.parse('http://43.205.97.189:8000/api/User/userInvitationStatus?org_id=$orgId');

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(url, headers: headers);
      print("Response: ${response.body}");
      print("StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<UserInvitationStatus> invitationStatusList = (jsonData as List)
            .map((data) => UserInvitationStatus.fromJson(data))
            .toList();

        return invitationStatusList;
      } else {
        throw Exception('Failed to load user invitation status');
      }
    } catch (error) {
      print('Error fetching user invitation status: $error');
      throw error;
    }
  }

  Future<void> resendInvitation(UserInvitationStatus user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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

    String apiUrl = "http://43.205.97.189:8000/api/User/resendInvitation?org_id=$orgId";
    Map<String, dynamic> requestData = {
      "user_id": user.userId,
      "org_id" : orgId,
      "email": user.email,
      "name" : user.name,
      "role_id": user.roleId,
      "mobile": user.mobile.toString(),
    };

    print("Request Payload: $requestData");

    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
          'Content-Type': 'application/json', // Adding Content-Type header
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        print("Invitation resend successful!");
      } else {
        // Handle API call failure
        print("Failed to resend invitation. Status code: ${response.statusCode}");
      }
    } catch (error) {
      // Handle API call exception
      print("Error occurred while resending invitation: $error");
    }
  }

  Future<void> revokeInvitation(UserInvitationStatus user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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

    print("storedData: $storedData");

    String apiUrl = "http://43.205.97.189:8000/api/User/revokeInvitation?user_id=${user.userId}&org_id=$orgId";

    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
          'Content-Type': 'application/json', // Adding Content-Type header
        },
        body: json.encode({}), // Empty body as no additional data is required for revoking
      );

      print("Request Payload: ${response.statusCode}");

      if (response.statusCode == 200) {
        // API call successful, handle the response if needed
        print("Invitation revoked successfully!");
      } else {
        // Handle API call failure
        print("Failed to revoke invitation. Status code: ${response.statusCode}");
      }
    } catch (error) {
      // Handle API call exception
      print("Error occurred while revoking invitation: $error");
    }
  }

}
