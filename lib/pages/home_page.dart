import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_planning/pages/algorithm_show.dart';
import 'package:path_planning/components/my_button.dart';
import 'package:path_planning/components/choose_map.dart';
import 'package:path_planning/components/random_map_show.dart';
import 'package:path_planning/model.dart';
import 'package:path_planning/utils.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Algorithm demo',
                style: GoogleFonts.arvo(
                  textStyle: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.05,
                    decoration: TextDecoration.none,
                    color: Theme.of(context).textTheme.headline1.color,
                  ),
                ),
              ),
              Spacer(),
              ChangeThemeButton(),
              SizedBox(width: 15),
              Tooltip(
                message: '退出',
                child: TextButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: Icon(Icons.exit_to_app_rounded),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                    minimumSize: MaterialStateProperty.all(Size.zero),
                  ),
                ),
              ),
            ],
          ),
          Spacer(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyShowMapButton(
                  () => pickFile('json').then(
                    (fileName) {
                      if (fileName != null && fileName != '') {
                        File f = File(fileName);
                        f.readAsString().then((value) => fadeChangePage(
                              context,
                              AlgorithmShow(value),
                            ));
                      }
                    },
                  ),
                  'Pick map file',
                ),
                SizedBox(height: 30),
                MyShowMapButton(
                  () => fadeChangePage(context, ChooseMap()),
                  'Choose map',
                ),
                SizedBox(height: 30),
                MyShowMapButton(
                  () => fadeChangePage(
                    context,
                    RandomMapShow(key: randomMapKey),
                  ),
                  'Random map',
                ),
              ],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}

class ChangeThemeButton extends StatefulWidget {
  @override
  _ChangeThemeButtonState createState() => _ChangeThemeButtonState();
}

class _ChangeThemeButtonState extends State<ChangeThemeButton> {
  bool _isLight = true;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyThemeModel>(context);
    return TextButton(
      onPressed: () => setState(() {
        _isLight = !_isLight;
        provider.changeTheme(_isLight);
      }),
      child: Icon(
        _isLight ? Icons.bedtime : Icons.brightness_high,
        size: 20,
        color: _isLight ? Colors.black : Colors.white,
      ),
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(Size.zero),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      ),
    );
  }
}
