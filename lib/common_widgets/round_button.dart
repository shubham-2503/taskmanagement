import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

enum RoundButtonType { primaryBG, secondaryBG }

class RoundButton extends StatelessWidget {
  final String title;
  final RoundButtonType type;
  final IconData? icon;
  final Function() onPressed;
  final List<DropdownMenuItem<String>>? items;

  const RoundButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.type = RoundButtonType.secondaryBG,
    this.icon,
    this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: type == RoundButtonType.secondaryBG
              ? AppColors.secondaryG
              : AppColors.primaryG,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        itemBuilder: (BuildContext context) {
          if (items == null || items!.isEmpty) {
            return [];
          }

          return items!.map((DropdownMenuItem<String> item) {
            return PopupMenuItem<String>(
              value: item.value,
              child: ListTile(
                title: item.child!,
                onTap: () {
                  Navigator.pop(context, item.value);
                },
              ),
            );
          }).toList();
        },
        child: MaterialButton(
          minWidth: double.maxFinite,
          height: 50,
          onPressed: onPressed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textColor: AppColors.primaryColor2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: AppColors.whiteColor,
                  size: 16,
                ),
                SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.whiteColor,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
