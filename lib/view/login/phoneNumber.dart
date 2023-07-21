import 'package:Taskapp/common_widgets/round_gradient_button.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/round_textfield.dart';
import '../../utils/app_colors.dart';

class PhoneNumber extends StatefulWidget {
  @override
  State<PhoneNumber> createState() => _PhoneNumberState();
}

class _PhoneNumberState extends State<PhoneNumber> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Enter Your Phone Number",
                  style: TextStyle(
                    color: AppColors.primaryColor2,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 40),
                RoundTextField(
                  textEditingController: _phoneNumberController,
                  hintText: "Phone Number",
                  icon: "assets/icons/pho.png",
                  textInputType: TextInputType.phone,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Phone number is required';
                    }
                    if (!value.startsWith('+')) {
                      return 'Please include the country code';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),
                RoundGradientButton(
                  title: "Proceed",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Proceed with the phone number
                      String phoneNumber = _phoneNumberController.text;
                      // Add your logic here for processing the phone number
                      print('Phone number: $phoneNumber');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
