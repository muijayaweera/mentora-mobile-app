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
      if (!mounted || !_scrollController.hasClients) return;

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
      backgroundColor: surfaceLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.68,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Previous Chats",
                      style: GoogleFonts.poppins(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: _startNewChat,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: StreamBuilder(
                    stream: _historyService.getChats(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFA822D9),
                          ),
                        );
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
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: bgLight,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: borderLight),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              leading: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4E8FA),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: Color(0xFFA822D9),
                                  size: 19,
                                ),
                              ),
                              title: Text(
                                data["title"] ?? "Untitled Chat",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: buttonGradient,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA822D9).withOpacity(0.22),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: const Icon(
          Icons.menu_rounded,
          color: Colors.white,
          size: 23,
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: SizedBox(
        height: 48,
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
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantBadge() {
    return Container(
      height: 104,
      width: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFDF2FF), Color(0xFFF3E7FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA822D9).withOpacity(0.16),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE8D4F5),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Container(
          height: 58,
          width: 58,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE5D3F4),
              width: 1.2,
            ),
          ),
          child: const Icon(
            Icons.favorite_border_rounded,
            color: Color(0xFFA822D9),
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
      child: Column(
        children: [
          const Spacer(),

          _buildAssistantBadge(),

          const SizedBox(height: 28),

          Text(
            "Ask Mentora",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: textDark,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 10),

          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.poppins(
                color: subTextLight,
                fontSize: 14.5,
                height: 1.55,
                fontWeight: FontWeight.w400,
              ),
              children: [
                const TextSpan(text: "Your ostomy care assistant for "),
                TextSpan(
                  text: "training, pouching, complications, ",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFA822D9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: "and patient education."),
              ],
            ),
          ),

          const SizedBox(height: 26),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: const [
              _SuggestionChip(text: "Stoma care basics"),
              _SuggestionChip(text: "Skin irritation"),
              _SuggestionChip(text: "Pouch leakage"),
            ],
          ),

          const Spacer(),

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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        constraints: const BoxConstraints(maxWidth: 290),
        decoration: BoxDecoration(
          gradient: isUser ? buttonGradient : null,
          color: isUser ? null : surfaceLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 5),
            bottomRight: Radius.circular(isUser ? 5 : 18),
          ),
          border: isUser ? null : Border.all(color: borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 9,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: GoogleFonts.poppins(
            color: isUser ? Colors.white : textDark,
            fontSize: 13.3,
            height: 1.42,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderLight),
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
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 12),
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
        height: 54,
        padding: const EdgeInsets.only(left: 18, right: 6),
        decoration: BoxDecoration(
          color: surfaceLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.055),
              blurRadius: 16,
              offset: const Offset(0, 7),
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
                  hintText: "Ask about ostomy care...",
                  hintStyle: GoogleFonts.poppins(
                    color: subTextLight.withOpacity(0.72),
                    fontSize: 13.5,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            GestureDetector(
              onTap: _isLoading ? null : _sendMessage,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: _isLoading ? null : buttonGradient,
                  color: _isLoading ? Colors.grey.shade400 : null,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    if (!_isLoading)
                      BoxShadow(
                        color: const Color(0xFFA822D9).withOpacity(0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 22,
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

class _SuggestionChip extends StatelessWidget {
  final String text;

  const _SuggestionChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4E8FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8D4F5)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: const Color(0xFFA822D9),
          fontSize: 11.8,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}