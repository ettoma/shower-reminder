import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shower App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _date = DateTime.now();
  DateTime _newDate;
  Timer timer;
  var _hoursDifference;
  final LocalStorage localStorage = new LocalStorage('ShowerDay');

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('flutter_devs');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);

    flutterLocalNotificationsPlugin.initialize(
      initSetttings,
    );
    localStorage.ready.then((_) => readStorage());
    timer = Timer.periodic(Duration(minutes: 1), (Timer t) => updateHours());
  }

//
  showNotification() async {
    var android = AndroidNotificationDetails('id', 'channel ', 'description',
        priority: Priority.high, importance: Importance.max);
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, 'Shower reminder', 'Basic notification', platform,
        payload: 'Reminder notification');
  }

  Future<void> scheduleNotification() async {
    var scheduledNotificationDateTime = DateTime.now().add(Duration(hours: 64));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel description',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0,
        'Shower reminder',
        'It`s shower day! ',
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        // uiLocalNotificationDateInterpretation: null,
        androidAllowWhileIdle: true);
  }

  // At startup, checks if the local storage has data about the next shower
  void readStorage() async {
    setState(() {
      if (localStorage != null) {
        DateTime _showerDate =
            DateTime.parse(localStorage.getItem('ShowerDay'));
        _hoursDifference = _showerDate.difference(_date).inHours;
        _newDate = _showerDate;
      }
    });
  }

  // Updates the time left every minute when the app is running. Function runs every 1 minute from initState
  void updateHours() {
    setState(() {
      DateTime now = DateTime.now();
      DateTime showerDay = DateTime.parse(localStorage.getItem('ShowerDay'));
      _hoursDifference = showerDay.difference(now).inHours;
    });
  }

  // Add 3 days to the current date stored in the local storage
  void startTimer() {
    scheduleNotification();
    setState(() {
      _date = DateTime.now();
      _newDate = _date.add(new Duration(days: 3));
      _hoursDifference = _newDate.difference(_date).inHours;
    });
    localStorage.setItem('ShowerDay', _newDate.toString());
  }

  String setText() {
    return localStorage.getItem('ShowerDay') == null
        ? 'Time to log your shower'
        : DateFormat('EEEE, d MMM').format(_newDate);
  }

  Image imageSelection() {
    return _hoursDifference != null && _hoursDifference > 14
        ? Image.asset('assets/images/clean.png')
        : Image.asset('assets/images/dirty.jpg');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take a shower'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: Column(
            children: [
              Container(
                child: imageSelection(),
                width: 300,
                height: 300,
              ),
              SizedBox(height: 20),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _hoursDifference == null
                        ? 'No shower logged yet'
                        : 'Your next shower will be in',
                    style: TextStyle(
                      fontSize: 23,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(
                      setText(),
                      style: TextStyle(fontSize: 36),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Text(
                        _hoursDifference == null
                            ? 'Log your first shower'
                            : '$_hoursDifference hours left',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: SizedBox(
                      width: 180,
                      height: 60,
                      child: RaisedButton(
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: startTimer,
                        child: Text('Take shower!',
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
