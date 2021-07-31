import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ibm_watson/flutter_ibm_watson.dart';

class TtSpeech extends StatefulWidget {
  @override
  _TtSpeechState createState() => _TtSpeechState();
}

class _TtSpeechState extends State<TtSpeech> {
  AudioPlayer audioPlayer = new AudioPlayer();
  List<String> voices = [];
  List<String> languages = [];
  List<Voice> listVoice;
  IamOptions options;
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
    options = await IamOptions(iamApiKey: apiKey, url: ibmURL).build();
    service = new TextToSpeech(iamOptions: options);
    listVoice = await service.getListVoices();
    setState(() {
      listVoice.forEach((res) {
        if (!languages.contains(res.language.toString())) {
          languages.add(res.language.toString());
        }
      });
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
    if (options == null || service == null || listVoice == null)
      return Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Loading'),
            SizedBox(height: 50),
            CircularProgressIndicator(),
          ],
        )),
      );
    else
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
            ],
          ),
        ),
      );
  }
}
