import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/model/chatbot_models.dart';
import 'package:roomdz_frontend/service/chatbot_service.dart';
import 'package:roomdz_frontend/view/user/detailScreen.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatbotService _chatbotService = ChatbotService();
  final TextEditingController _messageCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<ChatbotMessage> _messages = [];
  List<String> _suggestions = [];
  int? _conversationId;
  bool _isLoading = false;
  bool _isBooting = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    setState(() => _isBooting = true);

    try {
      final data = await _chatbotService.getSuggestions(lang: 'en');
      if (!mounted) return;

      setState(() {
        _messages
          ..clear()
          ..add(
            ChatbotMessage.local(
              role: 'assistant',
              content: data.welcomeMessage,
            ),
          );
        _suggestions = data.suggestions;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..add(
            ChatbotMessage.local(
              role: 'assistant',
              content:
                  'RoomDz Assistant is ready. Ask me about available rooms.',
            ),
          );
        _suggestions = const [
          'Find rooms under \$200',
          'Rooms in BKK with WiFi',
          'Cheapest available rooms',
        ];
      });
    } finally {
      if (mounted) {
        setState(() => _isBooting = false);
      }
    }
  }

  Future<void> _sendMessage([String? preset]) async {
    final text = (preset ?? _messageCtrl.text).trim();
    if (text.isEmpty || _isLoading) return;

    _messageCtrl.clear();
    setState(() {
      _messages.add(ChatbotMessage.local(role: 'user', content: text));
      _isLoading = true;
      _suggestions = const [];
    });
    _scrollToBottom();

    try {
      final reply = await _chatbotService.sendMessage(
        message: text,
        conversationId: _conversationId,
      );

      if (!mounted) return;
      setState(() {
        _conversationId = reply.conversationId ?? _conversationId;
        _messages.add(reply.message);
        _suggestions = reply.message.suggestions;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatbotMessage.local(
            role: 'assistant',
            content: 'Sorry, I could not reach the RoomDz chatbot API. $e',
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  void _startNewChat() {
    _conversationId = null;
    _chatbotService.resetSession();
    _loadSuggestions();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary, size: 26),
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'RoomDz Assistant',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'New chat',
            onPressed: _isBooting ? null : _startNewChat,
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isBooting
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return const _TypingBubble();
                      }

                      return _MessageBubble(message: _messages[index]);
                    },
                  ),
          ),
          if (_suggestions.isNotEmpty && !_isLoading)
            _SuggestionBar(suggestions: _suggestions, onSelected: _sendMessage),
          _Composer(
            controller: _messageCtrl,
            isLoading: _isLoading,
            onSend: () => _sendMessage(),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatbotMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final bubbleColor = isUser ? AppColors.primary : AppColors.surface;
    final textColor = isUser ? Colors.white : AppColors.neutral;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.84,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: isUser ? null : const Radius.circular(4),
                ),
                boxShadow: isUser
                    ? const []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Text(
                message.content,
                style: TextStyle(color: textColor, fontSize: 15, height: 1.35),
              ),
            ),
            if (message.rooms.isNotEmpty) _RoomResults(rooms: message.rooms),
          ],
        ),
      ),
    );
  }
}

class _RoomResults extends StatelessWidget {
  final List<ChatbotRoom> rooms;

  const _RoomResults({required this.rooms});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 198,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: rooms.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final room = rooms[index];
          return _RoomCard(room: room);
        },
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final ChatbotRoom room;

  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Get.to(() => Detailscreen(id: room.id));
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 94,
              width: double.infinity,
              child: room.image == null || room.image!.isEmpty
                  ? Container(
                      color: const Color(0xFFE2E8F0),
                      child: const Icon(Icons.apartment_outlined, size: 36),
                    )
                  : CachedNetworkImage(
                      imageUrl: room.image!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.apartment_outlined, size: 36),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${room.price.toStringAsFixed(0)} / ${room.pricePeriod}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionBar extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  const _SuggestionBar({required this.suggestions, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ActionChip(
            label: Text(suggestion),
            onPressed: () => onSelected(suggestion),
            backgroundColor: const Color(0xFFEFF6FF),
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.16)),
            labelStyle: const TextStyle(color: AppColors.primary),
          );
        },
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => isLoading ? null : onSend(),
                decoration: InputDecoration(
                  hintText: 'Ask about rooms...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              tooltip: 'Send',
              onPressed: isLoading ? null : onSend,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                fixedSize: const Size(48, 48),
              ),
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(
            16,
          ).copyWith(bottomLeft: const Radius.circular(4)),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
