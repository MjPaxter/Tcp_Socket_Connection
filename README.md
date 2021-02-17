# tcp_socket_connection

This is a Flutter package that allows you to connect to a socket over the net. All data is then read using UTF-8.

## Getting started

To use this plugin, add *tcp_socket_connection* as a dependency in your pubspec.yaml file.

## Main Example
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
  //Instantiating the class with the Ip and the PortNumber
  TcpSocketConnection socketConnection=TcpSocketConnection("192.168.1.113", 10251);

  String message="";

  @override
  void initState() {
    super.initState();
    startConnection();
  }

  //receiving and sending back a custom message
  void messageReceived(String msg){
    setState(() {
      message=msg;
    });
    socketConnection.sendMessage("MessageIsReceived :D ");
  }

  //starting the connection and listening to the socket asynchronously
  void startConnection() async{
    socketConnection.enableConsolePrint(true);    //use this to see in the console what's happening
    if(await socketConnection.canConnect(5000, attempts: 3)){   //check if it's possible to connect to the endpoint
      await socketConnection.connect(5000, "EOS", messageReceived, attempts: 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text(
          'You have received '+ message,
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
await socketConnection.connect(TIMEOUT, EOS, CALLBACK_FUNCTION);
```

The method <span style="color:navy">**connect**</span> allows you to set a TIMEOUT before finishing attempting to connect, an EOS (End Of Stream) representing a specific set of characters indicating that the message is finished, a CALLBACK_FUNCTION that is created by the developer and takes a <span style="color:darkred">**String**</span> as parameter. The CALLBACK_FUNCTION will be called when the message is received.

The word **await** is really important since the connection requires a little bit of time to be initialized. Write that line of code inside an async method to ensure it doesn't impact the UI.

To send a message use the following method:
```javascript
socketConnection.sendMessage(MESSAGE);
```
It will automatically append the EOS you specified when calling the <span style="color:navy">**connect**</span> method at the end of the MESSAGE.

## Examples
Imagine you are receiving a <span style="color:darkred">**String**</span> from a server which states *"Confirm?EOS"*. In order to read it you have to listen to the server asynchronously until you receive the EOS to be sure that the message is finished. After that you have to split the <span style="color:darkred">**String**</span> and keep only the part you need, in this case *"Confirm?"*. This is all done by the <span style="color:navy">**connect**</span> method in only 1 line of code!
```javascript
await socketConnection.connect(TIMEOUT, EOS, CALLBACK_FUNCTION, {ATTEMPTS=1});
```
Imagine you are receiving a <span style="color:darkred">**String**</span> from a server which states *"Store%separator%SOME_JSON_DATA%separator%EOS"*. In order to read it you have to listen to the server asynchronously until you receive the EOS to be sure that the message is finished. After that you have to split the <span style="color:darkred">**String**</span> and keep only the part you need. First of all you have to detect which command is sent by the server, in this case "Store" and then read all the Json data untill it's finished. This is all done by the <span style="color:navy">**connectWithCommand**</span> method in only 1 line of code!
```javascript
await socketConnection.connectWithCommand(TIMEOUT, SEPARATOR, EOS, CALLBACK_FUNCTION, {ATTEMPTS=1});
```
Imagine you are receiving a <span style="color:darkred">**String**</span> from a server.  With the <span style="color:navy">**simpleConnect**</span> method you can read messages received (that probably need to be elaborated by you: the developer) in only 1 line of code!
```javascript
await socketConnection.simpleConnect(TIMEOUT, CALLBACK_FUNCTION, {ATTEMPTS=1});
```

## Last but not least

If you find this package useful, don't forget to leave a like! I appreciate it!
