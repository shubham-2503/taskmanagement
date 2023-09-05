import 'package:flutter/material.dart';

class AppColors{
  static const primaryColor2 =  Color(0xFF018ABE);
  static const primaryColor1 =  Color(0xFF97CADB);

  static const secondaryColor1 =  Color(0xFF593E67);
  static const secondaryColor2 =  Color(0xFF84495F);

  static const whiteColor = Color(0xFFFFFFFF);
  static const blackColor = Color(0xFF001B48);
  static const grayColor = Color(0xFF7B6F72);
  static const lightGrayColor = Color(0xFFF7F8F8);
  static const midGrayColor = Color(0xFFADA4A5);

  static List<Color> get primaryG => [primaryColor1,primaryColor2];
  static List<Color> get secondaryG => [secondaryColor1,secondaryColor2];
}

Color getCircleAvatarColor(String entry) {
  if (entry.contains('Comment:')) {
    return AppColors.primaryColor1;
  } else if (entry.contains('History:')) {
    return AppColors.secondaryColor2;
  }
  return Colors.transparent; // Default color
}

Color getTextColor(String entry) {
  if (entry.startsWith('Comment:')) {
    return AppColors.secondaryColor2;
  } else if (entry.startsWith('History:')) {
    return AppColors.primaryColor1;
  }
  return Colors.transparent; // Default color
}

IconData getLeadingIcon(String entry) {
  if (entry.startsWith('Comment:')) {
    return Icons.comment;
  } else if (entry.startsWith('History:')) {
    return Icons.history;
  }
  return Icons.error; // Default icon
}