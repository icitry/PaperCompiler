import 'package:flutter/material.dart';

class CustomSliverPageAppBar extends StatelessWidget {
  final double appBarBgHeight;
  final String bgImagePath;
  final Color themeColor;
  final String pageTitle;
  final String pageSubtitle;

  const CustomSliverPageAppBar({
    super.key,
    required this.appBarBgHeight,
    required this.bgImagePath,
    required this.themeColor,
    required this.pageTitle,
    required this.pageSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 50,
      expandedHeight: appBarBgHeight,
      backgroundColor: themeColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              bgImagePath,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 300, maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          pageTitle,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                            bottom: 20,
                          ),
                          child: Text(
                            pageSubtitle,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
