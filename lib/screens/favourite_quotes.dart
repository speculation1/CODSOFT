import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspire_app/services/quote_provider.dart';
import 'package:provider/provider.dart';

class FavoriteQuotesScreen extends StatefulWidget {
  const FavoriteQuotesScreen({super.key});

  @override
  State<FavoriteQuotesScreen> createState() => _FavoriteQuotesScreenState();
}

class _FavoriteQuotesScreenState extends State<FavoriteQuotesScreen> {
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
      body: SafeArea(
        child: Expanded(
          child: Stack(
            children: [
              const Positioned.fill(
                  child: Image(
                image: AssetImage('assets/images/backgroung quize.jpg'),
                fit: BoxFit.cover,
              )),
              Column(
                children: [
                  Text(
                    'Favourite Quotes',
                    style: GoogleFonts.aBeeZee(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: quoteProvider.getFavoriteQuotes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error loading favorite quotes'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No favorite quotes yet'));
                        } else {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final quote = snapshot.data![index];
                              return ListTile(
                                title: Text(quote['text']),
                                subtitle: Text('- ${quote['author']}'),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            // Navigate to the selected screen
            if (_currentIndex == 0) {
              // Navigate back to the home screen
              Navigator.pop(context);
            } else if (_currentIndex == 1) {
              // Navigate to the favorites screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoriteQuotesScreen(),
                ),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
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
