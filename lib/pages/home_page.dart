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
      padding: EdgeInsets.only(top: 20, left: 15, right: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Algorithm demo',
                style: GoogleFonts.gotu(
                  textStyle: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.04,
                    decoration: TextDecoration.none,
                    color: Colors.black,
                  ),
                ),
              ),
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
          Container(
            height: MediaQuery.of(context).size.height * 0.37,
            padding: EdgeInsets.symmetric(horizontal: 20),
            color: Colors.transparent,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
                SizedBox(width: 30),
                AlgorithmCard('A*'),
                SizedBox(width: 30),
                AlgorithmCard('Ant Colony'),
                SizedBox(width: 30),
                AlgorithmCard('RRT*'),
                SizedBox(width: 30),
              ],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
