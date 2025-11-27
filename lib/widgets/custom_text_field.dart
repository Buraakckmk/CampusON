import 'package:flutter/material.dart';
import '../core/theme.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    Key? key,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.glassWhite : const Color(0xFFF1F5F9);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark
        ? Colors.white.withOpacity(0.5)
        : Colors.grey.withOpacity(0.7);
    final iconColor = isDark
        ? Colors.white.withOpacity(0.7)
        : Colors.grey.shade600;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        autocorrect: false,
        enableSuggestions: false,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: hintColor),
          prefixIcon: prefixIcon != null 
              ? Icon(prefixIcon, color: iconColor) 
              : null,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
