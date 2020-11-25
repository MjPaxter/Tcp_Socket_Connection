library tcp_socket_connection;
import 'dart:async';
import 'dart:io';
import 'dart:convert';

class SocketConnection{

  String _ipAddress;
  int _portAddress;
  Socket _server;
  String _eof;
  String _separator;

  /// Initializes che class itself
  ///  * @param  ip  server's ip you are trying to connect to
  ///  * @param  port servers's port you are trying to connect to

  SocketConnection(String ip, int port){
    _ipAddress=ip;
    _portAddress=port;
  }


  /// Initializes the connection. Socket starts listening to server for data.
  /// 'callback' function will be called when 'eof' is received
  ///
  ///  * @param  timeOut  amount of time to attempt the connection in milliseconds
  ///  * @param  separator  sequence of characters to use between commands
  ///  * @param  eof  sequence of characters at the end of each single message
  ///  * @param  callback  function called when received a message. It must take 2 'String' as params. The first one is the command received, the second one is the message itself.

  connectWithCommand(int timeOut, String separator, String eof,  Function callback) async{
    if(_ipAddress==null){
      print("Cass not initialized. You must call the constructor!");
      return;
    }
    _eof=eof;
    _separator=separator;
    Timer t=_startTimeout(timeOut);
    _server = await Socket.connect(_ipAddress, _portAddress);
    String message="";
    t.cancel();
    _server.listen((List<int> event) async {

      message += (utf8.decode(event));
      if(message.contains(eof)){
        List<String> commands=message.split(_separator);
        callback(commands[0],commands[1].split(eof)[0]);
        if(commands[1].split(eof).length>1){
          message=commands[1].split(eof)[1];
        }else{
          message="";
        }
      }
    });
  }

  /// Initializes the connection. Socket starts listening to server for data.
  /// 'callback' function will be called when 'eof' is received.
  /// No separator is used to split message into parts
  ///  * @param  timeOut  amount of time to attempt the connection in milliseconds
  ///  * @param  separator  sequence of characters to use between commands
  ///  * @param  eof  sequence of characters at the end of each single message
  ///  * @param  callback  function called when received a message. It must take a 'String' as param which is the message received.

  connect(int timeOut, String eof,  Function callback) async{
    if(_ipAddress==null){
      print("Cass not initialized. You must call the constructor!");
      return;
    }
    _eof=eof;
    Timer t=_startTimeout(timeOut);
    _server = await Socket.connect(_ipAddress, _portAddress);
    String message="";
    t.cancel();
    _server.listen((List<int> event) async {
      String received=(utf8.decode(event));
      message += received;
      if(message.contains(eof)){
        callback(message.split(eof)[0]);
        if(message.split(eof).length>1){
          message=message.split(eof)[1];
        }else{
          message="";
        }
      }
    });
  }

  /// Stop the connection and close the socket

  void disconnect(){
    if(_server!=null){
      try{
        _server.close();
      }catch(Exception){
        print("WTF?!?!");
      }
    }
  }

  /// Send message to server. Make sure to have established a connection before calling this method
  /// Message will be sent as 'message'+'separator'+'eof'
  ///  * @param  message  message to send to server

  void sendMessage(String message) async{
    if(_server!=null){
      _server.add(utf8.encode(message+_separator+_eof));
    }else{
      print("Socket not initialized before sending message! Make sure you have already called the method 'connect()'");
    }
  }

  /// Send message to server with a command. Make sure to have established a connection before calling this method
  /// Message will be sent as 'command'+'separator'+'message'+'separator'+'eof'
  ///  * @param  message  message to send to server
  ///  * @param  command  tells the server what to do with the message
  void sendMessageWithCommand(String message, String command) async{
    if(_server!=null){
      _server.add(utf8.encode(command+_separator+message+_separator+_eof));
    }else{
      print("Socket not initialized before sending message! Make sure you have alreadt called the method 'connect()'");
    }
  }

  _startTimeout(int time) {
    var duration = Duration(milliseconds: time);
    return new Timer(duration, ()=> _handleTimeout());
  }

  void _handleTimeout() {
    if(_server!=null){
      try{
        _server.close();
      }catch(Exception){
        print("WTF?!?!");
      }
    }
    print("Can't connect to server!");
  }
}