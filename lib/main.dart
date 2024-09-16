import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(250, 100),
    alwaysOnTop: true,
  );

  windowManager.setTitle("To JPG");

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.center();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    runProcess();
    super.initState();
  }

  String outputError = "";
  String resultCode = "Waiting";

  //* Use these paths during Debug/Development Only
  // String debugMogrifyPath = 'production_packaging_files\\imgk\\.\\mogrify.exe';
  // String debugHEICImageInputPath =
  //     'production_packaging_files\\imgk\\Images\\*.*';
  // String debugJPGImageOutput = 'production_packaging_files\\imgk\\Images\\JPG';

  //* Use these paths for Procuction/Release
  String releaseMogrifyPath = 'C:\\ravi\\ToJPG\\data\\imgk\\.\\mogrify.exe';
  String releaseHEICImageInputPath = '*.*';
  String releaseJPGImageOutput = 'JPG';

  void runProcess() async {
    await Process.run('cmd', [
      '/c',
      //'mkdir $debugJPGImageOutput', //* Uncomment this for Development/Debug
      'mkdir $releaseJPGImageOutput', //* Uncomment this for Procuction/Release
    ]);

    var result = await Process.run('cmd', [
      '/c',
      //* Uncomment below line for Development/Debug
      //'$debugMogrifyPath -path $debugJPGImageOutput -quality 100% -format jpg $debugHEICImageInputPath',

      //* Uncomment below line for Procuction/Release
      '$releaseMogrifyPath -path $releaseJPGImageOutput -quality 100% -format jpg $releaseHEICImageInputPath',
    ]);

    setState(() {
      outputError = result.stderr.toString();
      resultCode = result.exitCode.toString();
      if (resultCode == '1') {
        windowManager.maximize(vertically: false);
      }
    });
  }

  final myColor = Colors.deepPurple;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To JPG',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: myColor,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (resultCode == '0') ...[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Processed",
                      style: TextStyle(fontSize: 30),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.done,
                      size: 30,
                      color: Colors.green,
                    ),
                  ],
                ),
              ] else if (resultCode == '1') ...[
                const Text(
                  "Failed",
                  style: TextStyle(fontSize: 30),
                ),
                Text(outputError),
              ] else ...[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Processing",
                      style: TextStyle(fontSize: 30),
                    ),
                    SizedBox(width: 10),
                    CircularProgressIndicator(),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
