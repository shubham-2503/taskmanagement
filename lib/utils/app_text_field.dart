import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_style.dart';


class AppTextField extends StatefulWidget {
  final TextEditingController textController;
  final String titleText;
  final String hintText;
  final FocusNode node;
  final bool isPassword;
  final bool isReadonly;
  final int maxLine;
  AppTextField({Key? key,this.maxLine=1,required this.textController,required this.node,this.hintText="",this.titleText="",this.isReadonly=false,this.isPassword=false}) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool isPasswordHideShow = true;
  @override
  void initState() {
    isPasswordHideShow=widget.isPassword;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            widget.titleText,
            style: AppTextStyle.regular.copyWith(
              color: AppColors.grayColor,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 5,),
      ],
    );
  }
}
