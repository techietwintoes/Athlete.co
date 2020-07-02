import 'package:attt/utils/size_config.dart';
import 'package:attt/view/chewieVideo/widgets/addNote.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_box/video.controller.dart';

Widget noteButton(
  BuildContext context,
  bool noteClicked,
  isFromPortrait,
  isOrientationFull,
  VideoController controller,
  DocumentSnapshot userDocument,
  userTrainerDocument,
  int index,
  listLenght,
  isReps,
  sets,
  var reps,
  String name,
  workoutID,
  weekID,
  Function pauseTimer,
) {
  return Container(
    height: SizeConfig.blockSizeHorizontal * 10,
    width: SizeConfig.blockSizeHorizontal * 10,
    child: ClipOval(
        child: Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          pauseTimer();
          if (noteClicked) {
            noteClicked = false;
            controller.pause();
            if (MediaQuery.of(context).orientation == Orientation.portrait)
              isFromPortrait = true;
            else
              isFromPortrait = false;
            Navigator.of(context).push(
              MaterialPageRoute(
                maintainState: true,
                builder: (_) => AddNote(
                  controller: controller,
                  listLenght: listLenght,
                  userDocument: userDocument,
                  userTrainerDocument: userTrainerDocument,
                  index: index,
                  isReps: isReps,
                  reps: reps,
                  sets: sets,
                  name: name,
                  workoutID: workoutID,
                  weekID: weekID,
                  isOrientationFull: isOrientationFull,
                ),
              ),
            );
          } else {
            print('');
          }
        },
        child: Container(
          child: Center(
            child: Icon(
              Icons.insert_comment,
              size: SizeConfig.safeBlockHorizontal * 5.5,
            ),
          ),
        ),
      ),
    )),
  );
}
