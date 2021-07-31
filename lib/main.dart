import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ibm_watson/flutter_ibm_watson.dart';
import 'package:http/http.dart';
import 'package:tts/texttospeech.dart';
import 'bookmarked.dart' as bookmarked;
import 'bookmark.dart';

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
      debugShowCheckedModeBanner: false,
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
  String url = "https://owlbot.info/api/v4/dictionary/";
  String token = "340940b6f7cc28287e914f91e7dba84c1e7fe8d9";
  StreamController streamController;
  Stream _stream;
  Timer _debounce;
  TextEditingController textEditingController = TextEditingController();
  String definition = "";
  AudioPlayer audioPlayer = new AudioPlayer();
  String textAsSpeech = "";
  String apiKey = "A0qDY3MIoVLzzbcTIQFzMM2feWgFGLdY1Y2Qj7_Hcd8x";
  String ibmURL =
      "https://api.us-south.text-to-speech.watson.cloud.ibm.com/instances/c395a80a-bea6-4624-863f-32df4cdefcfe";

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

  searchText() async {
    if (textEditingController.text == null ||
        textEditingController.text.length == 0 ||
        textEditingController.text.length == 1) {
      streamController.add(null);
      return;
    }
    streamController.add("waiting");
    Response response = await get(url + textEditingController.text.trim(),
        // do provide spacing after Token
        headers: {"Authorization": "Token " + token});
    streamController.add(json.decode(response.body));
  }

  void textToSpeech(String text) async {
    IamOptions options =
        await IamOptions(iamApiKey: apiKey, url: ibmURL).build();
    TextToSpeech service = new TextToSpeech(iamOptions: options);
    service.setVoice("en-US_MichaelVoice");
    Uint8List voice = await service.toSpeech(text);
    audioPlayer.playBytes(voice);
  }

  @override
  void initState() {
    super.initState();
    streamController = StreamController();
    _stream = streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Owlbot Dictionary API'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12, bottom: 11.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      color: Colors.white),
                  child: TextFormField(
                    onChanged: (String text) {
                      if (_debounce?.isActive ?? false) _debounce.cancel();
                      _debounce = Timer(const Duration(milliseconds: 1000), () {
                        searchText();
                      });
                    },
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: "Search for a word",
                      contentPadding: const EdgeInsets.only(left: 24.0),

                      // removing the input border
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  searchText();
                },
              )
            ],
          ),
        ),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Text To Speech'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => TtSpeech()),
                );
              },
            ),
            ListTile(
              title: const Text('Bookmarks'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => Bookmark()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        child: StreamBuilder(
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: Text("Enter a search word"),
              );
            }
            if (snapshot.data == "waiting") {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            try {
              return ListView.builder(
                itemCount: snapshot.data["definitions"].length is int
                    ? snapshot.data["definitions"].length
                    : 0,
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
                                  data.imageUrl = snapshot.data["definitions"]
                                      [index]["image_url"];
                                  data.name = textEditingController.text.trim();
                                  data.type = snapshot.data["definitions"]
                                      [index]["type"];
                                  data.definition = snapshot.data["definitions"]
                                      [index]["definition"];
                                  String name = data.name;
                                  bool found = false;
                                  bookmarked.bookmarks.forEach((element) {
                                    if (element.definition == data.definition)
                                      found = true;
                                  });
                                  if (found) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        showSnackBar(
                                            "\"$name\" already bookmarked",
                                            Colors.orange));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        showSnackBar(
                                            "Bookmarked!", Colors.green));
                                    setState(() {
                                      bookmarked.bookmarks.add(data);
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.bookmark,
                                  color: Colors.green,
                                )),
                            leading: snapshot.data["definitions"][index]
                                        ["image_url"] ==
                                    null
                                ? null
                                : CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        snapshot.data["definitions"][index]
                                            ["image_url"]),
                                  ),
                            title: Row(
                              children: [
                                Text(textEditingController.text.trim() +
                                    "(" +
                                    snapshot.data["definitions"][index]
                                        ["type"] +
                                    ")"),
                                GestureDetector(
                                    onTap: () {
                                      definition =
                                          textEditingController.text.trim();
                                      textToSpeech(definition);
                                    },
                                    child: Icon(Icons.multitrack_audio)),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(snapshot.data["definitions"][index]
                              ["definition"]),
                        ),
                      ],
                    ),
                  );
                },
              );
            } catch (e) {
              print(e);
            }
            return Center(
              child: Text("Word not found"),
            );
          },
          stream: _stream,
        ),
      ),
    );
  }
}

class Word {
  String imageUrl;
  String name;
  String type;
  String definition;

  Word({this.imageUrl, this.name, this.type, this.definition});
}
