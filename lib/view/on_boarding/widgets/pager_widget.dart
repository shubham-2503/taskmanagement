import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class PagerWidget extends StatelessWidget {

  final Map obj;

  const PagerWidget({Key? key, required this.obj}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return SizedBox(
      width: media.width,
      height: media.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(obj["image"],width: media.width,fit: BoxFit.fitWidth),
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  SizedBox(
                    width: 315,
                    child: Center(
                      child: Text(
                        obj["subtitle"],
                        style: const TextStyle(
                          color: AppColors.grayColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                ],
              )
          ),
        ],
      ),
    );
  }
}
