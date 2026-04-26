import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/ui_constants.dart';
import '../services/chat_service.dart';
import '../services/chat_history_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ChatService _chatService = ChatService();
  final ChatHistoryService _historyService = ChatHistoryService();

  final List<ChatMessage> _messages = [];

  bool _isLoading = false;
  bool _hasStartedChat = false;

  String? _currentChatId;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _hasStartedChat = true;
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });

    _messageController.clear();
    _safeScrollToBottom();

    try {
      String? chatId = _currentChatId;

      // Try saving user message, but don't break chatbot if history fails
      try {
        chatId ??= await _historyService.createChat(text);
        _currentChatId = chatId;

        await _historyService.saveMessage(
          chatId: chatId,
          text: text,
          isUser: true,
        );
      } catch (historyError) {
        print("⚠️ Chat history save failed: $historyError");
      }

      final reply = await _chatService.sendMessage(text);

      if (!mounted) return;

      setState(() {
        _messages.add(ChatMessage(text: reply, isUser: false));
      });

      // Try saving bot reply, but don't break chatbot if history fails
      try {
        if (_currentChatId != null) {
          await _historyService.saveMessage(
            chatId: _currentChatId!,
            text: reply,
            isUser: false,
          );
        }
      } catch (historyError) {
        print("⚠️ Bot reply history save failed: $historyError");
      }
    } catch (e) {
      print("❌ Chat send failed: $e");

      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: "Something went wrong. Please try again.",
            isUser: false,
          ),
        );
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _safeScrollToBottom();
    }
  }

  void _safeScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;

      final position = _scrollController.position;
      if (!position.hasContentDimensions) return;

      _scrollController.animateTo(
        position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  void _startNewChat() {
    Navigator.pop(context);

    setState(() {
      _messages.clear();
      _currentChatId = null;
      _hasStartedChat = false;
      _isLoading = false;
    });
  }

  Future<void> _openChat(String chatId) async {
    final savedMessages = await _historyService.getMessages(chatId);

    if (!mounted) return;

    setState(() {
      _currentChatId = chatId;
      _messages.clear();
      _messages.addAll(
        savedMessages.map(
              (msg) => ChatMessage(
            text: msg["text"] ?? "",
            isUser: msg["isUser"] ?? false,
          ),
        ),
      );
      _hasStartedChat = true;
      _isLoading = false;
    });

    Navigator.pop(context);
    _safeScrollToBottom();
  }

  void _openPreviousChats() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.68,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Previous Chats",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: _startNewChat,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          gradient: buttonGradient,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          "New Chat",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Expanded(
                  child: StreamBuilder(
                    stream: _historyService.getChats(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            "No previous chats yet.",
                            style: GoogleFonts.poppins(
                              color: subTextLight,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }

                      final chats = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          final data = chat.data();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F7FB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: borderLight.withOpacity(0.6),
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFC514C2)
                                      .withOpacity(0.10),
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: Color(0xFFC514C2),
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                data["title"] ?? "Untitled Chat",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: textDark,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: subTextLight,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  await _historyService.deleteChat(chat.id);
                                },
                              ),
                              onTap: () => _openChat(chat.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuButton() {
    return GestureDetector(
      onTap: _openPreviousChats,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: buttonGradient,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC514C2).withOpacity(0.22),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.sort_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
      child: SizedBox(
        height: 42,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _buildMenuButton(),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFC514C2), Color(0xFFA822D9)],
              ).createShader(bounds),
              child: Text(
                "mentora.",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.poppins(
                color: subTextLight,
                fontSize: 16,
                height: 1.35,
                fontWeight: FontWeight.w400,
              ),
              children: [
                const TextSpan(text: "Hello! I'm "),
                TextSpan(
                  text: "Mentora.",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFC514C2),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const TextSpan(
                  text: " Ask me anything\nrelated to ostomy care and training.",
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _buildInputBar(isWelcome: true),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 285),
        decoration: BoxDecoration(
          gradient: isUser ? buttonGradient : null,
          color: isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border:
          isUser ? null : Border.all(color: borderLight.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: GoogleFonts.poppins(
            color: isUser ? Colors.white : textDark,
            fontSize: 13.2,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderLight.withOpacity(0.6)),
        ),
        child: Text(
          "Mentora is typing...",
          style: GoogleFonts.poppins(
            color: subTextLight,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == _messages.length) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildInputBar({bool isWelcome = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isWelcome ? 0 : 22,
        8,
        isWelcome ? 0 : 22,
        isWelcome ? 0 : 18,
      ),
      child: Container(
        height: 46,
        padding: const EdgeInsets.only(left: 16, right: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.grey.withOpacity(0.22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                onSubmitted: (_) => _sendMessage(),
                enableSuggestions: false,
                autocorrect: false,
                contextMenuBuilder: (_, __) => const SizedBox.shrink(),
                style: GoogleFonts.poppins(
                  color: textDark,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: "Ask Mentora...",
                  hintStyle: GoogleFonts.poppins(
                    color: subTextLight.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            GestureDetector(
              onTap: _isLoading ? null : _sendMessage,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: _isLoading ? null : buttonGradient,
                  color: _isLoading ? Colors.grey.shade400 : null,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _hasStartedChat
                    ? _buildChatArea()
                    : _buildWelcomeScreen(),
              ),
            ),
            if (_hasStartedChat) _buildInputBar(),
          ],
        ),
      ),
    );
  }
}