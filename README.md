# tcp_socket_connection

This package allows you to connect to a socket over the net. All data is then read using UTF-8.

## Getting started

To use this plugin, add *tcp_socket_connection* as a dependency in your pubspec.yaml file.

## Examples
Here is shown an example where a connection is established and the received message is displayed in a Text widget.
```javascript
import 'package:flutter/material.dart';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';

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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  TcpSocketConnection socketConnection=TcpSocketConnection("192.168.1.113", 10251);
  String message="";

  @override
  void initState() {
    super.initState();
    startConnection();
  }

  //msg is the message reseived
  void messageReceived(String msg){
    setState(() {
      message=msg;
    });
  }

  //timeout is set to 5000 ms and messageReceived will be called when 'EOF' received
  void startConnection() async{
    await socketConnection.connect(5000, "EOF", messageReceived);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text(
          'You have received'+ message,
        ),
      ),
    );
  }
}
```
## Usage
First of all declare a new instance of the *TcpSocketConnection* class:
```javascript
TcpSocketConnection socketConnection=TcpSocketConnection(IP_ADDRESS, PORT_NUMBER);
```
Then, to establish a connection it's used the following method:

```javascript
await socketConnection.connect(TIMEOUT, EOF, CALLBACK_FUNCTION);
```

The method *connect* allows you to set a TIMEOUT before finishing attempting to connect, an EOF representing a specific set of characters indicating that the message is finished, a CALLBACK_FUNCTION that is created by the developer and takes a *String* as parameter. The CALLBACK_FUNCTION will be called when the message is received.

The word *await* is really important since the connection requires a little bit of time to be initialized. Write that line of code inside an async method to ensure it doesn't impact the UI.

To send a message use the following method:
```javascript
socketConnection.sendMessage(MESSAGE);
```
