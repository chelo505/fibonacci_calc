import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:file_save_directory/file_save_directory.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Fibonacci Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _lastSavedPath;
  String _displayResult = '—';

  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> saveResult(String content) async {
    try {
      if (_lastSavedPath != null) {
        final oldFile = File(_lastSavedPath!);
        if (await oldFile.exists()) {
          await oldFile.delete();
          log('Deleted old file: $_lastSavedPath');
        }
      }

      final result = await FileSaveDirectory.instance.saveFile(
        fileName: 'number.txt',
        fileBytes: utf8.encode(content),
        location: SaveLocation.documents,
        openAfterSave: true,
      );

      if (result.success && result.path != null) {
        _lastSavedPath = result.path;
        log('Saved new file at: ${result.path}');
      }
    } catch (e) {
      log('Save error: $e');
    }
  }

  

  BigInt fibonacci(int n) {
    if (n < 0) {
      throw ArgumentError('Number must be non-negative');
    }
    if (n == 0) return BigInt.zero;
    
    if (n == 1) return BigInt.one;
    

    BigInt a = BigInt.zero;
    BigInt b = BigInt.one;

    for (int i = 2; i <= n; i++) {
      final temp = a + b;
      a = b;
      b = temp;
    }

    return b;
  }

  void _incrementCounter() async {
    final parsed = int.tryParse(_inputController.text) ?? 0;

    final fib = fibonacci(parsed);

    if (parsed > 1500) {
      setState(() {
        _displayResult = 'Result too large to display (saved to file)';
      });

      await saveResult(fib.toString());
    } else {
      setState(() {
        _displayResult = fib.toString();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('Enter a number:'),
            TextField(
              controller: _inputController,
              keyboardType: TextInputType.number,
              maxLength: 20,
              decoration: InputDecoration(
                labelText: 'Enter a non-negative number',
              ),
            ),
            Text(
              _displayResult,
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
