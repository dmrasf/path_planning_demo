import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_planning/components/algorithm_card.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Tooltip(
                message: '退出',
                child: TextButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: Icon(Icons.exit_to_app_rounded),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                    padding:
                        MaterialStateProperty.all(EdgeInsets.only(top: 30)),
                  ),
                ),
              ),
            ],
          ),
          Spacer(),
          Text(
            'Path Planning',
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                color: Colors.black,
                decoration: TextDecoration.none,
                fontSize: MediaQuery.of(context).size.height * 0.06,
              ),
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AlgorithmCard('A*'),
              AlgorithmCard('Ants'),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }
}
