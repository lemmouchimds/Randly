import 'package:flutter/material.dart';
import 'dart:math';

class RandomNumberPage extends StatefulWidget {
  const RandomNumberPage({super.key, required this.title});
  final String title;

  @override
  State<RandomNumberPage> createState() => _RandomNumberPageState();
}

class _RandomNumberPageState extends State<RandomNumberPage> with SingleTickerProviderStateMixin {
  int _randomNumber = 0;
  int _displayedNumber = 0;
  int _targetNumber = 0;
  final TextEditingController _minController = TextEditingController(text: '1');
  final TextEditingController _maxController = TextEditingController(text: '100');
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
      // Update the displayed number during animation
      _updateDisplayedNumber();
    });
    
    // Set initial values
    _randomNumber = _getRandomNumberInRange();
    _displayedNumber = _randomNumber;
    _targetNumber = _randomNumber;
    
    // Mark as initialized
    _isInitialized = true;
  }

  int _getRandomNumberInRange() {
    int min = int.tryParse(_minController.text) ?? 1;
    int max = int.tryParse(_maxController.text) ?? 100;
    
    // Ensure min is less than max
    if (min >= max) {
      min = 1;
      max = 100;
      _minController.text = '1';
      _maxController.text = '100';
    }
    
    return min + _random.nextInt(max - min + 1);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _updateDisplayedNumber() {
    if (_animationController.isAnimating) {
      // Calculate progress through the animation
      final progress = _animationController.value;
      
      // If we're closer to the end, slow down the cycling a bit
      final effectiveProgress = progress < 0.7 
          ? progress 
          : 0.7 + (progress - 0.7) * 3; // Non-linear progress
      
      // Get the current range limits
      int min = int.tryParse(_minController.text) ?? 1;
      int max = int.tryParse(_maxController.text) ?? 100;
      if (min >= max) {
        min = 1;
        max = 100;
      }
      
      // Calculate the intermediate number to display
      setState(() {
        if (_targetNumber >= _randomNumber) {
          _displayedNumber = _randomNumber + 
              ((effectiveProgress) * (_targetNumber - _randomNumber)).round();
        } else {
          _displayedNumber = _randomNumber - 
              ((effectiveProgress) * (_randomNumber - _targetNumber)).round();
        }
        
        // Ensure the displayed number stays within the range
        _displayedNumber = _displayedNumber.clamp(min, max);
      });
    }
  }

  void _generateRandomNumber() {
    if (!_isInitialized) return;
    
    // Store the current displayed number
    _randomNumber = _displayedNumber;
    
    // Generate new target number and ensure it's within range
    _targetNumber = _getRandomNumberInRange();
    
    // Start animation to the new number
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
        onTap: _generateRandomNumber,
        behavior: HitTestBehavior.opaque, // Ensures taps are detected even on transparent areas
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
                        '$_displayedNumber',
                        style: const TextStyle(
                          fontSize: 80,
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
                        controller: _minController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Min',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _generateRandomNumber(),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        controller: _maxController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Max',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _generateRandomNumber(),
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
