import 'dart:io';

import 'package:app/src/services/compile_service.dart';
import 'package:app/src/services/user_management_system.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../components/custom_sliver_page_app_bar.dart';
import '../components/image_picker_button.dart';
import 'compile_result_page.dart';

class MainPage extends StatefulWidget {
  final double appBarBgHeight = 250;

  final Color themeColor;
  final String bgImagePath;

  const MainPage({
    super.key,
    required this.themeColor,
    required this.bgImagePath,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final double searchBgHeight = 300;
  Map<String, String>? _languages;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    Map<String, String>? languages =
        await CompileService.getAvailableLanguages();

    setState(() {
      _languages = languages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paper Compiler',
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
              pageTitle: "Paper Compiler",
              pageSubtitle: "Take a photo of your code (and input)",
            ),
            CompileForm(
              themeColor: widget.themeColor,
              languages: _languages,
            )
          ],
        ),
      ),
    );
  }
}

class CompileForm extends StatefulWidget {
  final Color themeColor;
  final Map<String, String>? languages;

  const CompileForm(
      {super.key, required this.themeColor, required this.languages});

  @override
  State<CompileForm> createState() => _CompileFormState();
}

class _CompileFormState extends State<CompileForm> {
  File? codeImage;
  File? codeInputImage;
  String? languageId;

  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: [
        const SizedBox(
          height: 30,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              "Code (required)",
              style: TextStyle(color: widget.themeColor),
            ),
          ),
        ),
        ImagePickerButton(
          updateImagePathCallback: (image) =>
              {setState(() => codeImage = image)},
          themeColor: widget.themeColor,
        ),
        const SizedBox(
          height: 30,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              "Code input (optional)",
              style: TextStyle(color: widget.themeColor),
            ),
          ),
        ),
        ImagePickerButton(
          updateImagePathCallback: (image) =>
              {setState(() => codeInputImage = image)},
          themeColor: widget.themeColor,
        ),
        const SizedBox(
          height: 50,
        ),
        Center(
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: Text(
                'Language',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
              ),
              items: widget.languages != null
                  ? widget.languages!.entries
                      .map((MapEntry<String, String> item) =>
                          DropdownMenuItem<String>(
                            value: item.key,
                            child: Text(
                              item.value,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ))
                      .toList()
                  : List.empty(),
              value: languageId,
              onChanged: (String? value) {
                setState(() {
                  languageId = value;
                });
              },
              buttonStyleData: const ButtonStyleData(
                padding: EdgeInsets.symmetric(horizontal: 16),
                height: 40,
                width: 140,
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 40,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        CompileButton(
          codeImage: codeImage,
          codeInputImage: codeInputImage,
          languageId: languageId,
        ),
        const SizedBox(
          height: 50,
        ),
      ],
    );
  }
}

class CompileButton extends StatefulWidget {
  final File? codeImage;
  final File? codeInputImage;
  final String? languageId;

  const CompileButton({
    super.key,
    required this.codeImage,
    required this.codeInputImage,
    required this.languageId,
  });

  @override
  State<CompileButton> createState() => _CompileButtonState();
}

class _CompileButtonState extends State<CompileButton> {
  var _isLoading = false;

  Future<Image?> _onSubmit() async {
    if (widget.codeImage == null || widget.languageId == null) {
      return null;
    }

    final userId = UserManagementSystem.getLocalUserId();
    if (userId == null) {
      return null;
    }

    setState(() => _isLoading = true);

    final compileImage = CompileService.compileCode(
      widget.codeImage!,
      widget.codeInputImage,
      widget.languageId!,
      userId,
    );

    setState(() => _isLoading = false);

    return compileImage;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed:
            _isLoading || widget.codeImage == null || widget.languageId == null
                ? null
                : () {
                    _onSubmit().then((value) => {
                          if (value != null)
                            {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CompileResultPage(image: value),
                                ),
                              )
                            }
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
            : const Icon(Icons.code),
        label: const Text('Compile'),
      ),
    );
  }
}
