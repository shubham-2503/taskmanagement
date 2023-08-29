import 'package:flutter/cupertino.dart';


class AppSize{
  double w=0.0;
  double h=0.0;
  bool isTablet=false;
  void init(BuildContext context)async{
    debugPrint("--- Size Assigned ---");
    w=MediaQuery.of(context).size.width;
    h=MediaQuery.of(context).size.height;
    if(h>=1024 && w>=768){
      isTablet=true;
    }
  }
}