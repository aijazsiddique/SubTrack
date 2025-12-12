import 'package:subtrack/src/features/transactions/domain/entities/parsed_transaction.dart'; // We will create this later
import 'package:flutter_riverpod/flutter_riverpod.dart';

final regexParserServiceProvider = Provider((ref) => RegexParserService());

class RegexParserService {
  // This will eventually be loaded from a more persistent source or configuration
  // For now, hardcoding some example patterns
  final List<Map<String, String>> _patterns = [
    {
      'bank': 'Chase',
      'pattern': r'Chase:\s*.*?\s*\$([\d\.]+)\s*at\s*([\w\s*]+)',
      'amountGroup': '1',
      'merchantGroup': '2',
    },
    {
      'bank': 'Amex',
      'pattern': r'(?i)Amex:.*?charged\s*\$([\d\.]+)\s*at\s*([\w\s]+)',
      'amountGroup': '1',
      'merchantGroup': '2',
    },
    {
      'bank': 'PayPal',
      'pattern': r'(?i)You\s+paid\s+\$([\d\.]+)\s+USD\s+to\s+([\w\s]+)',
      'amountGroup': '1',
      'merchantGroup': '2',
    },
    {
      'bank': 'Generic', // Catch-all generic pattern
      'pattern': r'(?i)(?:purchased|spent|charged|debit)\s*(?:USD|rs|inr|£|\$)?\s*([\d,]+\.\d{2})\s*(?:at|from|to)\s*([\w\s]+)',
      'amountGroup': '1',
      'merchantGroup': '2',
    },
  ];

  ParsedTransaction? parseNotification(String title, String text, String packageName) {
    String fullText = '$title $text';
    // Consider also using bigText if available

    for (final patternData in _patterns) {
      final regex = RegExp(patternData['pattern']!);
      final match = regex.firstMatch(fullText);

      if (match != null) {
        try {
          final amount = double.parse(match.group(int.parse(patternData['amountGroup']!))!.replaceAll(',', ''));
          final merchant = match.group(int.parse(patternData['merchantGroup']!))!.trim();
          
          return ParsedTransaction(
            source: 'Notification',
            packageName: packageName,
            amount: amount,
            merchant: merchant,
            date: DateTime.now(), // Approximate date, can be improved with date parsing
            originalText: fullText,
          );
        } catch (e) {
          print("Error parsing with regex pattern for ${patternData['bank']}: $e");
        }
      }
    }
    return null; // No match found
  }
}
