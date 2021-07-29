import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ibm_watson/flutter_ibm_watson.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'IBM text to speech api'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AudioPlayer audioPlayer = new AudioPlayer();
  String textAsSpeech = "";
  String apiKey = "A0qDY3MIoVLzzbcTIQFzMM2feWgFGLdY1Y2Qj7_Hcd8x";
  String ibmURL =
      "https://api.us-south.text-to-speech.watson.cloud.ibm.com/instances/c395a80a-bea6-4624-863f-32df4cdefcfe";

  void textToSpeech(String text) async {
    IamOptions options =
        await IamOptions(iamApiKey: apiKey, url: ibmURL).build();
    TextToSpeech service = new TextToSpeech(iamOptions: options);
    Uint8List voice = await service.toSpeech(text);
    audioPlayer.playBytes(voice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    textAsSpeech = value;
                  });
                },
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  textToSpeech(textAsSpeech);
                },
                child: Text("convert"))
          ],
        ),
      ),
    );
  }
}
