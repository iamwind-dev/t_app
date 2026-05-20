import 'package:flutter/material.dart';

import '../widget/outline_button.dart';
import '../widget/primary_button.dart';

class AddProfilePhotoScreen extends StatelessWidget {
  const AddProfilePhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 36,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  icon: Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Thêm ảnh đại diện',
                style: TextStyle(
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Hãy thêm ảnh đại diện để bạn bè nhận ra bạn. Mọi người có thể nhìn thấy ảnh của bạn.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 46),
              Center(
                child: Container(
                  width: 165,
                  height: 165,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    color: colorScheme.onSurfaceVariant,
                    size: 112,
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Thêm ảnh',
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              OutlineButton(
                text: 'Bỏ qua',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
