import 'package:attt/utils/colors.dart';
import 'package:attt/utils/globals.dart';
import 'package:attt/utils/size_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:attt/view/chooseAthlete/widgets/nameHeadline.dart';
import 'package:attt/view/chooseAthlete/widgets/trainerList.dart';
import 'package:attt/utils/customScreenAnimation.dart';
import 'package:attt/view/settings/pages/settingsPage.dart';
import 'dart:io';

class ChooseAthlete extends StatefulWidget {
  final String name, email, photo, userUID;
  final DocumentSnapshot userDocument;
  ChooseAthlete({Key key, this.email, this.name, this.photo, this.userDocument, this.userUID}) : super(key: key);

  @override
  _ChooseAthleteState createState() => _ChooseAthleteState();
}

class _ChooseAthleteState extends State<ChooseAthlete> {
  
  @override
  void initState() { 
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
  
    SizeConfig().init(context);
    String usersName = widget.name;
    String usersPhoto = widget.photo;
    String userUID = widget.userUID;

    return Scaffold(
      backgroundColor: MyColors().lightBlack,
      body: WillPopScope(
        onWillPop: () =>  _onWillPop(context),
              child: ListView(
          children: <Widget>[
            nameHeadline(usersName, usersPhoto, context, widget.userDocument),
            trainersList(context, userName, userPhoto, userEmail, widget.userDocument, userUID),
          ],
        ),
      ),
    );
  }
}


_onWillPop(BuildContext context) {
  print(isFromSettings.toString() + ' SETTINGS');
  isFromSettings ? Navigator.of(context)
              .pop() : exit(0);
  isFromSettings = false;
}