import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/on_boarding/widgets/pager_widget.dart';
import 'package:Taskapp/view/signup/signup_screen.dart';
import 'package:flutter/material.dart';

class OnBoardingScreen extends StatefulWidget {
  static String routeName = "/OnBoardingScreen";
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  PageController pageController = PageController();
  List pageList = [
    {
      "subtitle":
          "Don't worry if you have trouble determining your goals, We can help you determine your goals and track your goals",
      "image": "assets/images/pm.jpeg"
    },
    {
      "subtitle":
          "The best way to get a project done faster is to start sooner.",
      "image": "assets/images/pm-2.png"
    },
    {
      "subtitle":
          "A goal without a timeline is just a dream",
      "image": "assets/images/pm-3.jpeg"
    },
    {
      "subtitle":
          "There are no unrealistic goals, only unrealistic deadlines",
      "image": "assets/images/pm-4.webp"
    }
  ];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bagroud.png"), // Replace with your background image
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 300),
          child: Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: pageList.length,
                  onPageChanged: (i) {
                    setState(() {
                      selectedIndex = i;
                    });
                  },
                  itemBuilder: (context, index) {
                    var temp = pageList[index] as Map? ?? {};
                    return PagerWidget(obj: temp);
                  },
                ),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor2,
                          value: (selectedIndex+1) / 4,
                          strokeWidth: 3,
                        ),
                      ),
                      Container(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            color: AppColors.primaryColor2),
                        child: IconButton(
                          icon: const Icon(
                            Icons.navigate_next,
                            color: AppColors.whiteColor,
                          ),
                          onPressed: () {
                            if (selectedIndex < 3) {
                              selectedIndex = selectedIndex + 1;
                              pageController.animateToPage(selectedIndex,
                                  duration: const Duration(milliseconds: 700),
                                  curve: Curves.easeInSine);
                            }
                            else{
                              Navigator.pushNamed(context, SignupScreen.routeName);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
