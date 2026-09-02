import 'package:i_vatan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';

/*class AuthInputFields extends StatelessWidget {
  final String? label;
  final TextInputType textInputType;
  final IconData? iconData;
  final IconData? endIcon;
  final bool showLabel;
  final bool isObscure;
  final GestureTapCallback? onEndIconTap;
  final TextEditingController? controller;
  final List<String>? hint;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AuthInputFields({
    super.key,
    this.label,
    this.iconData,
    this.controller,
    this.endIcon,
    this.hint,
    this.onEndIconTap,
    this.validator,
    this.onChanged,
    this.hintText,
    this.showLabel = true,
    this.isObscure = false,
    this.textInputType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (showLabel && label != null && label!.isNotEmpty)
          Text(
            label!.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ).marginSymmetric(horizontal: 4),
        TextFormField(
          autofillHints: hint,
          controller: controller,
          obscureText: isObscure,
          obscuringCharacter: "*",
          onTapOutside: (event) => FocusScope.of(context).unfocus(),
          keyboardType: textInputType,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.premiumGold),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.premiumGold),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primaryLight),
            ),
            suffixIcon: endIcon == null
                ? null
                : IconButton(
                    onPressed: onEndIconTap,
                    icon: Icon(endIcon),
                    style: Theme.of(context).iconButtonTheme.style?.copyWith(
                      side: const WidgetStatePropertyAll(BorderSide.none),
                      backgroundColor: const WidgetStatePropertyAll(
                        AppColors.transparent,
                      ),
                    ),
                  ).marginOnly(right: 8),
            prefixIcon: iconData == null
                ? null
                : Icon(iconData, size: 20).marginOnly(left: 12),
          ),
        ),
      ],
    );
  }
}*/

class AuthInputFields extends StatefulWidget {
  final String? label;
  final TextInputType textInputType;
  final IconData? iconData;
  final IconData? endIcon;
  final Widget? suffixIcon; // Added generic suffix widget
  final bool showLabel;
  final bool isObscure;
  final GestureTapCallback? onEndIconTap;
  final TextEditingController? controller;
  final List<String>? hint;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  final bool readOnly; // for DOB calendar
  final VoidCallback? onTap;

  const AuthInputFields({
    super.key,
    this.label,
    this.iconData,
    this.controller,
    this.endIcon,
    this.suffixIcon,
    this.hint,
    this.onEndIconTap,
    this.validator,
    this.onChanged,
    this.hintText,
    this.showLabel = true,
    this.isObscure = false,
    this.textInputType = TextInputType.text,

    this.readOnly = false,
    this.onTap,
  });

  @override
  State<AuthInputFields> createState() => _AuthInputFieldsState();
}

class _AuthInputFieldsState extends State<AuthInputFields> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: _focusNode,
      controller: widget.controller,
      autofillHints: widget.hint,
      obscureText: widget.isObscure,
      obscuringCharacter: "*",
      keyboardType: widget.textInputType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validator,
      onChanged: widget.onChanged,

      readOnly: widget.readOnly,
      onTap: widget.onTap,

      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: widget.readOnly ? AppColors.premiumGold : AppColors.white,
      ),

      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: AppColors.premiumGold,
          fontWeight: FontWeight.w500,
        ),

        hintText: widget.hintText,
        hintStyle: TextStyle(fontSize: 14, color: AppColors.premiumGold),

        prefixIcon:
            widget.iconData == null
                ? null
                : Icon(widget.iconData, size: 20, color: AppColors.primary),

        // Prefer suffixIcon widget, else fallback to endIcon button
        suffixIcon:
            widget.suffixIcon ??
            (widget.endIcon == null
                ? null
                : IconButton(
                  onPressed: widget.onEndIconTap,
                  icon: Icon(widget.endIcon, size: 20),
                  color: AppColors.primary,
                )),

        // Premium rounded borders with fill
        filled: true,
        fillColor:
            widget.readOnly
                ? AppColors.premiumGold.withOpacity(0.1)
                : AppColors.transparent,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.premiumGold),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.premiumGold),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.premiumGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.premiumGold),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String labelText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Icon? suffixIcon;
  final bool obscureText;

  const CustomTextField({
    Key? key,
    required this.labelText,
    this.controller,
    this.keyboardType,
    this.suffixIcon,
    this.obscureText = false,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _focusNode,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      cursorColor: Colors.blue,
      decoration: InputDecoration(
        suffixIcon: widget.suffixIcon,
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: _isFocused ? AppColors.premiumGold : AppColors.premiumGold,
          fontSize: 14,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.premiumGold, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.premiumGold, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.transparent,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      ),
      style: const TextStyle(color: AppColors.white, fontSize: 15),
    );
  }
}

class AuthInputFieldsBorder extends StatefulWidget {
  final String? label;
  final TextInputType textInputType;
  final IconData? iconData;
  final IconData? endIcon;
  final bool showLabel;
  final bool isObscure;
  final GestureTapCallback? onEndIconTap;
  final TextEditingController? controller;
  final List<String>? hint;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  final bool readOnly;
  final VoidCallback? onTap;

  const AuthInputFieldsBorder({
    super.key,
    this.label,
    this.iconData,
    this.controller,
    this.endIcon,
    this.hint,
    this.onEndIconTap,
    this.validator,
    this.onChanged,
    this.hintText,
    this.showLabel = true,
    this.isObscure = false,
    this.textInputType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<AuthInputFieldsBorder> createState() => _AuthInputFieldsBorderState();
}

class _AuthInputFieldsBorderState extends State<AuthInputFieldsBorder> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: _focusNode,
      controller: widget.controller,
      autofillHints: widget.hint,
      obscureText: widget.isObscure,
      obscuringCharacter: "*",
      keyboardType: widget.textInputType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: widget.validator,
      onChanged: widget.onChanged,

      readOnly: widget.readOnly,
      onTap: widget.onTap,

      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: widget.readOnly ? AppColors.premiumGold : AppColors.white,
      ),

      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: AppColors.premiumGold,
          fontWeight: FontWeight.w500,
        ),

        hintText: widget.hintText,
        hintStyle: TextStyle(fontSize: 14, color: AppColors.premiumGold),

        prefixIcon:
            widget.iconData == null
                ? null
                : Icon(widget.iconData, size: 20, color: AppColors.primary),

        suffixIcon:
            widget.endIcon == null
                ? null
                : IconButton(
                  onPressed: widget.onEndIconTap,
                  icon: Icon(widget.endIcon, size: 20),
                  color: AppColors.primary,
                ),

        // Premium rounded borders with fill
        filled: true,
        fillColor:
            widget.readOnly
                ? AppColors.premiumGold.withOpacity(0.1)
                : AppColors.transparent,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.premiumGold),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.premiumGold),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.premiumGold),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }
}
