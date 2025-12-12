import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtrack/src/features/transactions/domain/entities/parsed_transaction.dart';

final ocrParserServiceProvider = Provider((ref) => OcrParserService());

class OcrParserService {
  ParsedTransaction? parseOcrResult(List<String> ocrLines) {
    String fullText = ocrLines.join('\n');

    double? amount;
    String? merchant;
    DateTime? date;

    // --- Amount Detection ---
    // Look for currency symbols followed by numbers
    final amountRegex = RegExp(r'\$?(\d{1,3}(?:,\d{3})*(?:\.\d{2}))');
    final allAmounts = amountRegex.allMatches(fullText).map((m) => double.tryParse(m.group(1)!.replaceAll(',', ''))).whereType<double>().toList();

    // Prioritize the largest numerical value in the bottom half of the document
    if (allAmounts.isNotEmpty) {
      // Simple heuristic: Take the largest amount found
      amount = allAmounts.reduce((a, b) => a > b ? a : b);
    }

    // --- Date Detection ---
    final dateRegex = RegExp(r'\b(\d{1,2}[-/.]\d{1,2}[-/.]\d{2,4}|\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{1,2},\s+\d{4}|\d{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{4})\b', caseSensitive: false);
    final dateMatch = dateRegex.firstMatch(fullText);
    if (dateMatch != null) {
      try {
        date = DateTime.parse(dateMatch.group(0)!);
      } catch (_) {
        // Fallback for different date formats, more robust parsing needed here
      }
    }
    // Default to now if no date found
    date ??= DateTime.now();

    // --- Merchant Identification ---
    // This part requires a list of known merchants or more advanced NLP
    // For now, a very basic heuristic: look for common subscription names or
    // take a prominent text near the top.
    final knownMerchants = ['Netflix', 'Spotify', 'Adobe', 'Amazon', 'Google'];
    for (var known in knownMerchants) {
      if (fullText.contains(known)) {
        merchant = known;
        break;
      }
    }

    // Fallback: If no known merchant, try to extract something from the top lines
    if (merchant == null && ocrLines.isNotEmpty) {
      merchant = ocrLines.first.trim().isNotEmpty ? ocrLines.first.trim() : 'Unknown Merchant';
    }


    if (amount != null && merchant != null && date != null) {
      return ParsedTransaction(
        source: 'OCR',
        amount: amount,
        merchant: merchant,
        date: date,
        originalText: fullText,
      );
    }

    return null; // Could not parse
  }
}
