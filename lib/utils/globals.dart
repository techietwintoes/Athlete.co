import 'package:flutter/material.dart';
import 'dart:async';


String userName, userEmail, userPhoto, userUIDPref, userTU, userTP, keyOfExercise;
int currentWeek = 0;
int totalWeeks = 0;
bool isLoggedIn = false, isTwitter = false, isTimerDone = false;
String name = '';
bool isPaused = false;
bool isReady = false;
OverlayEntry overlayEntryPaused;
OverlayState overlayStatePaused;
List<dynamic> allVideos;
List<dynamic> onlineVideos = [];
List<dynamic> onlineWarmup = [];
List<dynamic> onlineExercises = [];
List<dynamic> exerciseSnapshots = [];
bool isEmpty = false;
bool repsDone = false;
bool isEndPlaying = false;
bool restShowed = false; 
/// for disabling android back button when rest and  ready are active
bool restGoing = false, readyGoing = false;
String userNotes = '';

///Couunters for note and info
bool infoClicked = true;
bool noteClicked = true;


Timer videoTimer;

/// for alert back exit on video 
bool alertQuit = false;
/// for info from video 
String  exVideo;
List<dynamic> exTips = [];
/// [isTips] for paused, [goBackToChewie] is for orientation 
bool isTips = false, goBackToChewie = false;
/// for checking are apps instaleld  
bool isInstalled = false;
/// for skip rest feature 
bool isRestSkipped = false;
/// list for sets
List<dynamic> workoutExercisesWithSets = [];
List<dynamic> namesWithSet = [];
/// for full training stopwatch
String displayTime = '00:00:00';
var swatch = Stopwatch();