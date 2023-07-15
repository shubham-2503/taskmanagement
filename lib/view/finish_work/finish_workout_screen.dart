import 'package:Taskapp/common_widgets/round_gradient_button.dart';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:flutter/material.dart';

class FinishWorkScreen extends StatelessWidget {
  static String routeName = "/FinishWorkoutScreen";
  const FinishWorkScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 20,),
              Image.asset(
                "assets/images/complete_task.jpeg",
                height: media.width * 0.8,
                fit: BoxFit.fitHeight,
              ),

              const SizedBox(
                height: 20,
              ),

              Text(
                "Congratulations, You Have Finished Your Task",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.blackColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Text(
                "Nothing is so fatiguing as the eternal hanging on of an uncompleted task",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 12,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                "-William James",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.grayColor,
                  fontSize: 12,
                ),
              ),

              const Spacer(),
              RoundGradientButton(
                  title: "Back To Home",
                  onPressed: () {
                    Navigator.pop(context);
                  }),

              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
