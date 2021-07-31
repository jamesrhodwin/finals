import 'dart:typed_data';
import 'bookmarked.dart' as bookmarked;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ibm_watson/flutter_ibm_watson.dart';

import 'main.dart';

class Bookmark extends StatefulWidget {
  const Bookmark({Key key}) : super(key: key);

  @override
  _BookmarkState createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> {
  showSnackBar(String text, Color color) {
    final snackBar = SnackBar(
      backgroundColor: color,
      content: Text(text),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.black,
        onPressed: () {},
      ),
    );
    return snackBar;
  }

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
    if (bookmarked.bookmarks == null || bookmarked.bookmarks.length == 0) {
      return Scaffold(
          appBar: AppBar(
            title: Text("Bookmarks"),
          ),
          body: Center(child: Text("No bookmarked.bookmarks word yet")));
    } else
      return Scaffold(
        appBar: AppBar(
          title: Text("Bookmarks"),
        ),
        body: ListView.builder(
          itemCount: bookmarked.bookmarks.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: ListBody(
                children: [
                  Container(
                    color: Colors.grey[300],
                    child: ListTile(
                      trailing: GestureDetector(
                          onTap: () {
                            Word data = Word();
                            data.imageUrl =
                                bookmarked.bookmarks[index].imageUrl;
                            data.name = bookmarked.bookmarks[index].name;
                            data.type = bookmarked.bookmarks[index].type;
                            data.definition =
                                bookmarked.bookmarks[index].definition;
                            String name = data.name;
                            setState(() {
                              bookmarked.bookmarks.removeWhere(
                                  (item) => item.definition == data.definition);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                                showSnackBar(
                                    "Bookmark for \"$name\" has been removed!",
                                    Colors.blue));
                          },
                          child: Icon(
                            Icons.bookmark_remove,
                            color: Colors.red,
                          )),
                      leading: bookmarked.bookmarks[index].imageUrl == null
                          ? null
                          : CircleAvatar(
                              backgroundImage: NetworkImage(
                                  bookmarked.bookmarks[index].imageUrl),
                            ),
                      title: Row(
                        children: [
                          Text(bookmarked.bookmarks[index].name +
                              "(" +
                              bookmarked.bookmarks[index].type +
                              ")"),
                          GestureDetector(
                              onTap: () {
                                textToSpeech(bookmarked.bookmarks[index].name);
                              },
                              child: Icon(Icons.multitrack_audio)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(bookmarked.bookmarks[index].definition),
                  )
                ],
              ),
            );
          },
        ),
      );
  }
}
