

import 'package:attt/utils/size_config.dart';
import 'package:flutter/material.dart';

Widget asManyReps(BuildContext context, String repsDescription) {
   return Container(
     alignment: Alignment.center,
     margin: EdgeInsets.only(
         top: MediaQuery.of(context)
             .orientation ==
             Orientation.landscape
             ? SizeConfig.blockSizeVertical * 0
             : SizeConfig.blockSizeVertical *
           19,
         right: MediaQuery.of(context)
             .orientation ==
             Orientation.landscape
             ? SizeConfig.blockSizeHorizontal *
             0
             : SizeConfig.blockSizeHorizontal *
             0,
         left: MediaQuery.of(context)
             .orientation ==
             Orientation.landscape
             ? SizeConfig.blockSizeHorizontal *
             0
             : SizeConfig.blockSizeHorizontal *
             32),
     width: MediaQuery.of(context)
         .orientation ==
         Orientation.landscape
         ? SizeConfig.blockSizeHorizontal * 20
         : SizeConfig.blockSizeHorizontal * 35,
     height: MediaQuery.of(context)
         .orientation ==
         Orientation.landscape
         ? SizeConfig.blockSizeVertical * 14 : SizeConfig.blockSizeVertical * 8,
     child: Text(
       repsDescription != null ? repsDescription.toUpperCase() : '',
       //'AS MANY REPS AS POSSIBLE',
       style: TextStyle(
           color: Colors.white,
           fontWeight: FontWeight.w600,
           fontStyle: FontStyle.italic,
           fontSize: MediaQuery.of(context)
               .orientation ==
               Orientation.landscape
               ? SizeConfig.safeBlockVertical*
               4
               : SizeConfig.safeBlockHorizontal *
               4),
       textAlign: TextAlign.center,
     ),
   );
}