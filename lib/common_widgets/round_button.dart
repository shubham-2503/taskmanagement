import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

enum RoundButtonType { primaryBG, secondaryBG }

class RoundButton extends StatefulWidget {
  final String title;
  final RoundButtonType type;
  final IconData? icon;
  final Function() onPressed;
  final List<DropdownMenuItem<String>>? items;
  final bool isClickable;

  const RoundButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.type = RoundButtonType.secondaryBG,
    this.icon,
    this.items, this.isClickable = true,
  }) : super(key: key);

  @override
  State<RoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<RoundButton> {
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.type == RoundButtonType.secondaryBG
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
          if (widget.items == null || widget.items!.isEmpty) {
            return [];
          }

          return widget.items!.map((DropdownMenuItem<String> item) {
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
          onPressed: (widget.isClickable && !isClicked)
              ? () {
            setState(() {
              isClicked = true;
            });
            widget.onPressed();
          }
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textColor: AppColors.primaryColor2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: AppColors.whiteColor,
                  size: 16,
                ),
                SizedBox(width: 8),
              ],
              Text(
                widget.title,
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
