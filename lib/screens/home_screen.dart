import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspire_app/screens/favourite_quotes.dart';
import 'package:inspire_app/services/quote_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController _scrollController = ScrollController();
  bool showBtmAppbar = true;
  int _currentIndex = 0;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        showBtmAppbar = false;
        setState(() {});
      } else {
        showBtmAppbar = true;
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final quoteProvider = Provider.of<QuoteProvider>(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          quoteProvider.currentQuote.imageUrl.isNotEmpty
              ? Image.network(
                  quoteProvider.currentQuote.imageUrl,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  'assets/images/imagefree.jpg', // Replace with your actual asset path
                  fit: BoxFit.cover,
                ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        quoteProvider.currentQuote.text,
                        style: GoogleFonts.laila(
                            fontStyle: FontStyle.italic,
                            fontSize: 30,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '- ${quoteProvider.currentQuote.author}',
                        style: GoogleFonts.oswald(
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.transparent,
            onPressed: () => quoteProvider.fetchQuoteOfTheDay(),
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: Colors.transparent,
            onPressed: () async {
              final imageUrl = quoteProvider.currentQuote.imageUrl;
              final quoteText = quoteProvider.currentQuote.text;
              final author = quoteProvider.currentQuote.author;

              if (imageUrl != null) {
                // Download the background image
                final imageBytes = await http.readBytes(Uri.parse(imageUrl));

                // Create an Image from the background image
                final completer = Completer<ui.Image>();
                ui.decodeImageFromList(
                    Uint8List.fromList(imageBytes), completer.complete);

                final image = await completer.future;

                // creating a picture recorder
                final recorder = ui.PictureRecorder();
                final canvas = Canvas(recorder);

                // Drawing the background image
                canvas.drawImage(image, Offset.zero, Paint());

                // Create a Paint object for the background
                final backgroundPaint = Paint()
                  ..color = Colors.black
                      .withOpacity(0.7); // Adjust the opacity as needed

                // to draw on dark background
                canvas.drawRect(
                  Rect.fromPoints(
                    const Offset(0, 0),
                    Offset(image.width.toDouble(), image.height.toDouble()),
                  ),
                  backgroundPaint,
                );

                // for drawing quote text on to of the background
                final textPainter = TextPainter(
                  text: TextSpan(
                    text: '$quoteText\n- $author',
                    style: const TextStyle(color: Colors.white, fontSize: 60),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  textDirection: TextDirection.ltr,
                );

                // Layout and paint the text at the center
                textPainter.layout(maxWidth: image.width.toDouble());
                textPainter.paint(
                  canvas,
                  Offset(
                    (image.width.toDouble() - textPainter.width) / 2,
                    (image.height.toDouble() - textPainter.height) / 2,
                  ),
                );

                // for creating final image
                final compositeImage = await recorder.endRecording().toImage(
                      image.width.toInt(),
                      (image.height + textPainter.height).toInt(),
                    );

                final compositeBytes = await compositeImage.toByteData(
                    format: ui.ImageByteFormat.png);

                // for saving the composite image to file
                final tempDir = await getTemporaryDirectory();
                final tempFile = File('${tempDir.path}/quote_image.png');
                await tempFile
                    .writeAsBytes(compositeBytes!.buffer.asUint8List());

                // for sharing composite image
                Share.shareFiles(
                  [tempFile.path],
                  text: 'Check out this inspiring quote!',
                  subject: 'Inspiring Quote',
                );
              } else {
                // for sharing only text when there is no image
                Share.share(
                  '$quoteText\n- $author',
                  subject: 'Check out this inspiring quote!',
                );
              }
            },
            child: const Icon(
              Icons.share,
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: Colors.transparent,
            onPressed: () async {
              await quoteProvider.saveQuoteToFavorites();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quote saved to favorites!'),
                ),
              );
            },
            child: const Icon(
              Icons.favorite,
              color: Colors.red,
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedContainer(
        curve: Curves.easeInOutSine,
        duration: Duration(milliseconds: 800),
        height: showBtmAppbar ? 70 : 0,
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            // Navigate to the selected screen
            if (_currentIndex == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteQuotesScreen(),
                ),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              label: 'Favorites',
            ),
          ],
        ),
      ),
    );
  }
}
