import 'dart:io';
import 'package:flutter/material.dart';

final GlobalKey showMapKey = GlobalKey();
final GlobalKey showMapKeyForAnt = GlobalKey();
final GlobalKey showPathDiatance = GlobalKey();

Future<String> pickFile(String extension) async {
  bool _noExtension = false;

  ProcessResult pr = await Process.run('which', ['zenity'], runInShell: true);
  if (pr.exitCode != 0) {
    print("zenity not found.");
    return null;
  } else
    print("zenity found.");

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
