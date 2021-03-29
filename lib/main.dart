import 'package:flutter/material.dart';
import 'package:path_planning/pages/home_page.dart';
import 'package:path_planning/model.dart';
import 'package:path_planning/theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyThemeModel(),
      child: Consumer<MyThemeModel>(
        builder: (context, theme, child) => MaterialApp(
          title: 'Path Planning',
          debugShowCheckedModeBanner: false,
          theme: theme.isLightTheme ? MyTheme.lightTheme : MyTheme.darkTheme,
          home: HomePage(),
        ),
      ),
    );
  }
}
