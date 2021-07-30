import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ibm_watson/flutter_ibm_watson.dart';

import 'main.dart';

class Bookmark extends StatelessWidget {
  final List<Word> bookmarked;
  Bookmark({Key key, this.bookmarked}) : super(key: key);

  void textToSpeech(String text) async {
    AudioPlayer audioPlayer = new AudioPlayer();
    String apiKey = "A0qDY3MIoVLzzbcTIQFzMM2feWgFGLdY1Y2Qj7_Hcd8x";
    String ibmURL =
        "https://api.us-south.text-to-speech.watson.cloud.ibm.com/instances/c395a80a-bea6-4624-863f-32df4cdefcfe";

    IamOptions options =
        await IamOptions(iamApiKey: apiKey, url: ibmURL).build();
    TextToSpeech service = new TextToSpeech(iamOptions: options);
    Uint8List voice = await service.toSpeech(text);
    audioPlayer.playBytes(voice);
  }

  @override
  Widget build(BuildContext context) {
    if (bookmarked == null) {
      return Scaffold(
          appBar: AppBar(
            title: Text("Bookmarks"),
          ),
          body: Center(child: Text("No bookmarked chuchu yet")));
    } else
      return Scaffold(
        appBar: AppBar(
          title: Text("Bookmarks"),
        ),
        body: ListView.builder(
          itemCount: bookmarked.length,
          itemBuilder: (BuildContext context, int index) {
            return ListBody(
              children: [
                Container(
                  color: Colors.grey[300],
                  child: ListTile(
                    trailing: ElevatedButton(
                      child: Icon(Icons.speaker),
                      onPressed: () {
                        textToSpeech(bookmarked[index].definition);
                      },
                    ),
                    leading: bookmarked[index].imageUrl == null
                        ? null
                        : CircleAvatar(
                            backgroundImage:
                                NetworkImage(bookmarked[index].imageUrl),
                          ),
                    title: Text(bookmarked[index].name +
                        "(" +
                        bookmarked[index].type +
                        ")"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(bookmarked[index].definition),
                )
              ],
            );
          },
        ),
      );
  }
}
