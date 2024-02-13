import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<dynamic> _data = [];
  List<dynamic> _filteredData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      final response = await http.get(Uri.parse(
          'https://raw.githubusercontent.com/abhirgi/Census/main/ICD_orgi.json'));

      if (response.statusCode == 200) {
        setState(() {
          _data = json.decode(response.body);
          _filteredData = _data;
          _isLoading =
              false; // Set loading state to false after data is fetched
        });
      } else {
        print('Failed to load data');
        setState(() {
          _isLoading =
              false; // Set loading state to false if data loading fails
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false; // Set loading state to false if an error occurs
      });
    }
  }

  void _filterData(String query) {
    setState(() {
      _filteredData = _data
          .where((item) =>
              item['Code'].toString().contains(query) ||
              item['MCCD Description'].toString().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 73, 69, 69),
        appBarTheme: AppBarTheme(
          color: Colors.grey[900], // Dark grey color for app bar
        ),
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.white), // White text color
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: Color.fromARGB(255, 157, 146, 146), // Dark grey background color for input fields
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8.0),
          ),
          hintStyle: TextStyle(
              color: Color.fromRGBO(214, 115, 29, 1)), // Grey hint text color
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('ICD-10 WHO')),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search keyword',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 199, 227, 115)),
                  prefixIcon: Icon(Icons.search,
                      color: Color.fromARGB(206, 23, 46, 176)),
                ),
                onChanged: _filterData,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator(), // Show loading spinner while data is being fetched
                    )
                  : ListView(
                      children: _filteredData.map((item) {
                        return ListTile(
                          title: Text(
                            '${item['MCCD Description']}',
                            style: TextStyle(
                              // Set the text color to blue
                              fontSize: 18, // Set the font size
                              // Set the font style to italic
                            ),
                          ),
                          subtitle: Text('${item['Code']}',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontStyle: FontStyle.italic)),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
