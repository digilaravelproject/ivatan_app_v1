class DateHelper {
  static String formatPostDate(String dateString) {
    if (dateString.isEmpty) return "";
    
    try {
      final DateTime date = DateTime.parse(dateString);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(date);

      if (difference.inDays < 7) {
        if (difference.inSeconds < 60) {
          return "Just now";
        } else if (difference.inMinutes < 60) {
          return "${difference.inMinutes}m ago";
        } else if (difference.inHours < 24) {
          return "${difference.inHours}h ago";
        } else {
          return "${difference.inDays}d ago";
        }
      } else {
        // Format as "dd MMM yyyy" e.g., "12 Oct 2023"
        // Since we don't assume intl package, manual formatting:
        const List<String> months = [
          "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
        ];
        return "${date.day} ${months[date.month - 1]} ${date.year}";
      }
    } catch (e) {
      return dateString;
    }
  }
}
