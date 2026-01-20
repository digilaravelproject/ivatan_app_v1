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
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.grey),
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
                        Colors.transparent,
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
  final bool showLabel;
  final bool isObscure;
  final GestureTapCallback? onEndIconTap;
  final TextEditingController? controller;
  final List<String>? hint;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  final bool readOnly;       // for DOB calendar
  final VoidCallback? onTap;

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

      style: const TextStyle(color: Colors.black, fontSize: 15),

      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: _isFocused ? Colors.blue : Colors.grey,
          fontWeight: FontWeight.w600,
        ),

        hintText: widget.hintText,

        prefixIcon: widget.iconData == null
            ? null
            : Icon(widget.iconData, size: 20, color: Colors.grey),

        suffixIcon: widget.endIcon == null
            ? null
            : IconButton(
          onPressed: widget.onEndIconTap,
          icon: Icon(widget.endIcon, color: Colors.grey),
        ),

        // 🔥 Box हट गया, border हट गया
        filled: false,

        // 🔥 केवल underline (grey + blue on focus)
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 1.5),
        ),

        contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
          color: _isFocused ? Colors.blue : Colors.grey,
          fontSize: 14,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      ),
      style: const TextStyle(color: Colors.black, fontSize: 15),
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

      style: const TextStyle(color: Colors.black, fontSize: 15),

      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: _isFocused ? Colors.blue : Colors.grey,
          fontWeight: FontWeight.w600,
        ),

        hintText: widget.hintText,

        prefixIcon: widget.iconData == null
            ? null
            : Icon(widget.iconData, size: 20, color: Colors.grey),

        suffixIcon: widget.endIcon == null
            ? null
            : IconButton(
          onPressed: widget.onEndIconTap,
          icon: Icon(widget.endIcon, color: Colors.grey),
        ),

        filled: false,

        // 🔥 SAME BORDER ON BOTH STATES
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),

        // 🔥 ALSO ADDING default border to avoid Flutter override issues
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),

        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),

    );
  }
}
