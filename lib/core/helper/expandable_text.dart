import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

class ExpandableCaption extends StatefulWidget {
  final String text;

  const ExpandableCaption({super.key, required this.text});

  @override
  State<ExpandableCaption> createState() => _ExpandableCaptionState();
}

class _ExpandableCaptionState extends State<ExpandableCaption> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // TextStyle
    const textStyle = TextStyle(
      fontSize: 14,
      height: 1.4,
      color: AppColors.white,
    );

    // Check if text is long enough to show "more"
    final span = TextSpan(text: widget.text, style: textStyle);
    final tp = TextPainter(
      text: span,
      maxLines: 2,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: MediaQuery.of(context).size.width - 32); // padding ke liye adjust
    final isOverflow = tp.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: textStyle,
          maxLines: _isExpanded ? null : 2,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (isOverflow) // Show "More/Less" only if text is long
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                _isExpanded ? "Less" : "More",
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
