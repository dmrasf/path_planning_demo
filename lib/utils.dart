import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:math' show Random;

final GlobalKey showMapKeyForA = GlobalKey();
final GlobalKey showMapKeyForAnt = GlobalKey();
final GlobalKey showMapKeyForRRT = GlobalKey();
final GlobalKey showPathDiatance = GlobalKey();
final List<String> mapData = [
  'assets/maps/map_data_1.json',
  'assets/maps/map_data_2.json',
  'assets/maps/map_data_3.json',
  'assets/maps/map_data_4.json',
  'assets/maps/map_data_5.json',
  'assets/maps/map_data_6.json',
];

Future<String> pickFile(String extension) async {
  bool _noExtension = false;

  ProcessResult pr = await Process.run('which', ['zenity'], runInShell: true);
  if (pr.exitCode != 0) {
    print("zenity not found.");
    return null;
  }

  if (extension == "undefined") {
    _noExtension = true;
    print("WARNING: extension not specified.");
  }

  pr = await Process.run(
    'zenity',
    [
      '--file-selection',
      !_noExtension ? '--file-filter=' + '*.' + extension + '' : '',
    ],
    runInShell: false,
  );

  if (pr.exitCode != 0) {
    print("user canceled choice.");
    print(pr.stderr.toString());
    print(pr.stdout.toString());
    return null;
  } else
    return pr.stdout.toString().trim();
}

Future<String> buildMap(String fileName) async {
  ProcessResult pr = await Process.run(
    'my_map.py',
    [fileName],
    runInShell: true,
  );

  if (pr.exitCode != 0) {
    print("user canceled choice.");
    print(pr.stderr.toString());
    print(pr.stdout.toString());
    return null;
  } else
    return pr.stdout.toString().trim();
}

T randomChoice<T>(Iterable<T> options, [Iterable<double> weights = const []]) {
  if (options.isEmpty) {
    throw ArgumentError.value(
        options.toString(), 'options', 'must be non-empty');
  }
  if (weights.isNotEmpty && options.length != weights.length) {
    throw ArgumentError.value(weights.toString(), 'weights',
        'must be empty or match length of options');
  }

  if (weights.isEmpty) {
    return options.elementAt(Random().nextInt(options.length));
  }

  double sum = weights.reduce((val, curr) => val + curr);
  double randomWeight = Random().nextDouble() * sum;

  int i = 0;
  for (int l = options.length; i < l; i++) {
    randomWeight -= weights.elementAt(i);
    if (randomWeight <= 0) {
      break;
    }
  }

  return options.elementAt(i);
}

void showSnakBar(BuildContext context, String s) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        s,
        style: GoogleFonts.jua(
          textStyle: TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      duration: Duration(milliseconds: 200),
      backgroundColor: Colors.grey.withOpacity(0.5),
    ),
  );
}

void fadeChangePage(BuildContext context, Widget widget) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
        opacity: animation.drive(
          Tween(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: Curves.ease),
          ),
        ),
        child: child,
      ),
    ),
  );
}

void slideChangePage(BuildContext context, Widget widget) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: animation.drive(
          Tween(begin: Offset(0, 1), end: Offset(0, 0)).chain(
            CurveTween(curve: Curves.ease),
          ),
        ),
        child: child,
      ),
    ),
  );
}

Future<bool> saveRoute(
  String path,
  List<int> pathRoute,
  Map<String, dynamic> myMap,
  List<dynamic> visualPoints,
) async {
  double grid = myMap['grid'].toDouble();
  List<dynamic> start = myMap['start'];
  List<dynamic> end = myMap['end'];
  List<List<dynamic>> realPath = [start];
  for (int i = 1; i < pathRoute.length - 1; i++)
    realPath.add([
      (num.parse(
        (visualPoints[pathRoute[i]][0] * grid).toStringAsFixed(2),
      )),
      (num.parse(
        (visualPoints[pathRoute[i]][1] * grid).toStringAsFixed(2),
      ))
    ]);
  realPath.add(end);
  String pathStr = jsonEncode(realPath);
  File f = File(path);
  await f.create();
  await f.writeAsString(pathStr);
  return true;
}

double calculatePathDistance(
  List<dynamic> visualGraph,
  List<int> pathRoute,
) {
  double pathDistance = 0;
  for (int i = 0; i < pathRoute.length - 1; i++) {
    pathDistance += visualGraph[pathRoute[i]][pathRoute[i + 1]];
  }
  return pathDistance;
}
