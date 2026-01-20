import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ExpandableCaption extends StatefulWidget {
  final String text;
  final String username;

  const ExpandableCaption({
    Key? key,
    required this.text,
    this.username = "",
  }) : super(key: key);

  @override
  State<ExpandableCaption> createState() => _ExpandableCaptionState();
}

class _ExpandableCaptionState extends State<ExpandableCaption> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Base styles
    const styleUsername = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
    const styleCaption = TextStyle(
      fontSize: 14,
      color: Colors.black87,
      height: 1.3,
    );
    const styleLink = TextStyle(
      fontSize: 14,
      color: Color(0xFF00376B), // Instagram Blue
    );
    const styleMore = TextStyle(
       fontSize: 14,
       color: Colors.grey,
    );

    // Build the full text span with Username + Caption (Parsing hashtags)
    final List<TextSpan> fullSpans = [];
    
    // 1. Username
    if (widget.username.isNotEmpty) {
      fullSpans.add(TextSpan(text: "${widget.username} ", style: styleUsername));
    }

    // 2. Caption Parsing
    widget.text.split(' ').forEach((word) {
      if (word.startsWith('#') || word.startsWith('@')) {
        fullSpans.add(TextSpan(text: "$word ", style: styleLink));
      } else {
        fullSpans.add(TextSpan(text: "$word ", style: styleCaption));
      }
    });

    final TextSpan fullContent = TextSpan(children: fullSpans, style: styleCaption);

    // Check layout overflow
    final textPainter = TextPainter(
      text: fullContent,
      maxLines: 2,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);
    
    final bool isOverflow = textPainter.didExceedMaxLines;

    if (!isOverflow) {
      // Short text: Show everything
      return RichText(text: fullContent);
    }

    if (_isExpanded) {
      // Expanded: Show full text + " less"
      return RichText(
        text: TextSpan(
          children: [
            ...fullSpans,
            TextSpan(
               text: " less", // Added space for safety
               style: styleMore,
               recognizer: TapGestureRecognizer()
                 ..onTap = () => setState(() => _isExpanded = false),
            ),
          ],
        ),
      );
    } else {
      // Collapsed: Show truncated text (approx) + "... more"
      // Since calculating exact truncation index on RichText is complex, 
      // we'll use a simpler approach: Render MaxLines: 2 with Overflow.ellipsis 
      // AND a "more" button below or inline if possible. 
      // For simplicity in this iteration: Standard Column approach.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
             fullContent,
             maxLines: 2,
             overflow: TextOverflow.ellipsis,
          ),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = true),
            child: const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "more",
                style: styleMore,
              ),
            ),
          ),
        ],
      );
    }
  }
}
