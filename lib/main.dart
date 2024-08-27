import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DogImageApp(),
    );
  }
}

class DogImageApp extends StatefulWidget {
  @override
  State<DogImageApp> createState() => _DogImageAppState();
}

class _DogImageAppState extends State<DogImageApp> {
//Benötigte Variablen
  String? _selectedBreed;
  String? _imageUrl;
  bool _isLoading = false;
  final List<String> _breeds = [];

  @override
  void initState() {
    super.initState();
    _fetchBreeds();
  }

  Future<void> _fetchBreeds() async {
    final response =
        await http.get(Uri.parse("https://dog.ceo/api/breeds/list/all"));
    if (response.statusCode == 200) {
      final Map<String, dynamic> breedsJson =
          json.decode(response.body)["message"];
      setState(() {
        _breeds.addAll(breedsJson.keys
            .map((breed) => breed[0].toUpperCase() + breed.substring(1))
            .toList());
      });
    }
  }

  Future<void> _fetchRandomDogImage() async {
    setState(() {
      _isLoading = true;
    });
    final breed = _selectedBreed?.toLowerCase() ?? "random";
    final response = await http.get(Uri.parse(breed == "random"
        ? "https://dog.ceo/api/breeds/image/random"
        : "https://dog.ceo/api/breed/$breed/images/random"));
    if (response.statusCode == 200) {
      setState(() {
        _imageUrl = json.decode(response.body)["message"];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dog Image App"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (_breeds.isNotEmpty)
                  DropdownButton<String>(
                    value: _selectedBreed,
                    hint: Text("Bitte wähle eine Hunderasse aus"),
                    onChanged: (value) {
                      setState(() {
                        _selectedBreed = value;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: "random",
                        child: Text("Zufällige Rasse"),
                      ),
                      ..._breeds.map((breed) {
                        return DropdownMenuItem(
                          value: breed,
                          child: Text(breed),
                        );
                      }).toList(),
                    ],
                  ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: _fetchRandomDogImage,
                  child: Text("Hundebild anzeigen"),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : _imageUrl != null
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: Image.network(
                                  _imageUrl!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        : Text("Bitte wähle einen Hund aus")),
          )
        ],
      ),
    );
  }
}
