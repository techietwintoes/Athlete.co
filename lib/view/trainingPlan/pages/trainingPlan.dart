import 'package:attt/utils/size_config.dart';
import 'package:attt/view/trainingPlan/widgets/showAlertDialog.dart';
import 'package:attt/view/workout/pages/workout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrainingPlan extends StatelessWidget {
  final DocumentSnapshot userDocument;
  final DocumentSnapshot userTrainerDocument;
  final String trainerName;
  final String trainingPlanName;
  final String trainingPlanDuration;
  final String name, photo, email;
  TrainingPlan(
      {this.trainerName,
      this.userTrainerDocument,
      this.userDocument,
      this.trainingPlanDuration,
      this.trainingPlanName,
      this.photo,
      this.name,
      this.email});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(28, 28, 28, 1.0),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(28, 28, 28, 1.0),
        title: Text('Hi ' + name, style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: 90.0,
              width: 90,
              padding: EdgeInsets.all(10),
              child: CircleAvatar(
                radius: 28.0,
                backgroundImage: NetworkImage(photo),
              ),
            ),
            Container(
              child: Text(
                "Your training plan is: " +
                    userTrainerDocument.data['training_plan_name'].toString(),
                style: TextStyle(color: Colors.white),
              ),
            ),
            Container(
              child: Text(
                  "Duration is: " +
                      userTrainerDocument.data['training_plan_duration'],
                  style: TextStyle(color: Colors.white)),
            ),
            Container(
              child: Text(
                  "The man who will train you is: " +
                      userTrainerDocument.data['trainer_name'].toString(),
                  style: TextStyle(color: Colors.white)),
            ),
            Container(
              child: RaisedButton(
                child: Text('Sign out'),
                onPressed: () {
                  showAlertDialog(context);
                },
              ),
            ),
            Container(
              child: RaisedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => Workout(
                          trainerName: userTrainerDocument.data['trainer_name'],
                        ))),
                child: Text('Workouts'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
