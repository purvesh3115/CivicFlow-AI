import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../navigation/app_routes.dart';
import '../../../providers/ai_assistant_provider.dart';

class AiVoiceAssistantScreen extends StatefulWidget {
  const AiVoiceAssistantScreen({super.key});

  @override
  State<AiVoiceAssistantScreen> createState() => _AiVoiceAssistantScreenState();
}

class _AiVoiceAssistantScreenState extends State<AiVoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  bool _isListening = true;
  final String _transcript = 'There is garbage near my house.';

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _toggleMic() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _waveController.repeat(reverse: true);
      } else {
        _waveController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded,
              color: AppColors.primary, size: 24),
          tooltip: 'Close',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CitizenConnect AI',
          style: AppTypography.headlineSmall.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

              // Animated 7-Bar Waveform
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  final t = _isListening ? _waveController.value : 0.2;
                  return SizedBox(
                    height: 90,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildWaveBar(16 + 20 * t),
                        _buildWaveBar(28 + 36 * (1 - t)),
                        _buildWaveBar(20 + 30 * t),
                        _buildWaveBar(36 + 48 * (1 - t)),
                        _buildWaveBar(24 + 32 * t),
                        _buildWaveBar(30 + 40 * (1 - t)),
                        _buildWaveBar(18 + 22 * t),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Status indicator
              Text(
                _isListening ? 'Listening...' : 'Paused',
                style: AppTypography.headlineMedium.copyWith(
                  color: _isListening
                      ? AppColors.aiAccent
                      : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 28),

              // Transcription Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.aiSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.aiBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'You said:',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"$_transcript"',
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineSmall.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Large Circular Ripple Mic Button
              GestureDetector(
                onTap: _toggleMic,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isListening)
                      AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return Container(
                            width: 110 + (_waveController.value * 20),
                            height: 110 + (_waveController.value * 20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.aiAccent
                                  .withAlpha((50 * (1 - _waveController.value)).toInt()),
                            ),
                          );
                        },
                      ),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? AppColors.aiAccent
                            : AppColors.outline,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.aiAccent.withAlpha(80),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic_rounded : Icons.mic_off_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isListening ? 'Tap mic to pause' : 'Tap mic to resume',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),

              const Spacer(flex: 1),

              // Action Buttons: EDIT and CONFIRM
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.aiAccent,
                        side: const BorderSide(
                            color: AppColors.aiAccent, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final provider = context.read<AiAssistantProvider>();
                        provider.sendMessage(_transcript);
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.aiChat);
                      },
                      child: const Text(
                        'EDIT',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        context
                            .read<AiAssistantProvider>()
                            .prefillComplaintAndNavigate(
                              context,
                              category: 'Garbage',
                              title: 'Garbage Dump Near Residence',
                              description:
                                  'Voice-recorded civic report: $_transcript',
                              priority: 'High',
                            );
                      },
                      child: const Text(
                        'CONFIRM',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaveBar(double height) {
    return Container(
      width: 6,
      height: height.clamp(12.0, 80.0),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: _isListening ? AppColors.aiAccent : AppColors.outlineVariant,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
