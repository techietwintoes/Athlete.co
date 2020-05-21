import 'dart:ui';

import 'package:attt/interface/chewieVideoInterface.dart';
import 'package:attt/storage/storage.dart';
import 'package:attt/utils/alertDialog.dart';
import 'package:attt/utils/colors.dart';
import 'package:attt/utils/fullTrainingStopwatch/fullTrainingStopwatch.dart';
import 'package:attt/utils/globals.dart';
import 'package:attt/view/chewieVideo/widgets/finishWorkout.dart';
import 'package:attt/view/chewieVideo/widgets/indicatorsOnVideo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_box/video_box.dart';
import 'dart:async';
import 'package:attt/utils/size_config.dart';
import 'package:numberpicker/numberpicker.dart';

class ChewieVideo extends StatefulWidget {
  final DocumentSnapshot userDocument, userTrainerDocument;
  final String workoutID, weekID;
  ChewieVideo({
    this.userDocument,
    this.weekID,
    this.userTrainerDocument,
    this.workoutID,
  });
  @override
  _ChewieVideoState createState() => _ChewieVideoState();
}

class _ChewieVideoState extends State<ChewieVideo>
    with WidgetsBindingObserver, TickerProviderStateMixin
    implements ChewieVideoInterface {
  List<String> source = [
    'assets/video/F.mp4',
    'assets/video/C.mp4',
    'assets/video/F.mp4',
    'assets/video/F.mp4',
    'assets/video/C.mp4',
    'assets/video/F.mp4',
    'assets/video/C.mp4',
    'assets/video/C.mp4',
    'assets/video/C.mp4',
    'assets/video/C.mp4',
    'assets/video/C.mp4',
    'assets/video/C.mp4',
    'assets/video/C.mp4',
    'assets/video/C.mp4',
    'assets/video/C.mp4',
    'assets/video/C.mp4',
    'assets/video/C.mp4',
    'assets/video/C.mp4',
    'assets/video/C.mp4',
    'assets/video/C.mp4',
    'assets/video/C.mp4',
  ];
  AnimationController _controllerTimer;
  Animation<Offset> _offsetAnimationTimer;
  VideoController vc;
  VideoPlayerController controller;
  int exerciseDuration,
      exerciseIsReps,
      exerciseReps,
      exerciseSets,
      exerciseRest;
  String exerciseName, exerciseRepsDescription;
  String exerciseSet;
  int _index = 0;
  int get index => _index;
  set index(int nv) {
   // if (nv > _index) {
      // +
      nv = nv % source.length;
      vc.autoplay = true;
      controller = VideoPlayerController.asset(source[nv]);
      vc.setSource(controller);
      vc.looping = true;
      vc.bufferColor = Colors.black;
      vc.controllerWidgets = true;

      vc.initialize();
   // }
    _index = nv;
  }

  /// minutes for timer and seconds
  int _currentMinutes = 1, _currentSeconds = 1;


  showTmerInputDialog(BuildContext context) {
    Widget minuteChoose() {
      return new NumberPicker.integer(
          initialValue: _currentMinutes,
          minValue: 0,
          maxValue: 60,
          onChanged: (newValue) => _currentMinutes = newValue);
    }

    Widget secChoose() {
      return new NumberPicker.integer(
          initialValue: _currentSeconds,
          minValue: 0,
          maxValue: 59,
          onChanged: (newValue) => _currentSeconds = newValue);
    }

    Widget buttonDone() {
      return FlatButton(
          onPressed: () {
            print('VALUE MINUTES: ' + _currentMinutes.toString());
            print('VALUE seconds: ' + _currentSeconds.toString());
            setState(() {
              secondsForIndicators = _currentSeconds;
              minutesForIndicators = _currentMinutes;
              isTimeChoosed = true;
            });
            Navigator.of(context).pop();
          },
          child: Text('Done'));
    }


    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: MyColors().lightWhite,
      title: Text(
        "Choose your time",
        style: TextStyle(color: MyColors().lightBlack),
      ),
      content: Container(
        alignment: Alignment.center,
        height: SizeConfig.blockSizeVertical * 27,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[Text('Minutes'), Text('Seconds')],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                minuteChoose(),
                secChoose(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                buttonDone(),
              ],
            )
          ],
        ),
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  /// [_onWillPop]
  ///
  /// async funstion that creates an exit dialog for our screen
  /// CONTINUE / CANCEL
  Future<bool> _onWillPop() async {
    if (restGoing || readyGoing)
      print('Back button is disabled because REST || READY is active');
    else {
      vc.pause();
      return showDialog(
        context: context,
        builder: (context) => MyAlertDialog(
          no: 'Cancel',
          yes: 'Continue',
          title: 'Back to Training plan?',
          content: 'If you go back all your progress will be lost',
          userDocument: widget.userDocument,
          userTrainerDocument: widget.userTrainerDocument,
          vc: vc,
          close: dispose,
          isReps: exerciseIsReps,
        ),
      ) ??
          true;
    }
  }


  /// populate variables with exercise info
  initializeVariables() {
    String exerciseNameAndSet = namesWithSet[index];
    exerciseDuration = workoutExercisesWithSets[index].data['duration'];
    exerciseIsReps = workoutExercisesWithSets[index].data['isReps'];
    exerciseReps = workoutExercisesWithSets[index].data['reps'];
    exerciseSets = workoutExercisesWithSets[index].data['sets'];
    exerciseRest = workoutExercisesWithSets[index].data['rest'];
    exerciseName = exerciseNameAndSet.split('_')[1];
    exerciseSet = exerciseNameAndSet.split('_')[0];
    exerciseRepsDescription =
        workoutExercisesWithSets[index].data['repsDescription'];
  }

  /// when we want to play next video, we simply set index to increment
  nextPlay() {
    if(index == source.length -1 ) {
       finishWorkout();
    }  else {
      setState(() {
        index++;
        isPrevious = true;
      });
    }
  }

  finishWorkout() {
    onlineExercises = [];
    onlineWarmup = [];
    onlineVideos = [];
    exerciseSnapshots = [];
    alertQuit = true;
    FullTrainingStopwatch().stopStopwtach();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        maintainState: false,
        builder: (_) => FinishWorkout(
          weekID: widget.weekID,
          close: dispose,
          workoutID: widget.workoutID,
          userDocument: widget.userDocument,
          userTrainerDocument: widget.userTrainerDocument,
        ),
      ),
    );
  }

  /// when we want to play previous video, we simply set index to decrement
  previousPlay() {
    setState(() {
      index = index - 1;
    });
  }

  @override
  void initState() {
    super.initState();
    // source = onlineVideos;
    WidgetsBinding.instance.addObserver(this);
    _controllerTimer = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _offsetAnimationTimer = Tween<Offset>(
      begin: const Offset(0.8, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controllerTimer,
      curve: Curves.easeInOut,
    ));

    /// initializing VideoController and giving him source (videos)
    vc = VideoController(
        controllerWidgets: true,
        looping: true,
        autoplay: true,
        source: VideoPlayerController.asset(source[index]))
      ..initialize();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);

    if (_index == 0 && !isPrevious) {
      Timer(Duration(seconds: 1), () {
        vc.pause();
      });
    }
  }


    /// dispose whole widget and [vc] controller
    @override
    void dispose() {
      super.dispose();
      vc.dispose();
      WidgetsBinding.instance.removeObserver(this);
      print('CHEWIE VIDEO DISPOSED');
    }

    @override
    Widget build(BuildContext context) {
      SizeConfig().init(context);
      initializeVariables();
      if (alertQuit) {
        print('NO READY, QUIT');
        dispose();
      }

      return Scaffold(
        body: WillPopScope(
          onWillPop: () => _onWillPop(),
          child: Stack(
            children: <Widget>[
              Center(
                /// video / beforeChildren / controllerWidgets-> children / afterChildren
                child: VideoBox(
                  controller: vc,
                ),
              ),
              Positioned(
                child: Container(
                  height:
                  MediaQuery
                      .of(context)
                      .orientation == Orientation.portrait
                      ? SizeConfig.blockSizeVertical * 98
                      : SizeConfig.blockSizeVertical * 95,
                  child: IndicatorsOnVideo(
                    controller: vc,
                    listLenght: source.length,
                    userDocument: widget.userDocument,
                    userTrainerDocument: widget.userTrainerDocument,
                    index: _index,
                    isReps: exerciseIsReps,
                    reps: exerciseReps,
                    sets: exerciseSets,
                    name: exerciseName,
                    workoutID: widget.workoutID,
                    weekID: widget.weekID,
                    ctrl: true,
                    currentSet: exerciseSet,
                    playNext: nextPlay,
                    playPrevious: previousPlay,
                    repsDescription: exerciseRepsDescription,
                    onWill: _onWillPop,
                    showTimerDialog: showTmerInputDialog,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

  @override
  showRest(BuildContext context, String toPlay) {
//    // TODO: implement showRest
//    throw UnimplementedError();
  }
  }

