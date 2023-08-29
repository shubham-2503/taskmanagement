import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class RoundGradientButton extends StatefulWidget {
  final String title;
  final Function() onPressed;

  const RoundGradientButton({Key? key, required this.title, required this.onPressed})
      : super(key: key);

  @override
  _RoundGradientButtonState createState() => _RoundGradientButtonState();
}

class _RoundGradientButtonState extends State<RoundGradientButton> {
  bool _isButtonClicked = false;

  void _handleClick() {
    if (!_isButtonClicked) {
      setState(() {
        _isButtonClicked = true;
      });

      widget.onPressed(); // Call the provided onPressed callback
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // Reset the _isButtonClicked state after the frame is built
      setState(() {
        _isButtonClicked = false;
      });
    });
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryG,
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
        child: MaterialButton(
          minWidth: double.maxFinite,
          height: 50,
          onPressed: _handleClick,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          textColor: AppColors.primaryColor1,
          child: Text(
            _isButtonClicked ? "Clicked" : widget.title,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.whiteColor,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
