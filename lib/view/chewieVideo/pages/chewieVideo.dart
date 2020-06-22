import 'dart:ui';
import 'package:attt/interface/chewieVideoInterface.dart';
import 'package:attt/utils/alertDialog.dart';
import 'package:attt/utils/colors.dart';
import 'package:attt/utils/emptyContainer.dart';
import 'package:attt/utils/fullTrainingStopwatch/fullTrainingStopwatch.dart';
import 'package:attt/utils/globals.dart';
import 'package:attt/view/chewieVideo/widgets/finishButton.dart';
import 'package:attt/view/chewieVideo/widgets/finishWorkout.dart';
import 'package:attt/view/chewieVideo/widgets/indicatorsOnVideo.dart';
import 'package:attt/view/chewieVideo/widgets/seriesInfoScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_box/video_box.dart';
import 'dart:async';
import 'package:attt/utils/size_config.dart';
import 'package:flutter_picker/flutter_picker.dart';

class ChewieVideo extends StatefulWidget {
  final DocumentSnapshot userDocument, userTrainerDocument;
  final String workoutID, weekID;
  final bool finishedWorkout;
  ChewieVideo({
    this.userDocument,
    this.weekID,
    this.userTrainerDocument,
    this.workoutID,
    this.finishedWorkout,
  });
  @override
  _ChewieVideoState createState() => _ChewieVideoState();
}

