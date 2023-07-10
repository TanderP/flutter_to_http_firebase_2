import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

//
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Firebase'),
      debugShowCheckedModeBanner: false, // to remove debug banner
      darkTheme: ThemeData.dark(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // textfield
  void onTyped(String userVal) {
    setState(() {
      flutterSend = userVal;
    });
  }

  var textFieldController = TextEditingController();
  //
  var flutterSend = "NULL";
  bool _isOn = false;
  String fireBaseData = '';
  bool doorLocked = false;
  bool locked = false;
  // switch
  void toggleSwitch(bool value) {
    setState(() {
      _isOn = value;
      doorLocked = _isOn;
      sendDoorLockStatus();
    });
  }

  Future<void> sendDoorLockStatus() async {
    final response = await http.put(
      Uri.parse('$firebaseURL/doorLockStatus.json'),
      body: json.encode({'locked': doorLocked}),
    );
  }

  final String firebaseURL =
      "https://tdr1-89467-default-rtdb.asia-southeast1.firebasedatabase.app/";
  //firebase send
  void dataSend() async {
    final response = await http.put(Uri.parse("$firebaseURL/fromFlutter.json"),
        body: json.encode({
          "name": flutterSend,
        }));
  }

  // firebase fetch

  void initState() {
    super.initState();
    // Start fetching data every 1 second

    Timer.periodic(Duration(seconds: 1), (timer) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse("$firebaseURL/fromFB.json"));
    final response2 =
        await http.get(Uri.parse("$firebaseURL/doorLockStatus.json"));
    if (response.statusCode == 200) {
      setState(() {
        final data = json.decode(response.body);
        final data2 = json.decode(response2.body);
        fireBaseData = data['Data'].toString();
        locked = data2['locked'] as bool;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Center(
        child: SizedBox(
          width: 600,
          height: 600,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  SizedBox(height: 100),
                  Text(
                    "Humidity :$fireBaseData",
                    style: TextStyle(fontSize: 40),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    onSubmitted: onTyped,
                    controller: textFieldController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'to Firebase',
                    ),
                  ),
                  SizedBox(height: 20),
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            onTyped(textFieldController.text);
                            dataSend();
                          });
                        },
                        child: Text('Send'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isOn = !_isOn;
                        toggleSwitch(_isOn);
                      });
                    },
                    child: Container(
                      width: 70,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: locked ? Colors.red : Colors.green,
                      ),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            top: 2,
                            left: locked ? 30 : 2,
                            right: locked ? 2 : 30,
                            bottom: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Icon(
                    locked ? Icons.lock : Icons.lock_open,
                    size: 40,
                    color: locked ? Colors.red : Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
