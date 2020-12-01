import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

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
  var _hoursDifference;
  final LocalStorage localStorage = new LocalStorage('ShowerDay');

  @override
  void initState() {
    super.initState();
    localStorage.ready.then((_) => readStorage());
  }

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

  void startTimer() {
    setState(() {
      _date = DateTime.now();
      _newDate = _date.add(new Duration(days: 3));
      _hoursDifference = _newDate.difference(_date).inHours;
    });
    localStorage.setItem('ShowerDay', _newDate.toString());
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
              _hoursDifference != null && _hoursDifference > 14
                  ? (Image.asset(
                      'assets/images/clean.png',
                    ))
                  : (Image.asset(
                      'assets/images/dirty.jpg',
                      width: 512,
                      height: 512,
                    )),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Your next shower will be ',
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
                      localStorage.getItem('ShowerDay') == null
                          ? 'Time to log your shower'
                          : DateFormat('EEEE, d MMM').format(_newDate),
                      style: TextStyle(fontSize: 36),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Text(
                        '$_hoursDifference hours left',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: SizedBox(
                  width: 128,
                  height: 48,
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: startTimer,
                    child: Text('Take shower!', style: TextStyle(fontSize: 16)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
