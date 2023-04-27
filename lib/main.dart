import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carbon Emissions Calculator',
      home: MyHomePage(title: 'Carbon Emissions Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final myController = TextEditingController();
  final countryController = TextEditingController();
  String response = "";

  @override
  void dispose() {
    myController.dispose();
    countryController.dispose();
    super.dispose();
  }

  Future<String> callChatGPT(String product, String country) async {
    final apiKey = "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";
    final prompt = "What is the distance in miles that $product travels from the main production of site of $product in $country to Berkeley, California?";





    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey'
      },
      body: jsonEncode(<String, dynamic>{
        "model": "text-davinci-002",
        "prompt": prompt,
        "temperature": 0.5,
        "max_tokens": 60,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0
      }),
    );


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final output = data['choices'][0]['text'];
      final regex = RegExp(r'\d+');
      final match = regex.firstMatch(output);
      final distance = match?.group(0);
      final co2 = (int.parse(distance!) * 0.000621371 * 0.217).toStringAsFixed(2);;
      return "The estimated carbon dioxide emissions for $product produced in $country and shipped to Berkeley, California is $co2 kg.";
    } else {
      throw Exception('Failed to generate response');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: myController,
              decoration: InputDecoration(
                hintText: 'Enter product name',
                labelText: 'Product',
              ),
            ),
            TextField(
              controller: countryController,
              decoration: InputDecoration(
                hintText: 'Enter country name',
                labelText: 'Country',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  response = "Calculating...";
                });

                try {
                  final product = myController.text;
                  final country = countryController.text;
                  final result = await callChatGPT(product, country);
                  setState(() {
                    response = result;
                  });
                } catch (e) {
                  setState(() {
                    response = "Failed to generate response";
                  });
                }
              },
              child: Text('Calculate'),
            ),
            SizedBox(height: 16.0),
            Text(response),
          ],
        ),
      ),
    );
  }
}
