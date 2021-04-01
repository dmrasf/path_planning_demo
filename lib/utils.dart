import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:math' show Random;

final GlobalKey showMapKeyForA = GlobalKey();
final GlobalKey showMapKeyForAnt = GlobalKey();
final GlobalKey showMapKeyForRRT = GlobalKey();
final GlobalKey showPathDiatance = GlobalKey();
final GlobalKey randomMapKey = GlobalKey();
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

Future<void> fadeChangePage(BuildContext context, Widget widget) async {
  return await Navigator.of(context).push(
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

Future<void> slideChangePage(BuildContext context, Widget widget) async {
  return await Navigator.of(context).push(
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

class RandomMapGeneration {
  final double blankSize;
  final double wallThickness;
  final double border;
  final int widthBlock;
  final int heigthBlock;
  final int blocksLength;
  final Set<int> allBlocks;
  final bool isRemove;
  RandomMapGeneration({
    this.blankSize = 0.6,
    this.wallThickness = 0.15,
    this.border = 0.4,
    this.widthBlock = 14,
    this.heigthBlock = 14,
    this.isRemove = false,
  })  : blocksLength = widthBlock * heigthBlock,
        allBlocks = List.generate(widthBlock * heigthBlock, (i) => i).toSet();

  Map<String, dynamic> randomMapGeneration() {
    Map<String, dynamic> walls = {};
    List<List<int>> horizontal = List.generate(
      heigthBlock - 1,
      (_) => List.generate(widthBlock, (_) => 1),
    );
    List<List<int>> vertical = List.generate(
      widthBlock - 1,
      (_) => List.generate(heigthBlock, (_) => 1),
    );

    Set<int> closeBlocks = {};
    Queue<int> openBlocks = Queue<int>();
    int start = Random(Timeline.now).nextInt(blocksLength);
    int current = start;
    openBlocks.addLast(current);
    while (true) {
      int next = _getNextBlock(current, openBlocks.toSet().union(closeBlocks));
      if (next != -1) {
        _changeWall(current, next, horizontal, vertical);
        openBlocks.addLast(next);
        current = next;
      } else {
        current = openBlocks.removeLast();
        closeBlocks.add(current);
        if (closeBlocks.length == blocksLength) break;
        current = openBlocks.last;
      }
    }

    if (isRemove) {
      Set<int> randomChange = {};
      for (int i = 0; i < horizontal.length ~/ 2; i++) {
        while (randomChange.length < horizontal.length ~/ 2) {
          int n = Random(Timeline.now).nextInt(horizontal.length);
          if (!randomChange.contains(n)) randomChange.add(n);
        }
      }
      for (int p in randomChange) {
        for (int i = 0; i < widthBlock ~/ 4; i++)
          horizontal[p][Random(Timeline.now).nextInt(widthBlock)] = 0;
      }
      randomChange.clear();
      for (int i = 0; i < vertical.length ~/ 2; i++) {
        while (randomChange.length < vertical.length ~/ 2) {
          int n = Random(Timeline.now).nextInt(vertical.length);
          if (!randomChange.contains(n)) randomChange.add(n);
        }
      }
      for (int p in randomChange) {
        for (int i = 0; i < heigthBlock ~/ 4; i++)
          vertical[p][Random(Timeline.now).nextInt(heigthBlock)] = 0;
      }
    }

    walls['horizontal'] = horizontal;
    walls['vertical'] = vertical;
    walls['border'] = border;
    walls['widthBlock'] = widthBlock;
    walls['heigthBlock'] = heigthBlock;
    walls['blankSize'] = blankSize;
    walls['wallThickness'] = wallThickness;
    walls['type'] = 'random map';
    walls['name'] = 'random map';
    walls['grid'] = 0.05;
    walls['robotSize'] = 0.3;
    walls['start'] = [border + blankSize / 2, border + blankSize / 2];
    walls['end'] = [
      border +
          (heigthBlock - 0.5) * blankSize +
          (heigthBlock - 1) * wallThickness,
      border +
          (widthBlock - 0.5) * blankSize +
          (widthBlock - 1) * wallThickness,
    ];
    return walls;
  }

  List<int> _toXY(int current) {
    int x = current ~/ widthBlock;
    int y = current % widthBlock;
    return [x, y];
  }

  int _getNextBlock(int current, Set<int> oldBlocks) {
    int top = current - widthBlock;
    int bottom = current + widthBlock;
    int left = current - 1;
    int right = current + 1;
    List<int> blocks = [];
    if (top >= 0) blocks.add(top);
    if (bottom <= blocksLength - 1) blocks.add(bottom);
    blocks.addAll([left, right]);
    if (current % widthBlock == 0) blocks.remove(left);
    if (current % widthBlock == widthBlock - 1) blocks.remove(right);
    blocks = blocks.toSet().difference(oldBlocks).toList();
    if (blocks.isEmpty) return -1;
    return blocks[Random(Timeline.now).nextInt(blocks.length)];
  }

  void _changeWall(
    int current,
    int next,
    List<List<int>> horizontal,
    List<List<int>> vertical,
  ) {
    List<int> cXY = _toXY(current);
    List<int> nXY = _toXY(next);
    int w = -1, h = -1;
    if (cXY[0] != nXY[0]) w = cXY[0] > nXY[0] ? nXY[0] : cXY[0];
    if (cXY[1] != nXY[1]) h = cXY[1] > nXY[1] ? nXY[1] : cXY[1];
    if (w != -1) horizontal[w][cXY[1]] = 0;
    if (h != -1) vertical[h][cXY[0]] = 0;
  }
}
