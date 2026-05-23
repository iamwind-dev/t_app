import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/features/reels/presentation/cubits/reels_cubit.dart';
import 'package:t_app/features/reels/presentation/cubits/reels_state.dart';
import 'package:t_app/features/reels/presentation/widget/reel_overlay.dart';
import 'package:t_app/features/reels/presentation/widget/reel_video_player.dart';


class ReelsPage extends StatelessWidget {
  const ReelsPage({super.key, required this.bottomPadding});

  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final overlayBottomInset = (bottomPadding - 12).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocBuilder<ReelsCubit, ReelsState>(
        builder: (context, state) {
          if (state is ReelsLoading || state is ReelsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (state is ReelsError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (state is ReelsLoaded) {
            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: state.reels.length,
              itemBuilder: (context, index) {
                final reel = state.reels[index];

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ReelVideoPlayer(videoUrl: reel.videoUrl),
                    ReelOverlay(
                      reel: reel,
                      bottomInset: overlayBottomInset,
                      onLike: () {
                        context.read<ReelsCubit>().toggleLike(reel.id);
                      },
                    ),
                  ],
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}