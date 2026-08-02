import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circular_icon_button.dart';
import '../../domain/entities/coach_entities.dart';
import '../../domain/repositories/coach_repository.dart';

class AiChatThreadScreen extends StatefulWidget {
  const AiChatThreadScreen({super.key});

  @override
  State<AiChatThreadScreen> createState() => _AiChatThreadScreenState();
}

class _AiChatThreadScreenState extends State<AiChatThreadScreen> {
  AiChatThread? _thread;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CoachRepository>().getThread().then((v) {
      if (mounted) setState(() => _thread = v);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _botAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.primarySoft,
      backgroundImage: const AssetImage(AppAssets.aiRobot),
    );
  }

  @override
  Widget build(BuildContext context) {
    final thread = _thread;
    if (thread == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ResponsiveConstrained(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    CircularIconButton(
                      icon: Icons.arrow_back,
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 10),
                    _botAvatar(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            thread.botName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                thread.status,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    CircularIconButton(
                      icon: Icons.more_horiz,
                      onPressed: () => context.pushNamed(RouteNames.aiChats),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    Center(
                      child: Text(
                        thread.timestamp,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...thread.messages.map((m) {
                      switch (m.kind) {
                        case ChatBubbleKind.bot:
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _botAvatar(),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F4F7),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(m.text),
                                  ),
                                ),
                              ],
                            ),
                          );
                        case ChatBubbleKind.userSuggestion:
                          return Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: m.selected
                                    ? AppColors.primary
                                    : const Color(0xFFF0F7FF),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: const Radius.circular(18),
                                  bottomRight: Radius.circular(
                                    m.selected ? 4 : 18,
                                  ),
                                ),
                              ),
                              child: Text(
                                m.text,
                                style: TextStyle(
                                  color: m.selected
                                      ? AppColors.white
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        case ChatBubbleKind.botCard:
                          return Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _botAvatar(),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEAF3FF),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m.cardTitle ?? '',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          m.cardSubtitle ?? '',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 8,
                                          children: (m.tags ?? [])
                                              .map(
                                                (t) => Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      14,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        t == 'Gym'
                                                            ? Icons
                                                                .fitness_center
                                                            : t == 'SPA'
                                                                ? Icons.spa
                                                                : Icons.pool,
                                                        size: 14,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        t,
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors.primary,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                      }
                    }),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, bottom + 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: const InputDecoration(
                                  hintText: 'Type a message...',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.mic_none,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.charcoal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
