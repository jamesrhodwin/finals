import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ibm_watson/flutter_ibm_watson.dart';
import 'package:permission_handler/permission_handler.dart';

class TtSpeech extends StatefulWidget {
  @override
  _TtSpeechState createState() => _TtSpeechState();
}

class _TtSpeechState extends State<TtSpeech> {
  AudioPlayer audioPlayer = new AudioPlayer();
  List<String> voices = [];
  List<String> languages = [];
  List<Voice> listVoice;
  String selectedLanguage = "en-US";
  String selectedVoice = "en-US_MichaelVoice";
  String textAsSpeech = "";
  Uint8List voice;
  String apiKey = "A0qDY3MIoVLzzbcTIQFzMM2feWgFGLdY1Y2Qj7_Hcd8x";
  String ibmURL =
      "https://api.us-south.text-to-speech.watson.cloud.ibm.com/instances/c395a80a-bea6-4624-863f-32df4cdefcfe";
  TextToSpeech service;
  @override
  void initState() {
    super.initState();
    getListVoice();
    print("YAAAAAAAAAAAAAAAAAAAAAA");
  }

  void downloadAudio() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
    } else {
      File recordedFile = File("/storage/emulated/0/recordedFile.wav");

      var channels = 1;

      int byteRate = ((16 * 44100 * channels) / 8).round();

      var fileSize = 36;

      Uint8List header = Uint8List.fromList([
        // "RIFF"
        82, 73, 70, 70,
        fileSize & 0xff,
        (fileSize >> 8) & 0xff,
        (fileSize >> 16) & 0xff,
        (fileSize >> 24) & 0xff,
        // WAVE
        87, 65, 86, 69,
        // fmt
        102, 109, 116, 32,
        // fmt chunk size 16
        16, 0, 0, 0,
        // Type of format
        1, 0,
        // One channel
        channels, 0,
        // Sample rate
        44100 & 0xff,
        (44100 >> 8) & 0xff,
        (44100 >> 16) & 0xff,
        (44100 >> 24) & 0xff,
        // Byte rate
        byteRate & 0xff,
        (byteRate >> 8) & 0xff,
        (byteRate >> 16) & 0xff,
        (byteRate >> 24) & 0xff,
        // Uhm
        ((16 * channels) / 8).round(), 0,
        // bitsize
        16, 0,
      ]);
      return recordedFile.writeAsBytesSync(header, flush: true);
    }
  }

  void changeLanguage() {
    setState(() {
      listVoice.forEach((res) {
        if (res.language == selectedLanguage) {
          voices.add(res.name.toString());
          selectedVoice = res.name;
        }
      });
    });
  }

  void getListVoice() async {
    IamOptions options =
        await IamOptions(iamApiKey: apiKey, url: ibmURL).build();
    service = new TextToSpeech(iamOptions: options);
    listVoice = await service.getListVoices();
    setState(() {
      listVoice.forEach((res) {
        if (!languages.contains(res.language.toString())) {
          languages.add(res.language.toString());
        }
      });
      // for (int i = 0; i < listVoice.length; i++) {
      //   voices.add(listVoice[i].name.toString());
      // }
      listVoice.forEach((res) {
        if (res.language == selectedLanguage) {
          voices.add(res.name.toString());
        }
      });
    });
  }

  void textToSpeech(String text) async {
    service.setVoice(selectedVoice);
    voice = await service.toSpeech(text);
    audioPlayer.playBytes(voice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text to Speech'),
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
                child: Text("convert")),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                  width: 500,
                  child: ListTile(
                    leading: Text("Language"),
                    title: DropdownButton<String>(
                      value: selectedLanguage,
                      items: languages.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                      onChanged: (_) {
                        setState(() {
                          selectedLanguage = _;
                          voices.clear();
                          changeLanguage();
                        });
                      },
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                  width: 500,
                  child: ListTile(
                    leading: Text("Voice"),
                    title: DropdownButton<String>(
                      value: selectedVoice,
                      items: voices.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                      onChanged: (_) {
                        setState(() {
                          selectedVoice = _;
                        });
                      },
                    ),
                  )),
            ),
            ElevatedButton(
                onPressed: downloadAudio, child: Icon(Icons.download))
          ],
        ),
      ),
    );
  }
}
