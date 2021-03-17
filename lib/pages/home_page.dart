import 'package:flutter/material.dart';
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AlgorithmCard('A*'),
              AlgorithmCard('Ants'),
            ],
          ),
        ],
      ),
    );
  }
}
