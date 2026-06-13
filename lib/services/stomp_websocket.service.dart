import 'package:stomp_dart_client/stomp_dart_client.dart';

import 'package:fuodz/constants/api.dart';

class StompWebsocketService {
  static final StompWebsocketService _instance =
      StompWebsocketService._internal();

  factory StompWebsocketService() {
    return _instance;
  }

  StompWebsocketService._internal();

  StompClient? stompClient;

  // Change this to your spring boot server url
  final String socketUrl = (() {
    try {
      final uri = Uri.parse(Api.baseUrl);
      final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
      return uri.replace(scheme: scheme, path: '/ws').toString();
    } catch (e) {
      return "wss://api.mybalifriendz.co/ws";
    }
  })();

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
