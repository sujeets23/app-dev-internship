import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_dating/core/theme/app_colors.dart';
import 'package:inclusive_dating/core/theme/app_typography.dart';
import '../../domain/models/chat_message.dart';
import '../providers/chat_provider.dart';
import 'incoming_call_screen.dart';
import 'outgoing_call_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String participantName;
  final String participantAvatar;
  final bool isVerified;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
    required this.participantAvatar,
    this.isVerified = false,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();

    ref.read(conversationMessagesProvider(widget.conversationId).notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(conversationMessagesProvider(widget.conversationId));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundImage: NetworkImage(widget.participantAvatar),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.participantName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (widget.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: AppColors.neonLime, size: 16),
                      ],
                    ],
                  ),
                  const Text(
                    'Online • End-to-end moderated',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.neonLime,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: AppColors.neonLime),
            tooltip: 'Mutual Consent Video Call',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.surfaceDark,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (ctx) => Material(
                  color: AppColors.surfaceDark,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.neonLime,
                            child: Icon(Icons.call_made_rounded, color: Colors.black),
                          ),
                          title: Text('Call ${widget.participantName}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: const Text('Start outgoing WebRTC call with mutual consent',
                              style: TextStyle(color: Colors.white60, fontSize: 12)),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OutgoingCallScreen(
                                  channelId: widget.conversationId,
                                  participantName: widget.participantName,
                                  participantAvatar: widget.participantAvatar,
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(color: Colors.white12),
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.softPink,
                            child: Icon(Icons.call_received_rounded, color: Colors.black),
                          ),
                          title: Text('Simulate Incoming Call from ${widget.participantName}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: const Text('Experience incoming ringing and accept screen',
                              style: TextStyle(color: Colors.white60, fontSize: 12)),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => IncomingCallScreen(
                                  callerName: widget.participantName,
                                  callerAvatar: widget.participantAvatar,
                                  channelId: widget.conversationId,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showChatOptionsSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Safety Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            color: AppColors.surfaceDark.withValues(alpha: 0.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield, color: AppColors.neonLime, size: 14),
                const SizedBox(width: 6),
                Text(
                  'AI Real-Time Safety & Toxic Content Shield Active',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMutedDark,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Messages View
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildMessageItem(msg);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.electricViolet),
              ),
              error: (err, _) => Center(
                child: Text('Error loading messages: $err', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.date_range_outlined, color: AppColors.softPink),
                    tooltip: 'Propose AI Date Plan',
                    onPressed: () {
                      _showQuickDatePlannerOffer(context);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(color: AppColors.textMutedDark),
                        filled: true,
                        fillColor: AppColors.backgroundDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.electricViolet,
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    final isMe = msg.isMe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isMe && !msg.isFlagged
                  ? const LinearGradient(
                      colors: [AppColors.electricViolet, Color(0xFF7032FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isMe
                  ? null
                  : (msg.isFlagged
                      ? Colors.red.withValues(alpha: 0.2)
                      : AppColors.cardBackgroundDark),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              border: msg.isFlagged
                  ? Border.all(color: Colors.redAccent.withValues(alpha: 0.5))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg.itinerarySnippet != null) ...[
                  _buildItineraryCard(msg.itinerarySnippet!),
                  const SizedBox(height: 8),
                ],
                Text(
                  msg.text,
                  style: TextStyle(
                    color: msg.isFlagged
                        ? Colors.red[200]
                        : (isMe ? Colors.white : Colors.white.withValues(alpha: 0.95)),
                    fontSize: 14,
                    height: 1.35,
                    fontStyle: msg.isFlagged ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: AppColors.textMutedDark,
                  fontSize: 10,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                Icon(
                  msg.status == MessageStatus.read
                      ? Icons.done_all
                      : (msg.status == MessageStatus.delivered ? Icons.done_all : Icons.done),
                  size: 13,
                  color: msg.status == MessageStatus.read ? AppColors.neonLime : AppColors.textMutedDark,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryCard(Map<String, dynamic> snippet) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.neonLime, size: 16),
              const SizedBox(width: 6),
              Text(
                snippet['title'] ?? 'AI Date Itinerary',
                style: const TextStyle(
                  color: AppColors.neonLime,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            snippet['summary'] ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Budget: ₹${snippet['budget'] ?? 1500}',
                style: const TextStyle(
                  color: AppColors.softPink,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Text(
                'Includes 10% Partner Voucher',
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQuickDatePlannerOffer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.neonLime),
                  const SizedBox(width: 8),
                  Text(
                    'Share AI Date Itinerary',
                    style: AppTypography.headlineMedium.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Share a curated, budget-friendly date plan directly into this chat.',
                style: TextStyle(color: AppColors.textMutedDark, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricViolet,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.read(conversationMessagesProvider(widget.conversationId).notifier).sendMessage(
                    'Hey, I generated this queer-friendly date plan for us on Date²! What do you think? ✨',
                    itinerarySnippet: {
                      'title': 'Bandra Cozy Sunset & Artisan Coffee',
                      'summary': 'Subko Specialty Coffee -> Bandra Seaside Walk -> Subko Bandra 10% Off',
                      'budget': '1200',
                    },
                  );
                },
                child: const Text('Send "Bandra Sunset Date" Plan'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChatOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Material(
        color: AppColors.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.shield_outlined, color: AppColors.neonLime),
              title: const Text('Safety & Verification Details', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile verified with Live Biometric Assurance.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.orangeAccent),
              title: const Text('Unmatch User', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem_outlined, color: Colors.redAccent),
              title: const Text('Report Safety Concern', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Incident reported to Trust & Safety team.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
