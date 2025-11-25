import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _wordInputController = TextEditingController();
  String _selectedLanguage = 'en';
  String _result = 'Search anything or use voice/camera features.';
  bool _isLoading = false;
  List<String> _imageUrls = [];

  final Map<String, String> _languages = {
    'en': 'English',
    'hi': 'Hindi',
    'ta': 'Tamil',
    'te': 'Telugu',
    'kn': 'Kannada',
    'ml': 'Malayalam',
    'mr': 'Marathi',
    'bn': 'Bengali',
    'gu': 'Gujarati',
    'pa': 'Punjabi',
    'or': 'Odia',
    'as': 'Assamese',
    'sd': 'Sindhi',
    'ur': 'Urdu',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'ja': 'Japanese',
    'it': 'Italian',
    'ru': 'Russian',
    'ar': 'Arabic',
    'pt': 'Portuguese',
    'zh': 'Chinese',
    'ko': 'Korean',
    'tr': 'Turkish',
  };

  Future<void> _searchWord() async {
    final String word = _wordInputController.text.trim();
    if (word.isEmpty) {
      setState(() {
        _result = 'Enter a word or topic to search.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '⏳ Searching...';
      _imageUrls = [];
    });

    if (word.toLowerCase() == 'maanvith') {
      setState(() {
        _result = '''
        <h2>Maanvith Sai — Creator & Programmer</h2>
        <p><b>Role:</b> Developer & Creator</p>
        <p><b>Skills:</b> Full-stack, JavaScript, Web, AI Tools</p>
        <p>Designed and programmed entirely by <b>Maanvith Sai</b>.</p>
        ''';
        _imageUrls = ['https://i.imgur.com/6XH8VxL.jpeg'];
        _isLoading = false;
      });
      return;
    }

    String? definition;
    String? example;
    List<String> synonyms = [];
    String entryWord = word;

    // Dictionary API
    try {
      final response = await http.get(Uri.parse(
          'https://api.dictionaryapi.dev/api/v2/entries/en/$word'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)[0];
        entryWord = data['word'];
        final meaning = data['meanings'][0];
        final definitionData = meaning['definitions'][0];
        definition = definitionData['definition'];
        example = definitionData['example'];
        synonyms = List<String>.from(definitionData['synonyms'] ?? []);
      }
    } catch (e) {
      // print(e);
    }

    // Wikipedia API
    if (definition == null) {
      try {
        final response = await http.get(Uri.parse(
            'https://en.wikipedia.org/api/rest_v1/page/summary/$word'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          definition = data['extract'];
          example = data['description'];
          entryWord = data['title'];
          if (data['originalimage'] != null) {
            _imageUrls.add(data['originalimage']['source']);
          }
        }
      } catch (e) {
        // print(e);
      }
    }

    if (definition == null) {
      setState(() {
        _result = 'No results found.';
        _isLoading = false;
      });
      return;
    }

    // Translation
    String translated = entryWord;
    try {
      final response = await http.get(Uri.parse(
          'https://api.mymemory.translated.net/get?q=$entryWord&langpair=en|$_selectedLanguage'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        translated = data['responseData']['translatedText'];
      }
    } catch (e) {
      // print(e);
    }

    String easy = definition.length > 90
        ? '${definition.split(" ").take(15).join(" ")}...'
        : definition;

    setState(() {
      _result = '''
      <h2>$entryWord</h2>
      <p><b>Definition:</b> $definition</p>
      <p><b>Easy Meaning:</b> $easy</p>
      <p><b>Example:</b> ${example ?? "No example"}</p>
      <p><b>Synonyms:</b> ${synonyms.isNotEmpty ? synonyms.take(6).join(', ') : 'None'}</p>
      <p><b>Translated ($_selectedLanguage):</b> $translated</p>
      ''';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://media.istockphoto.com/id/929023224/vector/seamless-background-with-books.jpg?s=612x612&w=0&k=20&c=suJcI7JPdWMAB32Dlr3V1CPs3FCfgFkhSSuFuQN8bzw='),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'WordsWise AI',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Dictionary & Encyclopedia',
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  '-Ultimate Edition-',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _wordInputController,
                  decoration: InputDecoration(
                    hintText: 'Search here anything',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: _selectedLanguage,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedLanguage = newValue;
                      });
                    }
                  },
                  items: _languages.entries
                      .map<DropdownMenuItem<String>>((MapEntry<String, String> entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _searchWord,
                      icon: const Icon(Icons.search),
                      label: const Text('Search'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Placeholder for voice search
                      },
                      icon: const Icon(Icons.mic),
                      label: const Text('Voice Search'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Placeholder for camera translate
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera Translate'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Placeholder for PDF download
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('PDF'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _result.replaceAll(RegExp(r'<[^>]*>'), '\n'), // Basic HTML removal
                              textAlign: TextAlign.left,
                            ),
                            if (_imageUrls.isNotEmpty)
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _imageUrls.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Image.network(_imageUrls[index]),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                const SizedBox(height: 30),
                const Text(
                  'Created & Programmed by Maanvith Sai',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Still under experiments. Our AI can make mistakes. Please re-check the information.',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
