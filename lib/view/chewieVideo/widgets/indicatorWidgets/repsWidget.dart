import 'package:attt/utils/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget repsWidget(
    BuildContext context, int isReps, var reps, String exerciseTime) {
  return Container(
    alignment: Alignment.center,
    height: MediaQuery.of(context).orientation == Orientation.landscape
        ? null
        : SizeConfig.blockSizeHorizontal * 9,
    child: Text(
      reps.toString().length <= 2 ? 'x ' + reps.toString() : reps.toString(),
      style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          fontSize: MediaQuery.of(context).orientation == Orientation.landscape
              ? SizeConfig.safeBlockVertical * 4
              : SizeConfig.safeBlockHorizontal * 4),
    ),
  );
}
