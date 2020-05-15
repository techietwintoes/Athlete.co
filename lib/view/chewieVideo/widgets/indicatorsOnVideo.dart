import 'dart:async';
import 'package:attt/utils/customScreenAnimation.dart';
import 'package:attt/utils/emptyContainer.dart';
import 'package:attt/utils/globals.dart';
import 'package:attt/view/chewieVideo/widgets/addNote.dart';
import 'package:attt/view/workout/widgets/info.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_box/video.controller.dart';
import 'package:attt/utils/size_config.dart';

class IndicatorsOnVideo extends StatefulWidget {
  final VideoController controller;
  final DocumentSnapshot userDocument, userTrainerDocument;
  final int index, listLenght;
  final int duration;
  final Function showRest, showAddNote, playNext;
  final int isReps, sets, reps, rest;
  final String name, workoutID, weekID, currentSet, repsDescription;
  final bool ctrl;

  IndicatorsOnVideo({
    this.controller,
    this.currentSet,
    this.repsDescription,
    this.showAddNote,
    this.workoutID,
    this.playNext,
    this.listLenght,
    this.rest,
    this.weekID,
    this.name,
    this.sets,
    this.reps,
    this.isReps,
    this.showRest,
    this.index,
    this.userTrainerDocument,
    this.userDocument,
    this.ctrl,
    this.duration,
  });

  @override
  _IndicatorsOnVideoState createState() => _IndicatorsOnVideoState();
}

