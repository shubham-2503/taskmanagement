import 'dart:async';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:Taskapp/view/signup/inviteTeammates.dart';
import 'package:flutter/material.dart';
import 'View_model/UserApiServices.dart';
import 'common_widgets/round_textfield.dart';
import 'models/user_invitation_modal.dart';

class InviteScreen extends StatefulWidget {
  final VoidCallback refreshCallback;
  const InviteScreen({Key? key, required this.refreshCallback}) : super(key: key);

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  // Sample list of users, you should replace this with your actual list of User objects
  List<UserInvitationStatus> users = [];
  List<UserInvitationStatus> filteredUsers = [];
  late Timer _timer;

  Future<void> fetchUserInvitationStatusAndRefresh() async {
    try {
      List<UserInvitationStatus> invitationStatusList = await ApiService.fetchUserInvitationStatus();

      setState(() {
        users = invitationStatusList;
        filteredUsers = invitationStatusList;
      });
    } catch (error) {
      print('Error fetching user invitation status: $error');
      // Handle error if necessary
    }
  }

  void refreshScreen() {
    // Fetch the latest data
    try {
      ApiService.fetchUserInvitationStatus().then((invitationStatusList) {
        setState(() {
          users = invitationStatusList;
        });
      }).catchError((error) {
        print('Error fetching user invitation status: $error');
        // Handle error if necessary
      });
    } catch (error) {
      print('Error fetching user invitation status: $error');
      // Handle error if necessary
    }
  }

  @override
  void initState() {
    super.initState();
    // Call fetchUserInvitationStatus method once when the screen loads
   // fetchUserInvitationStatusAndRefresh();
    // _timer = Timer.periodic(Duration(seconds: 2), (Timer t) async{
    //   await fetchUserInvitationStatus();
    // });
    _timer = Timer.periodic(Duration(seconds:2), (Timer timer) {
      // Your timer callback logic here
      // For example, you can call a method or perform some background task
      // This callback will be called every 5 minutes
    });
    fetchUserInvitationStatusAndRefresh();
  }

