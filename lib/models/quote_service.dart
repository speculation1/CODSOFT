import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:inspire_app/models/quote.dart';

class QuoteService {
  static const String apiUrl = 'https://api.quotable.io/random';
  static const String unsplashApiKey =
      'bkthYaBe6oEb2wxOJpOVLwtzVwD46r3RnBAz_YtQKFY'; // Replace with your Unsplash API key

  Future<Quote> fetchRandomQuote() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Fetch a random image from Unsplash
        final imageUrl = await _fetchRandomImage();

        return Quote(
          text: data['content'] ?? '',
          author: data['author'] ?? '',
          imageUrl: imageUrl.isNotEmpty ? imageUrl : 'URL_TO_PLACEHOLDER_IMAGE',
        );
      } else {
        print('Failed to load quote: ${response.statusCode}');
        return Quote(text: 'Failed to load quote', author: '', imageUrl: '');
      }
    } catch (error) {
      print('Error fetching quote: $error');
      return Quote(text: 'Error fetching quote', author: '', imageUrl: '');
    }
  }

  Future<String> _fetchRandomImage() async {
    try {
      final unsplashUrl =
          'https://api.unsplash.com/photos/random?query=inspiration&client_id=$unsplashApiKey';

      final unsplashResponse = await http.get(Uri.parse(unsplashUrl));

      if (unsplashResponse.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(unsplashResponse.body);

        // Ensure 'urls' and 'regular' keys exist in the response
        final imageUrl =
            data.containsKey('urls') ? data['urls']['regular'] ?? '' : '';
        return imageUrl;
      } else {
        print('Failed to load image: ${unsplashResponse.statusCode}');
        return '';
      }
    } catch (error) {
      print('Error fetching image: $error');
      return '';
    }
  }
}
