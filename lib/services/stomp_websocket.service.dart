import 'package:stomp_dart_client/stomp_dart_client.dart';

class StompWebsocketService {
  static final StompWebsocketService _instance =
      StompWebsocketService._internal();

  factory StompWebsocketService() {
    return _instance;
  }

  StompWebsocketService._internal();

  StompClient? stompClient;

  // Change this to your spring boot server url
  final String socketUrl =
      "wss://api.mybalifriendz.co:8080/ws"; // Adjust port/path as needed

  void connect({
    required Function(StompFrame) onConnect,
    required Function(StompFrame) onWebSocketError,
  }) {
    if (stompClient != null && stompClient!.connected) return;

    stompClient = StompClient(
      config: StompConfig(
        url: socketUrl,
        onConnect: onConnect,
        onWebSocketError: (dynamic error) => print('WebSocket Error: $error'),
        onStompError: (dynamic error) => print('Stomp Error: $error'),
        onWebSocketDone: () => print('WebSocket done'),
      ),
    );

    stompClient!.activate();
  }

  void disconnect() {
    if (stompClient != null) {
      stompClient!.deactivate();
      stompClient = null;
    }
  }

  void subscribe(String topic, Function(StompFrame) callback) {
    if (stompClient != null && stompClient!.connected) {
      stompClient!.subscribe(destination: topic, callback: callback);
    }
  }

  void send(String destination, String body) {
    if (stompClient != null && stompClient!.connected) {
      stompClient!.send(destination: destination, body: body);
    }
  }
}
