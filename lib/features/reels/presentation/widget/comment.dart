import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_app/features/reels/presentation/cubits/comments/comments_cubit.dart';
import 'package:t_app/features/reels/presentation/cubits/comments/comments_state.dart';

class CommentsSection extends StatelessWidget {
  CommentsSection({super.key});

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<CommentsCubit, CommentsState>(
            builder: (context, state) {
              if (state is CommentsLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is CommentsLoaded) {
                if (state.comments.isEmpty) {
                  return const Center(
                    child: Text("Chưa có bình luận"),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: state.comments.length,
                  itemBuilder: (_, index) {
                    final comment = state.comments[index];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(comment),
                    );
                  },
                );
              }

              return const SizedBox();
            },
          ),
        ),

        Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Nhập bình luận...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              IconButton(
                onPressed: () {
                  if (controller.text.trim().isEmpty) return;

                  context
                      .read<CommentsCubit>()
                      .addComment(controller.text);

                  controller.clear();
                },
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}