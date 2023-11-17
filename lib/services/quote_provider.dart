import 'package:flutter/foundation.dart';
import 'package:inspire_app/models/quote.dart';
import 'package:inspire_app/models/quote_service.dart';

import 'package:inspire_app/services/quote_database.dart';

class QuoteProvider with ChangeNotifier {
  Quote _currentQuote = Quote(text: 'Loading...', author: '', imageUrl: '');

  Quote get currentQuote => _currentQuote;

  final QuoteService _quoteService = QuoteService();
  final QuoteDatabase _quoteDatabase = QuoteDatabase();

  Future<void> fetchQuoteOfTheDay() async {
    final quote = await _quoteService.fetchRandomQuote();
    _currentQuote = quote;
    notifyListeners();
  }

  Future<void> saveQuoteToFavorites() async {
    await _quoteDatabase.insertQuote({
      'text': _currentQuote.text,
      'author': _currentQuote.author,
    });
  }

  Future<List<Map<String, dynamic>>> getFavoriteQuotes() async {
    return await _quoteDatabase.getQuotes();
  }
}
