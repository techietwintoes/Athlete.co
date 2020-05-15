import 'package:attt/utils/size_config.dart';
import 'package:attt/utils/text.dart';
import 'package:attt/view_model/trainingPlanViewModel.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget messengerButton(BuildContext context) {
  SizeConfig().init(context);
  return GestureDetector(
    onTap: () => TrainingPlanViewModel().launchMessenger(),
    child: Container(
      height: SizeConfig.blockSizeVertical * 4.7,
      width: SizeConfig.blockSizeHorizontal * 49,
      margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
      padding: EdgeInsets.all(7.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color: Color.fromRGBO(225, 225, 225, 1.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            FontAwesomeIcons.facebookMessenger,
            color: Colors.blueAccent,
            size: SizeConfig.blockSizeVertical * 2.8,
          ),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal * 3,
          ),
          Text(
            MyText().anyQ,
            style: TextStyle(
                color: Colors.blueAccent,
                fontFamily: 'Roboto',
                fontSize: SizeConfig.blockSizeVertical * 2.2,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
 