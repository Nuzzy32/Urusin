import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models.dart';
import '../../theme.dart';
import '../../widgets.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;
  final bool isSystem;

  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.isSystem = false,
  });
}

class ChatScreen extends StatefulWidget {
  final void Function(String, [Map<String, dynamic>?]) go;
  final FlowState state;

  const ChatScreen({super.key, required this.go, required this.state});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _sending = false;
  String? _roomId;
  String? _myUserId;
  RealtimeChannel? _channel;

  Worker get _worker => kWorkers.firstWhere(
        (w) => w.id == widget.state.workerId,
        orElse: () => kWorkers.first,
      );

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    final problem = widget.state.selectedProblem.isNotEmpty
        ? widget.state.selectedProblem
        : 'masalah di rumah';
    _messages.add(ChatMessage(
      text: 'Booking dikirim ke ${_worker.name}',
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      isSystem: true,
    ));

    final client = _client;
    final bookingId = widget.state.activeBookingId;
    final authId = client?.auth.currentUser?.id;

    if (client != null && bookingId.isNotEmpty && authId != null) {
      try {
        final userRow = await client
            .from('users')
            .select('user_id')
            .eq('auth_user_id', authId)
            .maybeSingle();
        _myUserId = userRow?['user_id'] as String?;

        final room = await client
            .from('chat_rooms')
            .upsert({'booking_id': bookingId}, onConflict: 'booking_id')
            .select('room_id')
            .single();
        _roomId = room['room_id'] as String;

        final rows = await client
            .from('chat_messages')
            .select('message_id, sender_id, message_text, created_at')
            .eq('room_id', _roomId!)
            .order('created_at');
        for (final r in rows as List) {
          final m = r as Map<String, dynamic>;
          _messages.add(_rowToMessage(m));
        }

        _channel = client
            .channel('chat:${_roomId!}')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'chat_messages',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'room_id',
                value: _roomId!,
              ),
              callback: (payload) {
                if (!mounted) return;
                setState(() => _messages.add(_rowToMessage(payload.newRecord)));
                Future.delayed(const Duration(milliseconds: 60), _scrollBottom);
              },
            )
            .subscribe();
      } catch (_) {
        // Realtime tidak tersedia → fallback offline chat
      }
    }

    if (_messages.length == 1) {
      _messages.add(ChatMessage(
        text:
            'Halo! Saya sudah terima ringkasan masalah kamu — $problem. Saya bisa datang hari ini jam 14.00, apakah bisa?',
        isMe: false,
        time: DateTime.now().subtract(const Duration(minutes: 4)),
      ));
    }

    if (mounted) setState(() {});
  }

  ChatMessage _rowToMessage(Map<String, dynamic> row) {
    final senderId = row['sender_id'] as String?;
    return ChatMessage(
      text: (row['message_text'] as String?) ?? '',
      isMe: _myUserId != null && senderId == _myUserId,
      time: DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;
    _input.clear();
    setState(() => _sending = true);

    final client = _client;
    final roomId = _roomId;
    final senderId = _myUserId;
    if (client != null && roomId != null && senderId != null) {
      try {
        await client.from('chat_messages').insert({
          'room_id': roomId,
          'sender_id': senderId,
          'message_text': text,
        });
      } catch (_) {
        // Append lokal supaya pesan user tetap terlihat
        if (mounted) {
          setState(() => _messages.add(
                ChatMessage(text: text, isMe: true, time: DateTime.now()),
              ));
        }
      }
    } else {
      // Offline / belum login: simulasi lokal
      if (mounted) {
        setState(() => _messages.add(
              ChatMessage(text: text, isMe: true, time: DateTime.now()),
            ));
      }
    }
    if (mounted) setState(() => _sending = false);
    Future.delayed(const Duration(milliseconds: 60), _scrollBottom);
  }

  void _scrollBottom() {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final worker = _worker;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _ChatHeader(worker: worker, onBack: () => widget.go('bookingStatus')),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: _messages.length + (_sending ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) return _TypingBubble(name: worker.name);
                return _MessageBubble(msg: _messages[i], workerName: worker.name);
              },
            ),
          ),
          _ChatInputBar(
            controller: _input,
            onSend: _send,
            bottomPadding: bottom,
          ),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final Worker worker;
  final VoidCallback onBack;

  const _ChatHeader({required this.worker, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: top + 8, bottom: 12, left: 8, right: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: AppColors.ink,
            onPressed: onBack,
          ),
          Avatar(name: worker.name, size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worker.name,
                  style: pj(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Online · ${worker.service}',
                      style: pj(fontSize: 11.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user_outlined,
                    size: 13, color: AppColors.primaryDark),
                const SizedBox(width: 4),
                Text(
                  'Terverifikasi',
                  style: pj(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final String workerName;

  const _MessageBubble({required this.msg, required this.workerName});

  @override
  Widget build(BuildContext context) {
    if (msg.isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.line2,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              msg.text,
              style: pj(fontSize: 11, color: AppColors.muted),
            ),
          ),
        ),
      );
    }

    final isMe = msg.isMe;
    final timeStr =
        '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.only(
        bottom: 8,
        left: isMe ? 48 : 0,
        right: isMe ? 0 : 48,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 3),
              child: Text(
                workerName,
                style: pj(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              msg.text,
              style: pj(
                fontSize: 13.5,
                color: isMe ? Colors.white : AppColors.ink,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              timeStr,
              style: pj(fontSize: 10.5, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  final String name;
  const _TypingBubble({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 3),
            child: Text(
              name,
              style: pj(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.muted.withValues(alpha: .5),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final double bottomPadding;

  const _ChatInputBar({
    required this.controller,
    required this.onSend,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(12, 10, 12, bottomPadding + 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.line),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                style: pj(fontSize: 14, color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  hintStyle: pj(fontSize: 14, color: AppColors.muted),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
