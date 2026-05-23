import 'package:flutter/material.dart';

class RegisterDateField extends StatelessWidget {
  final DateTime? value;
  final VoidCallback onTap;

  const RegisterDateField({
    super.key,
    required this.value,
    required this.onTap,
  });

  String get dateText {
    if (value == null) return 'Ngày sinh';

    final day = value!.day.toString().padLeft(2, '0');
    final month = value!.month.toString().padLeft(2, '0');
    final year = value!.year.toString();

    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final fillColor = isDark ? Colors.black : colorScheme.surface;
    final borderColor = isDark ? const Color(0xFF262626) : colorScheme.outline;

    return FormField<DateTime>(
      validator: (_) {
        if (value == null) return 'Vui lòng chọn ngày sinh';
        return null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: state.hasError
                        ? Colors.redAccent
                        : borderColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dateText,
                        style: TextStyle(
                          color: value == null
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            if (state.hasError) ...[
              const SizedBox(height: 6),
              Text(
                state.errorText!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
