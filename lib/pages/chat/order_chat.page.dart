import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fuodz/component/base.page.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jiffy/jiffy.dart';
import 'package:fuodz/services/auth.service.dart';
import 'package:fuodz/services/stomp_websocket.service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:fuodz/constants/api.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:fuodz/services/toast.service.dart';

class OrderChatPage extends StatefulWidget {
  final String orderCode;
  final String chatType;
  final int receiverId;

  const OrderChatPage({
    Key? key,
    required this.orderCode,
    required this.chatType,
    required this.receiverId,
  }) : super(key: key);

  @override
  State<OrderChatPage> createState() => _OrderChatPageState();
}

class _OrderChatPageState extends State<OrderChatPage> {
  TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  int? currentUserId;
  bool isBusy = true;
  bool isUploading = false;
  
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final user = await AuthServices.getCurrentUser();
    if (mounted) {
      setState(() {
        currentUserId = user?.id;
      });
    }

    await _fetchHistory();
    _connectWebSocket();
  }

  Future<void> _fetchHistory() async {
    setState(() => isBusy = true);
    try {
      Dio dio = Dio();
      final response = await dio.get("${Api.baseUrl}chat/history/${widget.orderCode}/${widget.chatType}");
      if (response.statusCode == 200 && response.data != null) {
        if (mounted) {
          setState(() {
            messages = List<Map<String, dynamic>>.from(response.data["data"] ?? []);
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      print("Error fetching chat history: $e");
    }
    if (mounted) setState(() => isBusy = false);
  }

  void _connectWebSocket() {
    StompWebsocketService().connect(
      onConnect: (StompFrame frame) {
        StompWebsocketService().subscribe('/topic/chat.${widget.orderCode}.${widget.chatType}', (StompFrame frame) {
          if (frame.body != null) {
            final newMessage = jsonDecode(frame.body!);
            if (mounted) {
              setState(() {
                messages.add(newMessage);
              });
              _scrollToBottom();
            }
          }
        });
      },
      onWebSocketError: (dynamic error) => print('WS error: $error'),
    );
  }

  Future<void> _sendMessage({String? attachmentUrl}) async {
    final text = messageController.text.trim();
    if (text.isEmpty && attachmentUrl == null) return;

    final body = {
      "orderCode": widget.orderCode,
      "senderId": currentUserId,
      "receiverId": widget.receiverId,
      "chatType": widget.chatType,
      "message": text,
      "attachment": attachmentUrl,
    };

    StompWebsocketService().send('/app/chat.send', jsonEncode(body));
    messageController.clear();
    
    // Optimistic UI update
    if (mounted) {
      setState(() {
        messages.add({
          "sender_id": currentUserId,
          "message": text,
          "attachments": attachmentUrl != null ? [attachmentUrl] : [],
          "timestamp": DateTime.now().millisecondsSinceEpoch,
        });
      });
      _scrollToBottom();
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _uploadAttachment(image.path);
    }
  }

  Future<void> _uploadAttachment(String path) async {
    setState(() => isUploading = true);
    try {
      FormData formData = FormData.fromMap({
        "attachment": await MultipartFile.fromFile(path),
      });

      Dio dio = Dio();
      final token = await AuthServices.getAuthBearerToken();
      dio.options.headers["Authorization"] = "Bearer $token";
      final response = await dio.post("${Api.baseUrl}/chat/upload", data: formData);
      if (response.statusCode == 200 && response.data["success"]) {
        final url = response.data["url"];
        _sendMessage(attachmentUrl: url);
      } else {
        ToastService.toastError("Failed to upload attachment");
      }
    } catch (e) {
      print("Upload error: $e");
      ToastService.toastError("Failed to upload attachment");
    }
    if (mounted) setState(() => isUploading = false);
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    StompWebsocketService().disconnect();
    _scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Chat".tr(),
      body: Column(
        children: [
          Expanded(
            child: isBusy
                ? const CircularProgressIndicator().centered()
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg["sender_id"] == currentUserId;
                      final attachments = msg["attachments"] as List<dynamic>? ?? [];
                      
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? context.theme.primaryColor : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (msg["message"] != null && msg["message"].toString().isNotEmpty)
                                Text(
                                  msg["message"],
                                  style: TextStyle(color: isMe ? Colors.white : Colors.black),
                                ),
                              if (attachments.isNotEmpty)
                                ...attachments.map((url) => Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: CachedNetworkImage(
                                    imageUrl: url.toString(),
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                )).toList(),
                              const SizedBox(height: 5),
                              Text(
                                Jiffy.parseFromMillisecondsSinceEpoch(
                                  msg["timestamp"] != null ? int.tryParse(msg["timestamp"].toString()) ?? DateTime.now().millisecondsSinceEpoch : DateTime.now().millisecondsSinceEpoch
                                ).format(pattern: "hh:mm a"),
                                style: TextStyle(
                                  color: isMe ? Colors.white70 : Colors.black54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (isUploading)
            const LinearProgressIndicator().wFull(context),
          Container(
            padding: const EdgeInsets.all(10),
            color: context.theme.colorScheme.surface,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message".tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: context.theme.primaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
