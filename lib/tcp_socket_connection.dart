library tcp_socket_connection;
import 'dart:async';
import 'dart:io';
import 'dart:convert';

class TcpSocketConnection{

  String _ipAddress;
  int _portAddress;
  Socket _server;
  bool _connected=false;
  bool _logPrintEnabled=false;

  /// Initializes che class itself
  ///  * @param  ip  the server's ip you are trying to connect to
  ///  * @param  port the servers's port you are trying to connect to
  TcpSocketConnection(String ip, int port){
    _ipAddress=ip;
    _portAddress=port;
  }

  /// Initializes che class itself
  ///  * @param  the ip  server's ip you are trying to connect to
  ///  * @param  the port servers's port you are trying to connect to
  ///  * @param  enable if set to true, then events will be printed in the console
  TcpSocketConnection.constructorWithPrint(String ip, int port, bool enable){
    _ipAddress=ip;
    _portAddress=port;
    _logPrintEnabled=enable;
  }

  /// Shows events in the console with print method
  /// * @param  enable if set to true, then events will be printed in the console
  enableConsolePrint(bool enable){
    _logPrintEnabled=enable;
  }

/*
  /// Initializes the connection. Socket starts listening to server for data.
  /// 'callback' function will be called when 'eom' is received
  ///
  ///  * @param  timeOut  amount of time to attempt the connection in milliseconds
  ///  * @param  separator  sequence of characters to use between commands
  ///  * @param  eom  sequence of characters at the end of each single message
  ///  * @param  callback  function called when received a message. It must take 2 'String' as params. The first one is the command received, the second one is the message itself.
  ///  * @param  attempts  number of attempts before stop trying to connect. Default is 1.
  connectWithCommand(int timeOut, String separator, String eom,  Function callback, {int attempts=1}) async{
    if(_ipAddress==null){
      print("Class not initialized. You must call the constructor!");
      return;
    }
    _eom=eom;
    _separator=separator;
    int k=1;
    while(k<=attempts){
      try{
        _server = await Socket.connect(_ipAddress, _portAddress, timeout: new Duration(milliseconds: timeOut));
        break;
      }catch(Exception){
        _printData(k.toString()+" attempt: Socket not connected (Timeout reached)");
        if(k==attempts){
          return;
        }
      }
      k++;
    }
    _connected=true;
    _printData("Socket successfully connected");
    String message="";
    _server.listen((List<int> event) async {
      message += (utf8.decode(event));
      if(message.contains(eom)){
        List<String> commands=message.split(_separator);
        _printData("Message received: "+message);
        callback(commands[0],commands[1].split(eom)[0]);
        if(commands[1].split(eom).length>1){
          message=commands[1].split(eom)[1];
        }else{
          message="";
        }
      }
    });
  }*/

  /// Initializes the connection. Socket starts listening to server for data
  /// 'callback' function will be called whenever data is received. The developer elaborates the message received however he wants
  /// No separator is used to split message into parts
  ///  * @param  timeOut  the amount of time to attempt the connection in milliseconds
  ///  * @param  callback  the function called when received a message. It must take a 'String' as param which is the message received
  ///  * @param  attempts  the number of attempts before stop trying to connect. Default is 1.
  connect(int timeOut, Function callback,{int attempts=1}) async{
    if(_ipAddress==null){
      print("Class not initialized. You must call the constructor!");
      return;
    }
    int k=1;
    while(k<=attempts){
      try{
        _server = await Socket.connect(_ipAddress, _portAddress, timeout: new Duration(milliseconds: timeOut));
        break;
      }catch(Exception){
        _printData(k.toString()+" attempt: Socket not connected (Timeout reached)");
        if(k==attempts){
          return;
        }
      }
      k++;
    }
    _connected=true;
    _printData("Socket successfully connected");
    _server.listen((List<int> event) async {
      String received=(utf8.decode(event));
      _printData("Message received: "+received);
      callback(received);
    });
  }



