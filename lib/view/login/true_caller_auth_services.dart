// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:truecaller_sdk/truecaller_sdk.dart';
// import 'package:http/http.dart';
//
// class TruecallerAuthServices {
//   late StreamSubscription streamSubscription;
//
//   void loginWithTruecaller(String contact) async {
//     try {
//       Response response = await post(
//         Uri.parse('http://43.205.97.189:8000/api/UserAuth/otpLessLogin'),
//         body: {'contact': contact},
//       );
//
//       print("Contact: $contact");
//       print("StatusCode: ${response.statusCode}");
//
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body.toString());
//         print(data['token']);
//         print('Login successfully');
//       } else {
//         print('Login failed');
//       }
//     } catch (e) {
//       print('LoginWithTruecaller Error: $e'); // Log the error
//     }
//   }
//
//   Future<void> startVerification(BuildContext context) async {
//     const String truecallerClientId = 'xabxs-wu5ttiwlvmjm2uzvc5t9ra4mkchrtyck8k1r8';
//
//     TruecallerSdk.initializeSDK(sdkOptions: TruecallerSdkScope.SDK_OPTION_WITHOUT_OTP);
//
//     print("Client ID: $truecallerClientId");
//
//     // Step 2: Check if SDK is usable on that device, otherwise fall back to any other alternative
//     bool isUsable = await TruecallerSdk.isUsable;
//     print("Is Usable: $isUsable");
//
//     // Step 3: If isUsable is true, you can call getProfile to show the consent screen to verify the user's number
//     if (isUsable) {
//       print("Initiating Truecaller authentication...");
//       TruecallerSdk.getProfile();
//     } else {
//       print("***Not usable***");
//     }
//
//     // Step 4: Be informed about the TruecallerSdk.getProfile callback result (success, failure, verification)
//     streamSubscription = TruecallerSdk.streamCallbackData.listen((truecallerSdkCallback) {
//       switch (truecallerSdkCallback.result) {
//         case TruecallerSdkCallbackResult.success:
//           print("Truecaller auth success");
//
//           // Check if the profile is not null before accessing its properties
//           if (truecallerSdkCallback.profile != null) {
//             String firstName = truecallerSdkCallback.profile!.firstName ?? "N/A";
//             String? lastName = truecallerSdkCallback.profile!.lastName;
//             String phNo = truecallerSdkCallback.profile!.phoneNumber ?? "N/A";
//
//             print("First Name: $firstName");
//             print("Last Name: $lastName");
//             print("Phone Number: $phNo");
//
//             loginWithTruecaller(phNo);
//           } else {
//             print("Profile information is missing");
//             // Handle the case where profile information is missing
//           }
//           break;
//         case TruecallerSdkCallbackResult.failure:
//           print("Truecaller auth failed");
//           int errorCode = truecallerSdkCallback.error?.code ?? -1;
//           print("Error code: $errorCode");
//           // Handle the authentication failure or error
//           break;
//         case TruecallerSdkCallbackResult.verification:
//           print("Verification Required!!");
//           // Handle the case where verification is required
//           break;
//         default:
//           print("Invalid result");
//       }
//     });
//   }
//
//   // Step 5: Dispose streamSubscription
//   void dispose() {
//     streamSubscription.cancel();
//   }
// }