import 'package:flutter/material.dart';
import 'dart:math';

class RandomCharacterPage extends StatefulWidget {
  const RandomCharacterPage({super.key, required this.title});
  final String title;

  @override
  State<RandomCharacterPage> createState() => _RandomCharacterPageState();
}

class _RandomCharacterPageState extends State<RandomCharacterPage> with SingleTickerProviderStateMixin {
  String _randomChar = 'A';
  String _displayedChar = 'A';
  String _targetChar = 'A';
  final TextEditingController _startController = TextEditingController(text: 'A');
  final TextEditingController _endController = TextEditingController(text: 'Z');
  final Random _random = Random();
  late AnimationController _animationController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller first
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(() {
      // Update the displayed character during animation
      _updateDisplayedChar();
    });
    
    // Set initial values
    _randomChar = _getRandomCharInRange();
    _displayedChar = _randomChar;
    _targetChar = _randomChar;
    
    // Mark as initialized
    _isInitialized = true;
  }

  String _getRandomCharInRange() {
    String start = _startController.text.isNotEmpty ? _startController.text[0].toUpperCase() : 'A';
    String end = _endController.text.isNotEmpty ? _endController.text[0].toUpperCase() : 'Z';
    
    // Ensure start comes before end in alphabet
    int startCode = start.codeUnitAt(0);
    int endCode = end.codeUnitAt(0);
    
    if (startCode > endCode) {
      start = 'A';
      end = 'Z';
      _startController.text = 'A';
      _endController.text = 'Z';
      startCode = 'A'.codeUnitAt(0);
      endCode = 'Z'.codeUnitAt(0);
    }
    
    int range = endCode - startCode + 1;
    int randomCharCode = startCode + _random.nextInt(range);
    return String.fromCharCode(randomCharCode);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _updateDisplayedChar() {
    if (_animationController.isAnimating) {
      // Calculate progress through the animation
      final progress = _animationController.value;
      
      // If we're closer to the end, slow down the cycling a bit
      final effectiveProgress = progress < 0.7 
          ? progress 
          : 0.7 + (progress - 0.7) * 3; // Non-linear progress
      
      setState(() {
        // Get the ASCII codes
        int startCode = _randomChar.codeUnitAt(0);
        int targetCode = _targetChar.codeUnitAt(0);
        
        // Calculate the intermediate character to display
        int currentCode;
        if (targetCode >= startCode) {
          currentCode = startCode + 
              ((effectiveProgress) * (targetCode - startCode)).round();
        } else {
          currentCode = startCode - 
              ((effectiveProgress) * (startCode - targetCode)).round();
        }
        
        _displayedChar = String.fromCharCode(currentCode);
      });
    }
  }

  void _generateRandomChar() {
    if (!_isInitialized) return;
    
    // Store the current displayed character
    _randomChar = _displayedChar;
    
    // Generate new target character
    _targetChar = _getRandomCharInRange();
    
    // Start animation to the new character
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: GestureDetector(
        onTap: _generateRandomChar,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _displayedChar,
                        style: const TextStyle(
                          fontSize: 100,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tap anywhere to generate',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _startController,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 1,
                        decoration: const InputDecoration(
                          labelText: 'From',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                        onChanged: (_) => _generateRandomChar(),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        controller: _endController,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 1,
                        decoration: const InputDecoration(
                          labelText: 'To',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                        onChanged: (_) => _generateRandomChar(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
