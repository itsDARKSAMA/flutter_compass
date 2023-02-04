import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          _hasPermission = (status == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Compass',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
        backgroundColor: Colors.blueGrey,
        body: Center(
          child: Builder(builder: (context) {
            if (_hasPermission) {
              return _buildCompass();
            } else {
              return _permissionSheet();
            }
          }),
        ),
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Text("Error while reading heading: ${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data!.heading;
        // if device doesn't support >> show this message
        if (direction == null) {
          return const Center(child: Text("Device does not have sensors !"));
        }

        return Center(
          child: Container(
            padding: const EdgeInsets.all(35),
            child: Transform.rotate(
              angle: direction * (math.pi / 180) * -1,
              child: Image.asset(
                "assets/images/compass.png",
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _permissionSheet() {
    return ElevatedButton(
        onPressed: () {
          Permission.locationWhenInUse
              .request()
              .then((value) => _fetchPermissionStatus());
        },
        child: const Text('Get Permission'));
  }
}
