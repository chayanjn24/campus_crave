import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SignUpPage());
}

// ignore: must_be_immutable
class SignUpPage extends StatelessWidget {
  var isHide = true;
  bool isStrongPassword = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController retypePasswordController = TextEditingController();

  SignUpPage({Key? key}) : super(key: key);

  bool checkStrongPassword(String password) {
    // Define patterns for each requirement
    RegExp capitalLetterRegex = RegExp(r'[A-Z]');
    RegExp smallLetterRegex = RegExp(r'[a-z]');
    RegExp numberRegex = RegExp(r'[0-9]');
    RegExp specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    // Check if the password meets all requirements
    bool hasCapitalLetter = capitalLetterRegex.hasMatch(password);
    bool hasSmallLetter = smallLetterRegex.hasMatch(password);
    bool hasNumber = numberRegex.hasMatch(password);
    bool hasSpecialChar = specialCharRegex.hasMatch(password);

    return isStrongPassword = password.length >= 8 &&
        hasCapitalLetter &&
        hasSmallLetter &&
        hasNumber &&
        hasSpecialChar;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    List<String> hostelOptions = [
      'Choose Your Hostel',
      'Aryabhatta',
      'BH-1',
      'BH-2',
      'BH-3',
      'BH-4',
      'BH-5',
      'BH-6',
      'BH-7',
      'BH-8',
      'BH-9A',
      'BH-9B',
      'BH-9C',
      'BH-9D',
      'GH-1',
      'GH-2',
      'GH-3'
    ];

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAnimatedTextField(
                  "Institute Email",
                  "Enter your institute email id",
                  controller: emailController,
                ),
                SizedBox(height: 10),
                _buildAnimatedTextField(
                  "Phone Number",
                  "Enter your Phone Number",
                  controller: phoneNumberController,
                ),
                SizedBox(height: 10),
                _buildAnimatedTextFieldPasswordOnly(
                  "Password",
                  "Enter your password",
                  isPassword: true,
                  controller: passwordController,
                ),
                SizedBox(height: 10),
                _buildAnimatedTextField(
                  "Retype Password",
                  "Retype your password",
                  isPassword: true,
                  controller: retypePasswordController,
                ),
                SizedBox(height: 10),
                _buildAnimatedDropdownField(
                  hostelOptions,
                  "Select Hostel",
                  hostelOptions[0],
                ),
                SizedBox(height: 10),
                _buildContinueButton(context),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextFieldPasswordOnly(String label, String hintText,
      {bool isPassword = false, TextEditingController? controller}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      height: 120, // Increased height to accommodate the hint text
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Password Requirements: Minimum 8 characters, at least one uppercase letter, one lowercase letter, one number, and one special character.",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 5),
          TextFormField(
            obscureText: isPassword,
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: hintText,
              border: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 3,
                  color: Colors.greenAccent,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

//! GRADLE IS NOT WORKING
  Widget _buildAnimatedTextField(String label, String hintText,
      {bool isPassword = false, TextEditingController? controller}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      height: 70,
      child: TextFormField(
        obscureText: isPassword,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 3,
              color: Colors.greenAccent,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDropdownField(
      List<String> options, String label, String selectedValue) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      height: 70,
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (String? newValue) {},
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 3,
              color: Colors.greenAccent,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (checkStrongPassword(passwordController.text)) {
          //? Password is strong, navigate to HomeScreen
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => HomeScreen(),
          //   ),
          // );
        } else {
          // Password is weak, handle accordingly (show error, etc.)
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEBBE5A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          "Continue",
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
