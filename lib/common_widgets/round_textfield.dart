import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class RoundTextField extends StatelessWidget {
  final TextEditingController? textEditingController;
  final String hintText;
  final String icon;
  final TextInputType? textInputType;
  final bool isReadOnly;
  final bool isObscureText;
  final Widget? rightIcon;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final String? Function(String?)? validator; // Add validator property

  const RoundTextField({
    Key? key,
    this.textEditingController,
    required this.hintText,
    required this.icon,
    this.textInputType,
    this.isObscureText = false,
    this.rightIcon,
    this.onChanged,
    this.onTap,
    this.isReadOnly = false,
    this.validator, // Initialize validator property
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrayColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField( // Replace TextField with TextFormField
        controller: textEditingController,
        readOnly: isReadOnly,
        keyboardType: textInputType,
        obscureText: isObscureText,
        onChanged: onChanged,
        onTap: onTap,
        validator: validator, // Assign validator property
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hintText,
          prefixIcon: Container(
            alignment: Alignment.center,
            width: 20,
            height: 20,
            child: Image.asset(
              icon,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
          suffixIcon: rightIcon,
          hintStyle: TextStyle(fontSize: 12, color: AppColors.grayColor),
        ),
      ),
    );
  }
}