class _IndicatorsOnVideoState extends State<IndicatorsOnVideo>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;
  AudioCache audioCache;
  AudioPlayer audioPlayer;
  bool isOrientation = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.8, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _start = widget.duration;
    _isLessThan10 = false;

    if (widget.index == 0) {
      if (widget.isReps == 1 && !timerPaused) {
        Timer(Duration(seconds: 6), () {
          startTimer(_start);
          widget.controller.play();
        });
      } else if (widget.isReps == 0) {
        Timer(Duration(seconds: 6), () {
          widget.controller.play();
        });
      }
    } else {
      if (widget.isReps == 1 && !timerPaused) {
        startTimer(_start);
        widget.controller.play();
      } else if (widget.isReps == 0) {
        widget.controller.play();
      }
    }

    audioCache = AudioCache(
        prefix: "audio/",
        fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP));
  }

  @override
  void didUpdateWidget(IndicatorsOnVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isLessThan10 = false;
    if (widget.index == 0) {
      if (pausedOn == null) {
        if(!isOrientation) {
              _start = widget.duration;
        } else {
          _start = pausedOn;
        }
        
      } else {
        _start = pausedOn;
      }
    }
    if (widget.ctrl == true) {
      if(!isOrientation) {
              _start = widget.duration;
        } else {
          _start = pausedOn;
        }
    }
    if (widget.index > 0) {
      if (widget.isReps == 1 && !timerPaused) {
        startTimer(_start);
        widget.controller.play();
      } else if (widget.isReps == 0 && !restShowed) {
        widget.controller.play();
      }
    }
  }

  @override
  void dispose() {
    videoTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  int _start;
  int pausedOn;
  bool timerPaused = false;
  bool _isLessThan10 = false;

  initializeAudioPlayer() async {
    audioPlayer = await audioCache.play('zvuk.mp3');
  }

  void startTimer(int startingValue) async {
    const oneSec = const Duration(seconds: 1);
    videoTimer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (startingValue < 1) {
            if (widget.rest > 0) {
              if (widget.index == widget.listLenght - 1) isTimerDone = true;
              widget.showRest(context);
            } else {
              if (widget.index == widget.listLenght - 1) isTimerDone = true;
              widget.showRest(context);
            }
            setState(() {
              restShowed = true;
              timerPaused = false;
            });
            timer.cancel();
          } else {
            setState(() {
              startingValue = startingValue - 1;
              _start = startingValue;
            });
            if (_start < 10) {
              setState(() {
                _isLessThan10 = true;
              });
              if (startingValue == 5 && widget.isReps == 1) {
                initializeAudioPlayer();
              }
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SlideTransition(
        position: _offsetAnimation,
        child: InkWell(
            onTap: () {
              if (!timerPaused) {
                pausedOn = _start;
                widget.controller.pause();
                if (widget.isReps == 1) {
                  videoTimer.cancel();
                }
                if (_start <= 5) {
                  audioPlayer.pause();
                }
                setState(() {
                  timerPaused = true;
                });
              } else {
                widget.controller.play();
                if (widget.isReps == 1) {
                  startTimer(pausedOn);
                }
                setState(() {
                  timerPaused = false;
                });
                if (pausedOn <= 5) {
                  audioPlayer.resume();
                }
              }
              isTips = false;
            },
            child:

                /// LANDSCAPE MOdE
                Padding(
              padding: EdgeInsets.only(
                  top: SizeConfig.blockSizeVertical * 3,
                  left: SizeConfig.blockSizeHorizontal * 3,
                  right: SizeConfig.blockSizeVertical * 3),
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? SizeConfig.blockSizeVertical * 0
                        : SizeConfig.blockSizeVertical * 50),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MediaQuery.of(context).orientation ==
                                Orientation.landscape
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          /// number of reps
                          GestureDetector(
                            onTap: () {
                              if (infoClicked) {
                                Timer(Duration(seconds: 0), () {
                                  if (widget.isReps == 1) {
                                    pausedOn = _start;
                                    videoTimer.cancel();
                                  }
                                  setState(() {
                                    timerPaused = true;
                                    goBackToChewie = true;
                                    infoClicked = false;
                                  });
                                  widget.controller.pause();
                                  _start = pausedOn;
                                  if (MediaQuery.of(context).orientation ==
                                      Orientation.portrait)
                                    isFromPortrait = true;
                                  else
                                    isFromPortrait = false;
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => InfoExercise(
                                      vc: widget.controller,
                                      exerciseNameForInfo: widget.name,
                                      exerciseTips: exTips,
                                      exerciseVideoForInfo: exVideo,
                                    ),
                                  ));
                                });
                              } else {
                                print('NE MOZE VIŠE PAŠA');
                              }
                            },
                            child: Container(
                              width: SizeConfig.blockSizeHorizontal * 75,
                              margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).orientation ==
                                          Orientation.landscape
                                      ? SizeConfig.blockSizeVertical * 5
                                      : SizeConfig.blockSizeVertical * 10),
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: widget.name + ' ',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: MediaQuery.of(context)
                                                    .orientation ==
                                                Orientation.landscape
                                            ? SizeConfig.safeBlockHorizontal * 3
                                            : SizeConfig.safeBlockHorizontal *
                                                6,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  WidgetSpan(
                                      alignment: PlaceholderAlignment.bottom,
                                      child: Icon(
                                        Icons.info,
                                        size: MediaQuery.of(context)
                                                    .orientation ==
                                                Orientation.landscape
                                            ? SizeConfig.blockSizeHorizontal *
                                                2
                                            : SizeConfig.blockSizeHorizontal *
                                                3,
                                        color: Colors.white,
                                      ))
                                ]),
                              ),
                            ),
                          ),

                          /// icon note
                          Container(
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).orientation ==
                                        Orientation.landscape
                                    ? SizeConfig.blockSizeVertical * 6
                                    : SizeConfig.blockSizeVertical * 10),
                            child: IconButton(
                                color: Colors.white,
                                iconSize: MediaQuery.of(context).orientation ==
                                        Orientation.landscape
                                    ? SizeConfig.blockSizeHorizontal * 4.5
                                    : SizeConfig.blockSizeHorizontal * 7.5,
                                icon: Icon(Icons.comment),
                                onPressed: () {
                                  if (noteClicked) {
                                    Timer(Duration(seconds: 0), () {
                                      if (widget.isReps == 1) {
                                        pausedOn = _start;
                                        videoTimer.cancel();
                                      }
                                      setState(() {
                                        timerPaused = true;
                                        noteClicked = false;
                                      });
                                      widget.controller.pause();
                                      _start = pausedOn;
                                      if (MediaQuery.of(context).orientation ==
                                          Orientation.portrait)
                                        isFromPortrait = true;
                                      else
                                        isFromPortrait = false;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          maintainState: true,
                                          builder: (_) => AddNote(
                                              controller: widget.controller,
                                              listLenght: widget.listLenght,
                                              userDocument: widget.userDocument,
                                              userTrainerDocument:
                                                  widget.userTrainerDocument,
                                              index: widget.index,
                                              duration: widget.duration,
                                              isReps: widget.isReps,
                                              reps: widget.reps,
                                              sets: widget.sets,
                                              name: widget.name,
                                              showRest: widget.showRest,
                                              workoutID: widget.workoutID,
                                              weekID: widget.weekID),
                                        ),
                                      );
                                    });
                                  } else {
                                    print('NE MOZE VIŠE PAŠA 2');
                                  }
                                }),
                          )
                        ],
                      ),
                      MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                timerPaused || isTips
                                    ? Container(
                                        height:
                                            SizeConfig.blockSizeVertical * 20,
                                        width:
                                            SizeConfig.blockSizeHorizontal * 24,
                                        // decoration: BoxDecoration(
                                        //     color: Color.fromRGBO(28, 28, 28, 0.7),
                                        //     borderRadius:
                                        //         BorderRadius.all(Radius.circular(4.0))),
                                        // padding: EdgeInsets.all(20.0),
                                        //   child: Text(
                                        //     'PAUSED',
                                        //     style: TextStyle(
                                        //         color: Colors.white,
                                        //         fontSize: SizeConfig.blockSizeVertical * 9,
                                        //         fontWeight: FontWeight.bold,
                                        //         fontStyle: FontStyle.italic),
                                        //     textAlign: TextAlign.center,
                                        //   ),
                                      )
                                    : Container(
                                        height:
                                            SizeConfig.blockSizeVertical * 20,
                                        width:
                                            SizeConfig.blockSizeHorizontal * 24,
                                      )
                              ],
                            )
                          : EmptyContainer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              widget.isReps == 0
                                  ? Container(
                                      margin: EdgeInsets.only(
                                          top: MediaQuery.of(context).orientation ==
                                                  Orientation.landscape
                                              ? SizeConfig.blockSizeVertical *
                                                  12
                                              : widget.isReps == 0  ? SizeConfig.blockSizeVertical * 3 : SizeConfig.blockSizeVertical *
                                                  2,
                                          right: MediaQuery.of(context)
                                                      .orientation ==
                                                  Orientation.landscape
                                              ? SizeConfig.blockSizeHorizontal *
                                                  4
                                              : SizeConfig.blockSizeHorizontal *
                                                  0,
                                          left: MediaQuery.of(context)
                                                      .orientation ==
                                                  Orientation.landscape
                                              ? SizeConfig.blockSizeHorizontal *
                                                  0
                                              : SizeConfig.blockSizeHorizontal *
                                                  33),
                                      child: Text('x' + widget.reps.toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.landscape
                                                  ? SizeConfig
                                                          .blockSizeVertical *
                                                      10
                                                  : SizeConfig
                                                          .blockSizeVertical *
                                                      5,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic)),
                                    )
                                  : Container(
                                      margin: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                      .orientation ==
                                                  Orientation.landscape
                                              ? SizeConfig.blockSizeVertical * 11 : SizeConfig.blockSizeVertical * 3,
                                          left: MediaQuery.of(context)
                                                      .orientation ==
                                                  Orientation.landscape
                                              ? SizeConfig.blockSizeHorizontal *
                                                  0
                                              : SizeConfig.blockSizeHorizontal *
                                                  30),
                                      child: Text(
                                          _isLessThan10
                                              ? timerPaused
                                                  ? '00:0' + pausedOn.toString()
                                                  : '00:0' + _start.toString()
                                              : timerPaused
                                                  ? '00:' + pausedOn.toString()
                                                  : '00:' + _start.toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.landscape
                                                  ? SizeConfig
                                                          .blockSizeVertical *
                                                      10
                                                  : SizeConfig
                                                          .blockSizeVertical *
                                                      5,
                                              fontWeight: FontWeight.w800,
                                              fontStyle: FontStyle.italic)),
                                    ),
                              Container(
                                padding: MediaQuery.of(context).orientation ==
                                        Orientation.landscape
                                    ? EdgeInsets.all(0)
                                    : EdgeInsets.all(8.0),
                                margin: EdgeInsets.only(
                                    top: MediaQuery.of(context).orientation ==
                                            Orientation.landscape
                                        ? SizeConfig.blockSizeVertical * 1
                                        : SizeConfig.blockSizeVertical * 2,
                                    right: MediaQuery.of(context).orientation ==
                                            Orientation.landscape
                                        ? SizeConfig.blockSizeHorizontal * 4
                                        : SizeConfig.blockSizeHorizontal * 0,
                                    left: MediaQuery.of(context).orientation ==
                                            Orientation.landscape
                                        ? SizeConfig.blockSizeHorizontal * 0
                                        : SizeConfig.blockSizeHorizontal * 30),
                                child: Text(
                                  widget.currentSet +
                                      '/' +
                                      widget.sets.toString() +
                                      ' Sets',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).orientation ==
                                                  Orientation.landscape
                                              ? 25.0
                                              : SizeConfig.safeBlockHorizontal *
                                                  6.0,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              /// done icon
                              widget.isReps == 0
                                  ? Container(
                                      height: MediaQuery.of(context)
                                                  .orientation ==
                                              Orientation.landscape
                                          ? SizeConfig.blockSizeHorizontal * 10
                                          : SizeConfig.blockSizeHorizontal * 10,
                                      margin: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                      .orientation ==
                                                  Orientation.landscape
                                              ? SizeConfig.blockSizeVertical *
                                                  14
                                              : SizeConfig.blockSizeVertical *
                                                  5,
                                          left: MediaQuery.of(context)
                                                      .orientation ==
                                                  Orientation.landscape
                                              ? 0
                                              : SizeConfig.blockSizeHorizontal *
                                                  5),
                                      child: IconButton(
                                        icon: Icon(CupertinoIcons
                                            .check_mark_circled_solid),
                                        onPressed: () {
                                          if (widget.rest > 0) {
                                            if (widget.index ==
                                                widget.listLenght - 1)
                                              isTimerDone = true;
                                            widget.showRest(context);
                                          } else {
                                            if (widget.index ==
                                                widget.listLenght - 1)
                                              isTimerDone = true;
                                            widget.showRest(context);
                                          }
                                          setState(() {
                                            restShowed = true;
                                            timerPaused = false;
                                          });
                                        },
                                        color: Colors.white,
                                        iconSize: MediaQuery.of(context)
                                                    .orientation ==
                                                Orientation.landscape
                                            ? SizeConfig.blockSizeHorizontal * 9
                                            : SizeConfig.blockSizeHorizontal *
                                                12,
                                      ),
                                    )
                                  : Container(
                                      width: 0,
                                      height: MediaQuery.of(context)
                                                  .orientation ==
                                              Orientation.landscape
                                          ? SizeConfig.blockSizeVertical * 38
                                          : SizeConfig.blockSizeVertical * 20,
                                    ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: MediaQuery.of(context).orientation ==
                                            Orientation.landscape
                                        ? widget.isReps == 0
                                            ? SizeConfig.blockSizeVertical * 6.7
                                            : SizeConfig.blockSizeVertical * 1.3
                                        : widget.isReps == 0
                                            ? SizeConfig.blockSizeVertical * 7.8
                                            : SizeConfig.blockSizeVertical * 0,
                                    left: MediaQuery.of(context).orientation ==
                                            Orientation.landscape
                                        ? SizeConfig.blockSizeHorizontal * 4
                                        : widget.isReps == 0
                                            ? SizeConfig.blockSizeHorizontal *
                                                19
                                            : SizeConfig.blockSizeHorizontal *
                                                18),
                                child: IconButton(
                                    icon: Icon(Icons.fullscreen),
                                    color: Colors.white,
                                    onPressed: () {
                                      if (!timerPaused) {
                                        pausedOn = _start;
                                        widget.controller.pause();
                                        if (widget.isReps == 1) {
                                          videoTimer.cancel();
                                        }
                                        if (_start <= 5) {
                                          audioPlayer.pause();
                                        }
                                        setState(() {
                                          timerPaused = true;
                                        });
                                      } else {
                                        widget.controller.play();
                                        if (widget.isReps == 1) {
                                          startTimer(pausedOn);
                                        }
                                        setState(() {
                                          timerPaused = false;
                                        });
                                        if (pausedOn <= 5) {
                                          audioPlayer.resume();
                                        }
                                      }
                                      isOrientation = true;
                                      Future.delayed(Duration(seconds: 1));
                                      MediaQuery.of(context).orientation ==
                                              Orientation.landscape
                                          ? SystemChrome
                                              .setPreferredOrientations([
                                              DeviceOrientation.portraitUp
                                            ])
                                          : SystemChrome
                                              .setPreferredOrientations([
                                              DeviceOrientation.landscapeRight
                                            ]);
                                    }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
            ));
  }
}