class _ChewieVideoState extends State<ChewieVideo>
    with WidgetsBindingObserver
    implements ChewieVideoInterface {
  List<dynamic> source = [];
  List<dynamic> covers = [];
  VideoController vc;
  VideoPlayerController controller;
  List<dynamic> exerciseTips = [];
  int exerciseDuration, exerciseIsReps, exerciseSets, exerciseRest;
  var exerciseReps;
  String exerciseName, exerciseRepsDescription;
  String exerciseSet, exerciseTime;
  String seriesID;
  int _index = 0;
  int get index => _index;
  set index(int nv) {
    // if (nv > _index) {
    // +
    nv = nv % source.length;
    vc.autoplay = false;
    controller = VideoPlayerController.network(source[nv]);
    vc.setSource(controller);
    vc.looping = true;
    vc.isFullScreen = false;
    vc.bufferColor = Colors.transparent;
    vc.cover = Container(
      child: AspectRatio(
        aspectRatio: 2.0 / 1.2,
        child: Image.network(
          covers[nv],
          fit: BoxFit.fitHeight,
        ),
      ),
    );
    vc.controllerWidgets = true;

    vc.initialize();
    _index = nv;
  }

  /// minutes for timer and seconds
  List<dynamic> time = [];
  String timeToSplit;
  var ms;

  onConfirm(Picker picker) {
    timeToSplit = picker.getSelectedValues().toString();
    String min = timeToSplit[1] + (timeToSplit[2] == ',' ? '' : timeToSplit[2]);
    setState(() => minutesForIndicators = int.parse(min));
    print('Minutes: ' + minutesForIndicators.toString());
    String sec = minutesForIndicators > 10
        ? timeToSplit[5] + (timeToSplit[6] == ']' ? '' : timeToSplit[6])
        : timeToSplit[4] + (timeToSplit[5] == ']' ? '' : timeToSplit[5]);
    setState(() {
      secondsForIndicators = int.parse(sec);
      isTimeChoosed = true;
      resetFromChewie = false;
      reseted = false;
    });
  }

  showPickerNumber(BuildContext context) {
    new Picker(
            height: MediaQuery.of(context).orientation == Orientation.landscape
                ? SizeConfig.blockSizeVertical * 35
                : SizeConfig.blockSizeVertical * 15,
            textStyle: TextStyle(color: Colors.black),
            adapter: NumberPickerAdapter(data: [
              NumberPickerColumn(
                  onFormatValue: (v) {
                    return v < 10 ? "0$v" : "$v";
                  },
                  begin: 0,
                  end: 59,
                  suffix: Text(
                    'min',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).orientation ==
                                Orientation.landscape
                            ? SizeConfig.safeBlockHorizontal * 1.5
                            : SizeConfig.safeBlockHorizontal * 2.3),
                  )),
              NumberPickerColumn(
                  onFormatValue: (v) {
                    return v < 10 ? "0$v" : "$v";
                  },
                  begin: 1,
                  end: 60,
                  suffix: Text(
                    'sec',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).orientation ==
                                Orientation.landscape
                            ? SizeConfig.safeBlockHorizontal * 1.5
                            : SizeConfig.safeBlockHorizontal * 3),
                  )),
            ]),
            delimiter: [
              PickerDelimiter(
                  child: Container(
                color: MyColors().white,
                width: 30.0,
                alignment: Alignment.center,
                child: Icon(Icons.watch),
              ))
            ],
            cancelText: 'Reset',
            cancelTextStyle: TextStyle(
                color: Colors.red,
                fontSize:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? SizeConfig.safeBlockHorizontal * 3
                        : SizeConfig.safeBlockHorizontal * 4),
            confirmText: 'Done',
            confirmTextStyle: TextStyle(
                color: Colors.green,
                fontSize:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? SizeConfig.safeBlockHorizontal * 3
                        : SizeConfig.safeBlockHorizontal * 4),
            hideHeader: true,
            title: new Text(
              "Choose your time",
              style: TextStyle(
                  color: MyColors().lightBlack,
                  fontSize: MediaQuery.of(context).orientation ==
                          Orientation.landscape
                      ? SizeConfig.safeBlockHorizontal * 3
                      : SizeConfig.safeBlockHorizontal * 5),
            ),
            onSelect: (Picker picker, int index, List<int> selecteds) {
              this.setState(() {
                resetFromChewie = false;
              });
            },
            onConfirm: (Picker picker, List<int> value) {
              onConfirm(picker);
              print('Seconds: ' + secondsForIndicators.toString());
            },
            onCancel: () {
              setState(() => resetFromChewie = true);
            },
            magnification: 1.2)
        .showDialog(context);
  }

  /// [_onWillPop]
  ///
  /// async funstion that creates an exit dialog for our screen
  /// CONTINUE / CANCEL
  Future<bool> _onWillPop() async {
    setState(() {
      activatePause = true;
    });
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

  /// populate variables with exercise info
  initializeVariables() {
    String exerciseNameAndSet = namesWithSet[index];
    String exerciseNameAndSetNext = '';
    if (index != namesWithSet.length - 1) {
      exerciseNameAndSetNext = namesWithSet[index + 1];
      seriesID = exerciseNameAndSetNext.split('_')[1];
    }
    exerciseDuration = workoutExercisesWithSets[index].data['duration'];
    exerciseIsReps = workoutExercisesWithSets[index].data['isReps'];
    exerciseReps = workoutExercisesWithSets[index].data['reps'];
    exerciseSets = workoutExercisesWithSets[index].data['sets'];
    exerciseRest = workoutExercisesWithSets[index].data['rest'];
    exerciseTips = workoutExercisesWithSets[index].data['tips'];
    exerciseName = exerciseNameAndSet.split('_')[2];
    exerciseSet = exerciseNameAndSet.split('_')[0];
    exerciseRepsDescription =
        workoutExercisesWithSets[index].data['repsDescription'];
    exerciseTime = workoutExercisesWithSets[index].data['time'];
  }

  /// when we want to play next video, we simply set index to increment
  nextPlay() {
    if (index == source.length - 1) {
      finishWorkout();
    } else {
      setState(() {
        index++;
        isPrevious = true;
      });
      if (listOfBoundarySets.contains(index) && index != source.length - 1) {
        overlayState = Overlay.of(context);
        overlayEntry = OverlayEntry(
            builder: (BuildContext context) => Visibility(
                visible: true,
                child: SeriesInfoScreen(
                    trainerID: widget.userTrainerDocument.data['trainerID'],
                    weekID: widget.weekID,
                    sets: workoutExercisesWithSets[index + 1].data['sets'],
                    workoutID: widget.workoutID,
                    seriesID: seriesID)));
        overlayState.insert(overlayEntry);
      } else if (index == source.length - 1) {
        overlayState = Overlay.of(context);
        overlayEntry = OverlayEntry(
            builder: (BuildContext context) => Visibility(
                visible: true,
                child: SeriesInfoScreen(
                    trainerID: widget.userTrainerDocument.data['trainerID'],
                    weekID: widget.weekID,
                    sets: workoutExercisesWithSets[index].data['sets'],
                    workoutID: widget.workoutID,
                    seriesID: seriesID)));
        overlayState.insert(overlayEntry);
      }
    }
  }

  finishWorkout() {
    onlineExercises = [];
    onlineWarmup = [];
    onlineVideos = [];
    onlineCovers = [];
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
          finishedWorkout: widget.finishedWorkout,
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
    source = onlineVideos;
    covers = onlineCovers;
    WidgetsBinding.instance.addObserver(this);

    /// initializing VideoController and giving him source (videos)
    vc = VideoController(
        circularProgressIndicatorColor: Colors.transparent,
        controllerWidgets: true,
        looping: true,
        autoplay: false,
        cover: Container(
          child: AspectRatio(
            aspectRatio: 2.0 / 1.2,
            child: Image.network(
              covers[index],
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
        source: VideoPlayerController.network(source[index]))
      ..initialize();
    vc.isFullScreen = false;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    WidgetsBinding.instance
        .addPostFrameCallback((callback) => insertOverlayOnWarmup());
  }

  insertOverlayOnWarmup() async {
    if (index == 0) {
      String exerciseNameAndSetNext = '';
      exerciseNameAndSetNext = namesWithSet[0];
      seriesID = exerciseNameAndSetNext.split('_')[1];
      overlayState = Overlay.of(context);
      overlayEntry = OverlayEntry(
          builder: (BuildContext context) => Visibility(
              visible: true,
              child: SeriesInfoScreen(
                  trainerID: widget.userTrainerDocument.data['trainerID'],
                  weekID: widget.weekID,
                  sets: workoutExercisesWithSets[index + 1].data['sets'],
                  workoutID: widget.workoutID,
                  seriesID: seriesID)));
      overlayState.insert(overlayEntry);
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
    return Scaffold(
      backgroundColor: MyColors().lightBlack,
      bottomNavigationBar: index == source.length - 1
          ? finishButton(nextPlay, context, index, source.length)
          : EmptyContainer(),
      body: WillPopScope(
        onWillPop: () => _onWillPop(),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                VideoBox(
                  controller: vc,
                ),
              ],
            ),
            Positioned(
              child: Container(
                height:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? index == source.length - 1
                            ? SizeConfig.blockSizeVertical * 92
                            : SizeConfig.blockSizeVertical * 95
                        : SizeConfig.blockSizeVertical * 92,
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
                  showTimerDialog: showPickerNumber,
                  tips: exerciseTips,
                  video: source[index],
                  exerciseTime: exerciseTime,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