  /// Initializes the connection. Socket starts listening to server for data
  /// 'callback' function will be called when 'eom' is received
  ///  * @param  the timeOut  amount of time to attempt the connection in milliseconds
  ///  * @param  the eom  sequence of characters at the end of each single message
  ///  * @param  the callback  function called when received a message. It must take a 'String' as param which is the message received
  ///  * @param  the attempts  number of attempts before stop trying to connect. Default is 1
  connectEOM(int timeOut, String eom,  Function callback, {int attempts=1}) async{
    if(_ipAddress==null){
      print("Class not initialized. You must call the constructor!");
      return;
    }
    int k=1;
    while(k<=attempts){
      try{
        _server = await Socket.connect(_ipAddress, _portAddress, timeout: new Duration(milliseconds: timeOut));
        break;
      }catch(Exception){
        _printData(k.toString()+" attempt: Socket not connected (Timeout reached)");
        if(k==attempts){
          return;
        }
      }
      k++;
    }
    _connected=true;
    _printData("Socket successfully connected");
    StringBuffer message=new StringBuffer();
    _server.listen((List<int> event) async {
      String received=(utf8.decode(event));
      message.write(received);
      if(received.contains(eom)){
        _printData("Message received: "+message.toString());

        List<String> messages=message.toString().split(eom);
        if(!received.endsWith(eom)){
          message.clear();
          message.write(messages.last);
          messages.removeLast();
        }
        else{
          message.clear();
        }
        for(String m in messages){
          callback(m);
        }
      }
    });
  }

  /// Stops the connection and close the socket
  void disconnect(){
    if(_server!=null){
      try{
        _server.close();
        _printData("Socket disconnected successfully");
      }catch(exception){
        print("ERROR"+exception);
      }
    }
    _connected=false;
  }

  /// Checks if the socket is connected
  bool isConnected(){
    return _connected;
  }

  /// Sends a message to server. Make sure to have established a connection before calling this method
  /// Message will be sent as 'message'
  ///  * @param  message  message to send to server
  void sendMessage(String message) async{
    if(_server!=null &&_connected){
      _server.add(utf8.encode(message));
      _printData("Message sent: "+message);
    }else{
      print("Socket not initialized before sending message! Make sure you have already called the method 'connect()'");
    }
  }

  /// Sends a message to server. Make sure to have established a connection before calling this method
  /// Message will be sent as 'message'+'eom'
  ///  * @param  message  the message to send to server
  ///  * @param  eom  the end of message to send to server
  void sendMessageEOM(String message,String eom) async{
    if(_server!=null &&_connected){
      _server.add(utf8.encode(message+eom));
      _printData("Message sent: "+message+eom);
    }else{
      print("Socket not initialized before sending message! Make sure you have already called the method 'connect()'");
    }
  }
/*
  /// Send message to server with a command. Make sure to have established a connection before calling this method. Never use this if the connection is established with the 'simpleConnnect()' method
  /// Message will be sent as 'command'+'separator'+'message'+'separator'+'eom'
  ///  * @param  message  message to send to server
  ///  * @param  command  tells the server what to do with the message
  void sendMessageWithCommand(String message, String command) async{
    if(_server!=null){
      _server.add(utf8.encode(command+_separator+message+_separator+_eom));
      _printData("Message sent: "+command+_separator+message+_separator+_eom);
    }else{
      print("Socket not initialized before sending message! Make sure you have alreadt called the method 'connect()'");
    }
  }*/


  /// Test the connection. It will try to connect to the endpoint and if it does, it will disconnect and return 'true' (otherwise false)
  ///  * @param  timeOut  the amount of time to attempt the connection in milliseconds
  ///  * @param  attempts  the number of attempts before stop trying to connect. Default is 1.
  Future<bool> canConnect(int timeOut,{int attempts=1}) async{
    if(_ipAddress==null){
      print("Class not initialized. You must call the constructor!");
      this.disconnect();
      return false;
    }
    int k=1;
    while(k<=attempts){
      try{
        _server = await Socket.connect(_ipAddress, _portAddress, timeout: new Duration(milliseconds: timeOut));
        this.disconnect();
        return true;
      }catch(Exception){
        _printData(k.toString()+" attempt: Socket not connected (Timeout reached)");
        if(k==attempts){
          this.disconnect();
          return false;
        }
      }
      k++;
    }
    this.disconnect();
    return false;
  }

  void _printData(String data){
    if(_logPrintEnabled){
      print(data);
    }
  }
}