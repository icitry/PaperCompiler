import 'dart:io';

import 'package:app/src/components/image_picker_button.dart';
import 'package:app/src/services/user_management_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/custom_sliver_page_app_bar.dart';
import '../services/routing_service.dart';

class RegisterPage extends StatefulWidget {
  final double appBarBgHeight = 250;

  final Color themeColor;
  final String bgImagePath;

  const RegisterPage({
    super.key,
    required this.themeColor,
    required this.bgImagePath,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register Page',
      theme: ThemeData(
        colorSchemeSeed: widget.themeColor,
      ),
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            CustomSliverPageAppBar(
              appBarBgHeight: widget.appBarBgHeight,
              bgImagePath: widget.bgImagePath,
              themeColor: widget.themeColor,
              pageTitle: "Welcome",
              pageSubtitle: "Take a photo of your handwriting to begin",
            ),
            RegisterForm(
              themeColor: widget.themeColor,
            )
          ],
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  final Color themeColor;

  const RegisterForm({
    super.key,
    required this.themeColor,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  File? handwritingImage;

  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: [
        const SizedBox(
          height: 50,
        ),
        ImagePickerButton(
          updateImagePathCallback: (image) =>
              {setState(() => handwritingImage = image)},
          themeColor: widget.themeColor,
        ),
        const SizedBox(
          height: 50,
        ),
        RegisterButton(handwritingImage: handwritingImage),
      ],
    );
  }
}

class RegisterButton extends StatefulWidget {
  final File? handwritingImage;

  const RegisterButton({
    super.key,
    required this.handwritingImage,
  });

  @override
  State<RegisterButton> createState() => _RegisterButtonState();
}

class _RegisterButtonState extends State<RegisterButton> {
  var _isLoading = false;

  Future<String?> _onSubmit() async {
    if (widget.handwritingImage == null) {
      return null;
    }

    setState(() => _isLoading = true);

    final userId =
        await UserManagementSystem.registerUser(widget.handwritingImage!);

    setState(() => _isLoading = false);

    return userId;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _isLoading || widget.handwritingImage == null
            ? null
            : () {
                _onSubmit().then((value) => {
                      if (value != null) {context.pushReplacement(Routes.main)}
                    });
              },
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16.0)),
        icon: _isLoading
            ? Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2.0),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Icon(Icons.login),
        label: const Text('Register'),
      ),
    );
  }
}
