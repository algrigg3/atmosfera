import 'package:atmosfera/services/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  IO.Socket? socket;

  SocketService._internal();

  void initSocket(String userId) {
    socket = IO.io('http://$BASE_URL', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    socket!.on('connect', (_) {
      print('Connected to socket');
      socket!.emit('join', userId);
    });

    socket!.on('disconnect', (_) {
      print('Disconnected from socket');
    });
  }

  void onNotification(Function(dynamic data) callback) {
    socket!.on('Notification', callback);
  }

  void dispose() {
    socket?.disconnect();
  }
}
