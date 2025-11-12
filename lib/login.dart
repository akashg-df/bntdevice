import 'dart:io';

import 'package:dfdevicewebview/component/login_comp.dart';
import 'package:dfdevicewebview/responsive.dart';
import 'package:dfdevicewebview/typography.dart';
import 'package:dfdevicewebview/utli/loader_utils.dart';
import 'package:dfdevicewebview/webview/admin_twx_dashboard.dart';
import 'package:dfdevicewebview/webview/customer_view.dart';
import 'package:dfdevicewebview/widget/fieldheading_widget.dart';
import 'package:dfdevicewebview/widget/text_field_widget.dart';
import 'package:dfdevicewebview/widget/text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import 'controller/login_controller.dart';

class LoginView extends StatefulWidget {
  String? clientId;

  LoginView({super.key, this.clientId});

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends StateMVC<LoginView> {
  // no `late` needed
  LoginController get loginController => controller as LoginController;

  _LoginViewState() : super(LoginController());

  TextEditingController userEmail = TextEditingController(text: 'testing23@mailinator.com');
  TextEditingController userPass = TextEditingController(text: 'Qwerty@123');

  bool isPassVisible = true;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      child: Responsive(
        mobile: mobileView(width, height),
        tablet: tabletView(width, height),
        desktop: desktopView(width, height),
      ),
    );
  }

  mobileView(width, height) {
    return Scaffold(
      backgroundColor: priBg,
      body: loading ? LoaderUtils().circularLoader() : mobileBodyView(),
    );
  }

  tabletView(width, height) {
    return Scaffold(
      backgroundColor: priBg,
      body: loading ? LoaderUtils().circularLoader() : mobileBodyView(),
    );
  }

  desktopView(width, height) {
    return Scaffold(
      backgroundColor: priBg,
      body: loading ? LoaderUtils().circularLoader() : mobileBodyView(),
    );
  }

  Widget mobileBodyView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          SizedBox(
            height: 130,
            child: Image.asset(
              'assets/df.png',
              fit: BoxFit.contain,
            ),
          ),
          TextWidget(
            text: "Better Air, Better life",
            color: priText,
            fontsize: headlineSmall,
            letterspacing: 0.5,
            oflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 15),

          // Login Card
          Container(
            decoration: BoxDecoration(
              color: priBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.arrow_right_circle,
                  size: 50,
                  color: buttonNavy,
                ),
                const SizedBox(height: 10),
                TextWidget(
                  text: "Sign In",
                  color: priText,
                  fontsize: headlineSmall,
                  fontWeight: bold,
                  letterspacing: 0.5,
                  oflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),

                buildLoginMobileForm(),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildLoginMobileForm() {
    return Form(
      key: loginController.loginKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Headingtextwidget(text1: "Email Address"),
          emailField(),
          const SizedBox(height: 20),
          const Headingtextwidget(text1: "Password"),
          passField(),
          const SizedBox(height: 30),

          // Login Button
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () async {
                setState(() => loading = true);

                String validatorRes = loginController.validateLoginCred();
                if (validatorRes == 'pass') {
                  bool success = await loginController.loginUser();

                  if (success) {
                    setState(() => loading = false);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => AdminTwxDashboard(),
                      ),
                    );
                  } else {
                    setState(() => loading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Login failed. Please try again."),
                      ),
                    );
                  }
                } else {
                  setState(() => loading = false);
                }
              },
              child: LoginComp().buildSubmitBttn(),
            ),
          ),
        ],
      ),
    );
  }

  Widget emailField() {
    return InputTextField(
      controller: userEmail,
      isValidatorEnable: true,
      enabled: true,
      validator: (value) {
        loginController.loginModel.userEmail = value;
        if (loginController.emailValidator(value) == "pass") {
          return null;
        } else {
          return loginController.emailValidator(value);
        }
      },
      onSaved: (value) => loginController.loginModel.userEmail = value,
      hintText: 'Email',
      prefixIcon: CupertinoIcons.mail_solid,
    );
  }

  Widget passField() {
    return InputTextField(
      controller: userPass,
      isValidatorEnable: true,
      enabled: true,
      validator: (value) {
        loginController.loginModel.userPass = value;
        if (loginController.passValidator(value) == "pass") {
          return null;
        } else {
          return loginController.passValidator(value);
        }
      },
      onSaved: (value) => loginController.loginModel.userPass = value,
      prefixIcon: CupertinoIcons.lock,
      hintText: 'Password',
    );
  }
}

