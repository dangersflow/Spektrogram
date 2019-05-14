import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:photo_view/photo_view.dart';
import 'package:faker/faker.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

//global variables
var faker = Faker();
var info;
final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
String height = "2048";
String width = "1024";
String size = "${height}x${width}";
String mode = "combined";
String color = "intensity";
String scale = "log";
String win_func = "hann";
String orientation = "vertical";
int start = 0;
int stop = 0;
int saturation = 1;
int gain = 1;
double rotation = 0.0;
bool legend = true;
bool darkMode = false;
bool progressIndicator = false;
bool showChooseTrackText = true;
SharedPreferences pref;
String currentSpectrumDirectory;
String currentFilePath;
File image;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: "Nunito",
        primaryColor: Colors.black,
        //canvasColor: Colors.black,
        brightness: Brightness.dark,
        //cardColor: Color(0xFF292929),
        cardColor: Color(0xFF252525),
      ),
      home: MyHomePage(),
    );
  }
}

class ImageView extends StatefulWidget {
  File image;

  ImageView({this.image});

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  File _image;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _image = widget.image;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Container(
        child: GestureDetector(
          child: PhotoView(
            heroTag: 'dash',
            imageProvider: FileImage(_image),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ));
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController _height;
  TextEditingController _width;
  TextEditingController _start;
  TextEditingController _stop;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _height = new TextEditingController(text: height);
    _width = new TextEditingController(text: width);
    _start = new TextEditingController(text: start.toString());
    _stop = new TextEditingController(text: stop.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Settings",
            style: TextStyle(fontFamily: "Quicksand"),
          ),
        ),
        body: ListView(
          children: <Widget>[
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text("Height"),
                    trailing: Container(
                      width: 150,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false, signed: false),
                              controller: _height,
                              onChanged: (controller) {
                                pref.setString('height', _height.text);
                                height = pref.getString('height');
                                print(height);
                              },
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Width"),
                    trailing: Container(
                      width: 150,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false, signed: false),
                              controller: _width,
                              onChanged: (controller) {
                                pref.setString('width', _width.text);
                                width = pref.getString('width');
                                print(width);
                              },
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text("Channel Mode"),
                    trailing: Container(
                      width: 150,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: DropdownButton<String>(
                              value: mode,
                              onChanged: (String newValue) {
                                setState(() {
                                  pref.setString('mode', newValue);
                                  mode = pref.getString('mode');
                                });
                              },
                              items: <String>['combined', 'separate']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Color Scheme"),
                    trailing: Container(
                      width: 150,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: DropdownButton<String>(
                              value: color,
                              onChanged: (String newValue) {
                                setState(() {
                                  pref.setString('color', newValue);
                                  color = pref.getString('color');
                                  print(color);
                                });
                              },
                              items: <String>[
                                'channel',
                                'intensity',
                                'rainbow',
                                'moreland',
                                'nebulae',
                                'fire',
                                'fiery',
                                'fruit',
                                'cool',
                                'magma',
                                'green',
                                'viridis',
                                'plasma',
                                'cividis',
                                'terrain'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Scale"),
                    trailing: Container(
                      width: 150,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: DropdownButton<String>(
                              value: scale,
                              onChanged: (String newValue) {
                                setState(() {
                                  pref.setString('scale', newValue);
                                  scale = pref.getString('scale');
                                });
                              },
                              items: <String>[
                                'lin',
                                'sqrt',
                                'cbrt',
                                'log',
                                '4thrt',
                                '5thrt'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            Card(
              child: ListTile(
                title: Text("Saturation"),
                trailing: Container(
                  width: 250,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Slider(
                          value: saturation.toDouble(),
                          onChanged: (value) {
                            setState(() {
                              pref.setInt('saturation', value.floor().toInt());
                              saturation = pref.getInt('saturation');
                              print(saturation.toString());
                            });
                          },
                          max: 10.0,
                          min: -10.0,
                          activeColor: Colors.grey,
                        ),
                      ),
                      Text(saturation.toString())
                    ],
                  ),
                ),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text("Window Function"),
                    trailing: Container(
                      width: 150,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: DropdownButton<String>(
                              value: win_func,
                              onChanged: (String newValue) {
                                setState(() {
                                  pref.setString('win_func', newValue);
                                  win_func = pref.getString('win_func');
                                  print(win_func);
                                });
                              },
                              items: <String>[
                                'rect',
                                'bartlett',
                                'hann',
                                'hanning',
                                'hamming',
                                'blackman',
                                'welch',
                                'flattop',
                                'bharris',
                                'bnuttall',
                                'bhann',
                                'sine',
                                'nuttall',
                                'lanczos',
                                'gauss',
                                'tukey',
                                'dolph',
                                'cauchy',
                                'parzen',
                                'poisson',
                                'bohman'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Orientation"),
                    trailing: Container(
                      width: 150,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: DropdownButton<String>(
                              value: orientation,
                              onChanged: (String newValue) {
                                setState(() {
                                  pref.setString('orientation', newValue);
                                  orientation = pref.getString('orientation');
                                  print(orientation);
                                });
                              },
                              items: <String>['vertical', 'horizontal']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            Card(
              child: ListTile(
                title: Text("Color Rotation"),
                trailing: Container(
                  width: 250,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Slider(
                          value: ((rotation * pow(10, 1)).round()) / pow(10, 1),
                          onChanged: (value) {
                            setState(() {
                              pref.setDouble('rotation',
                                  ((value * pow(10, 1)).round()) / pow(10, 1));
                              rotation = pref.getDouble('rotation');
                              print(rotation.toString());
                            });
                          },
                          max: 1.0,
                          min: -1.0,
                          activeColor: Colors.grey,
                        ),
                      ),
                      Text(rotation.toString())
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text("Start Frequency (Hz)"),
                    trailing: Container(
                      width: 150,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false, signed: false),
                              controller: _start,
                              onChanged: (controller) {
                                pref.setInt('start', int.parse(_start.text));
                                start = pref.getInt('start');
                                print(start);
                              },
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Stop Frequency (Hz)"),
                    trailing: Container(
                      width: 150,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false, signed: false),
                              controller: _stop,
                              onChanged: (controller) {
                                pref.setInt('stop', int.parse(_stop.text));
                                stop = pref.getInt('stop');
                                print(stop);
                              },
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            Card(
              child: ListTile(
                title: Text("Legend"),
                trailing: Switch(
                    value: legend,
                    onChanged: (value) {
                      setState(() {
                        pref.setBool('legend', value);
                        legend = pref.getBool('legend');
                      });
                    }),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            ListTile(
                trailing: Container(
                  width: 150,
                  child: Row(
                    children: <Widget>[
                      RaisedButton(
                        child: Text("Reset Settings"),
                        onPressed: () {
                          setState(() {
                            pref.clear();
                            height = "2048";
                            width = "1024";
                            _height = new TextEditingController(text: height);
                            _width = new TextEditingController(text: width);
                            size = "${height}x${width}";
                            mode = "combined";
                            color = "intensity";
                            scale = "log";
                            win_func = "hann";
                            orientation = "vertical";
                            start = 0;
                            stop = 0;
                            _start =
                            new TextEditingController(text: start.toString());
                            _stop =
                            new TextEditingController(text: stop.toString());
                            saturation = 1;
                            gain = 1;
                            rotation = 0;
                            legend = true;
                          });
                        },
                      ),
                    ],
                  ),
                ))
          ],
        ));
  }
}

String returnCurrentSetCommands() {
  if (int.parse(height) < 40) height = "40";
  if (int.parse(width) < 40) width = "40";

  if (stop <= start && start != 0 && stop != 0) stop = start + 1;
  if (start >= stop && start != 0 && stop != 0) start = stop - 1;

  return "showspectrumpic=size=${height}x${width}:mode=$mode:color=$color:scale=$scale:saturation=${saturation.toString()}:"
      "win_func=$win_func:orientation=$orientation:gain=${gain.toString()}:legend=$legend:rotation=${rotation.toString()}:"
      "start=${start.toString()}:stop=${stop.toString()}";
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  void init() async {
    //saved preferences
    pref = await SharedPreferences.getInstance();
    height = pref.getString('height') ?? "2048";
    width = pref.getString('width') ?? "1024";
    size = "${height}x${width}";
    mode = pref.getString('mode') ?? "combined";
    color = pref.getString('color') ?? "intensity";
    scale = pref.getString('scale') ?? "log";
    win_func = pref.getString('win_func') ?? "hann";
    orientation = pref.getString('orientation') ?? "vertical";
    start = pref.getInt('start') ?? 0;
    stop = pref.getInt('stop') ?? 0;
    saturation = pref.getInt('saturation') ?? 1;
    gain = pref.getInt('gain') ?? 1;
    rotation = pref.getDouble('rotation') ?? 0.0;
    legend = pref.getBool('legend') ?? true;
    darkMode = pref.getBool('darkMode') ?? false;
    currentSpectrumDirectory = pref.getString('currentSpectrumDirectory') ?? "";
    currentFilePath = pref.getString('currentFilePath') ?? "";
    await _flutterFFmpeg
        .getMediaInformation("${currentFilePath}")
        .then((mediaInfo) => info = mediaInfo);
    image = File(currentSpectrumDirectory);

    if (!(await image.exists())){
      image = null;
      showChooseTrackText = true;
    }
    else
      showChooseTrackText = false;

    setPreviousState();
  }

  void setPreviousState() {
    setState(() {
      height;
      width;
      size;
      mode;
      color;
      scale;
      win_func;
      orientation;
      start;
      stop;
      saturation;
      gain;
      rotation;
      legend;
      darkMode;
      currentSpectrumDirectory;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Spektrogram",
          style: TextStyle(fontFamily: "Nunito"),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => SettingsPage()));
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                info != null && currentFilePath != ""
                    ? Card(
                  child: Column(
                    children: <Widget>[
                      info != null && currentFilePath != ""
                          ? Text("File Location:", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),):Text(""),
                      info != null && currentFilePath != ""
                          ? ListTile(
                        title: Text("${info["path"]}"),
                      )
                          : Text(""),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                  ),
                ):Container(),
                showChooseTrackText == true
                    ? Text("Select an audio track!", style: TextStyle(color: Colors.grey),):Container(margin: EdgeInsets.all(0),),
                progressIndicator
                    ? Container(
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Loading...",
                        style: TextStyle(fontSize: 20),
                      ),
                      Container(
                        margin: EdgeInsets.all(15),
                      ),
                      CircularProgressIndicator()
                    ],
                  ),
                  height: 250,
                  width: 300,
                )
                    : Container(),
                image != null && currentFilePath != ""
                    ? Card(
                  child: Column(
                    children: <Widget>[
                      image != null && currentFilePath != ""
                          ? Text("Generated Spectrum:", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),):Text(""),
                      image != null && currentFilePath != ""
                          ? Container(
                        child: Hero(
                            tag: 'dash',
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: FileImage(image),
                                      fit: BoxFit.contain)),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              ImageView(
                                                image: image,
                                              )));
                                },
                              ),
                              height: 250,
                            )),
                      )
                          : Container(),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                  ),
                ):Container(),
                info != null && currentFilePath != ""
                    ? Card(
                  child: Column(
                      children: <Widget>[
                        info != null && currentFilePath != ""
                            ? Text("Audio Information:", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),):Text(""),
                        Text(""),
                        info != null && currentFilePath != ""
                            ? ListTile(
                          title: Text(
                              "Codec: ${info["streams"][0]["codec"]}\n\nSample Rate: ${info["streams"][0]["sampleRate"]} Hz\n\nBitrate: ${info["streams"][0]["bitrate"]!=null ? info["streams"][0]["bitrate"]:info["bitrate"]} kbps\n\nSample Format: ${info["streams"][0]["sampleFormat"]}\n\nChannel Layout: ${info["streams"][0]["channelLayout"]}"),
                        )
                            : Text(""),
                      ],
                    ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
                  ),
                ):Container(),
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            alignment: FractionalOffset.center,
          ),
        ),
      )
      ,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            if (image != null) image.delete();
            image = null;
            info = null;
            showChooseTrackText = false;
          });
          final directory = await getApplicationDocumentsDirectory();
          print(directory.path);
          String path = await FilePicker.getFilePath(type: FileType.AUDIO);
          print(path);
          pref.setString('currentFilePath', path);
          setState(() {
            currentFilePath = pref.getString('currentFilePath');
          });
           _flutterFFmpeg.getMediaInformation("${path}").then((mediaInfo) {
            setState(() {
              info = mediaInfo;
            });
          });
          print("$info");
          String mainArg = returnCurrentSetCommands();
          print(mainArg);
          String tempFake =
          faker.randomGenerator.integer(3333333333, min: 1).toString();
          var arguments = [
            "-i",
            "$path",
            "-lavfi",
            mainArg,
            "-y",
            "${directory.path}/${tempFake}.jpg"
          ];
          setState(() {
            progressIndicator = true;
          });
          _flutterFFmpeg.executeWithArguments(arguments).then((rc) async {
            File tempImage =
            new File("${directory.path}/${tempFake}.jpg");
            if (await tempImage.exists()) {
              setState(() {
                progressIndicator = false;
                image = tempImage;
                print(path);
                pref.setString('currentSpectrumDirectory', image.path);
                currentSpectrumDirectory =
                    pref.getString('currentSpectrumDirectory');
                print(currentSpectrumDirectory);
              });
            } else {
              setState(() {
                progressIndicator = false;
                image = null;
                info = null;
                showChooseTrackText = true;
              });
            }
            print(rc);
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
