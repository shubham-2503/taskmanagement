import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';

class TruecallerAuthServices{

  late StreamSubscription streamSubscription;

  startVerification(BuildContext context) async {
    TruecallerSdk.initializeSDK(sdkOptions: TruecallerSdkScope.SDK_OPTION_WITHOUT_OTP);

//Step 2: Check if SDK is usable on that device, otherwise fall back to any other alternative
    bool isUsable = await TruecallerSdk.isUsable;

//Step 3: If isUsable is true, you can call getProfile to show consent screen to verify user's number
    isUsable ? TruecallerSdk.getProfile : print("***Not usable***");

//OR you can also replace Step 2 and Step 3 directly with this
    TruecallerSdk.isUsable.then((isUsable) {
      isUsable ? TruecallerSdk.getProfile : print("***Not usable***");
    });

//Step 4: Be informed about the TruecallerSdk.getProfile callback result(success, failure, verification)
    streamSubscription = TruecallerSdk.streamCallbackData.listen((truecallerSdkCallback) {
      switch (truecallerSdkCallback.result) {
        case TruecallerSdkCallbackResult.success:
          print("Truecaller auth success");
          String firstName = truecallerSdkCallback.profile!.firstName;
          String? lastName = truecallerSdkCallback.profile!.lastName;
          String phNo = truecallerSdkCallback.profile!.phoneNumber;
        
          break;
        case TruecallerSdkCallbackResult.failure:
          print("Truecaller auth failed");
          int errorCode = truecallerSdkCallback.error!.code;
          print("Error code: $errorCode");
          break;
        case TruecallerSdkCallbackResult.verification:
          print("Verification Required!!");
          break;
        default:
          print("Invalid result");
      }
    });
  }

  //Step 5: Dispose streamSubscription
  @override
  void dispose() {
    streamSubscription.cancel();
  }

}