  void filterUserInvitations(String query) {
    setState(() {
      filteredUsers = users.where((user) =>
          user.name.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  void dispose() {
    // Cancel the Timer to prevent unnecessary background tasks
    _timer.cancel();
    super.dispose();
  }

  void _showConfirmationDialog(BuildContext context, UserInvitationStatus user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Resend Invitation"),
          content: Text("Are you sure you want to resend the invitation?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Close the confirmation dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Close the confirmation dialog and return true
                Navigator.pop(context, true);
                _resendInvitation(user);
              },
              child: Text("Resend"),
            ),
          ],
        );
      },
    );
  }

  void _showRevokeConfirmationDialog(BuildContext context, UserInvitationStatus user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Revoke Invitation"),
          content: Text("Are you sure you want to revoke the invitation?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Close the confirmation dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, true); // Close the confirmation dialog and return true
                // Call the _revokeInvitation method with the selected user when "Revoke" is pressed
                _revokeInvitation(user);
              },
              child: Text("Revoke"),
            ),
          ],
        );
      },
    );
  }

  void showOptionsModal(UserInvitationStatus user) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Row(
                  children: [
                    Text("View Details"),
                  ],
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("User Details",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.secondaryColor2,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: "Name: ",
                                style: TextStyle(
                                    color: AppColors.secondaryColor2,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                ),
                                children: [
                                  TextSpan(
                                    text: "${user.name}",
                                    style: TextStyle(
                                      // Add any specific styles for the plan name here, if needed
                                      color: AppColors.blackColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10,),
                            RichText(
                              text: TextSpan(
                                text: "Role: ",
                                style: TextStyle(
                                    color: AppColors.secondaryColor2,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                ),
                                children: [
                                  TextSpan(
                                    text: "${user.roleName}",
                                    style: TextStyle(
                                      // Add any specific styles for the plan name here, if needed
                                      color: AppColors.blackColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10,),
                            RichText(
                              text: TextSpan(
                                text: "Email: ",
                                style: TextStyle(
                                    color: AppColors.secondaryColor2,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                ),
                                children: [
                                  TextSpan(
                                    text: "${user.email}",
                                    style: TextStyle(
                                      // Add any specific styles for the plan name here, if needed
                                      color: AppColors.blackColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10,),
                            RichText(
                              text: TextSpan(
                                text: "Status: ",
                                style: TextStyle(
                                    color: AppColors.secondaryColor2,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                ),
                                children: [
                                  TextSpan(
                                    text: "${user.status == true ? 'Accepted' : user.status == false ? 'Rejected' : 'Pending'}",
                                    style: TextStyle(
                                      // Add any specific styles for the plan name here, if needed
                                      color: AppColors.blackColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10,),
                            RichText(
                              text: TextSpan(
                                text: "Mobile: ",
                                style: TextStyle(
                                    color: AppColors.secondaryColor2,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                ),
                                children: [
                                  TextSpan(
                                    text: "${user.mobile}",
                                    style: TextStyle(
                                      // Add any specific styles for the plan name here, if needed
                                      color: AppColors.blackColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          Visibility(
                            visible: user.status == "Pending",
                            child: SizedBox(
                              height: 50,
                              width: 80,
                              child: RoundButton(title: "Resend", onPressed: () {}),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            width: 80,
                            child: RoundButton(title: "Okay", onPressed: (){
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              Visibility(
                visible: user.status == false || user.status == null, // Show the options when status is "false" or "null"
                child: Column(
                  children: [
                    ListTile(
                      title: Text("Resend Invitation"),
                      onTap: () {
                        _showConfirmationDialog(context, user); // Close the modal after option selection
                      },
                    ),
                   /* ListTile(
                      title: Text("Revoke Invitation"),
                      onTap: () {
                        _showRevokeConfirmationDialog(context, user); // Close the modal after option selection
                      },
                    ),*/
                  ],
                ),
              ),
              Visibility(
                visible:  user.status == null, // Show the options when status is "false" or "null"
                child: Column(
                  children: [
                     ListTile(
                      title: Text("Revoke Invitation"),
                      onTap: () {
                        _showRevokeConfirmationDialog(context, user); // Close the modal after option selection
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _resendInvitation(UserInvitationStatus user) async {
    try {
      ApiService apiService = ApiService();
      await apiService.resendInvitation(user);
      // Refresh the screen after resending the invitation
      String errorMessage = "Invitation resend successfully";
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Sent"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      refreshScreen();
      // Show a success message or handle the result as needed
      print("Invitation resend successful!");
    } catch (error) {
      // Handle the error
      print("Error occurred while resending invitation: $error");
    }
  }

  void _revokeInvitation(UserInvitationStatus user) async {
    try {
      ApiService apiService = ApiService();
      await apiService.revokeInvitation(user);
      // Fetch the updated list of users after the invitation is resent
      String errorMessage = "Invitation revoked successfully";
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Sent"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
               Navigator.pop(context);
               Navigator.pop(context);
               fetchUserInvitationStatusAndRefresh();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
      refreshScreen();
      // Show a success message or handle the result as needed
      print("Invitation revoked successfully!");
    } catch (error) {
      // Handle the error
      print("Error occurred while revoking invitation: $error");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(height: 50,width: 150,child:  RoundTextField(
              onChanged: (query) => filterUserInvitations(query), hintText: 'Search',
              icon: "assets/images/search_icon.png",
            ),),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              height: 30,
              width: 90,
              child: RoundButton(
                title: "Invite User",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InviteTeammatesScreen()),
                  );
                },
              ),
            ),
          )
        ],
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            UserInvitationStatus user = filteredUsers[index]; // Use UserInvitationStatus here
            return ListTile(
              leading: Icon(Icons.person,color: AppColors.secondaryColor2,),
              title: Text(user.name,style: TextStyle(
                color: AppColors.primaryColor2,
                fontWeight: FontWeight.bold
              ),), // Use properties of UserInvitationStatus
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: user.status == true
                            ? Colors.green // Green color for Accepted
                            : user.status == false
                            ? Colors.red // Red color for Declined
                            : Colors.grey, // Border color
                        width: 2.0, // Border width
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.all(8.0), // Optional: Add padding around the text
                    child: Text(
                      "${user.status == true ? 'Accepted' : user.status == false ? 'Declined' : 'Pending'}",
                      style: TextStyle(
                        color: user.status == true
                            ? Colors.green // Green color for Accepted
                            : user.status == false
                            ? Colors.red // Red color for Declined
                            : Colors.grey, // Grey color for Pending
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showOptionsModal(user);
                    },
                    icon: Icon(Icons.more_vert),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor1,
        onPressed: () {
          // Fetch user invitation status and reload the screen
          fetchUserInvitationStatusAndRefresh();
        },
        child: Icon(Icons.refresh, color: AppColors.secondaryColor2),
      ),
    );
  }
}

