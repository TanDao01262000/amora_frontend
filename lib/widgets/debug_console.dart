import 'package:flutter/material.dart';

class DebugConsole extends StatefulWidget {
  const DebugConsole({super.key});

  @override
  State<DebugConsole> createState() => _DebugConsoleState();
}

class _DebugConsoleState extends State<DebugConsole> {
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Capture print statements (this is a simplified approach)
    _logs.add('🔧 Debug Console initialized');
    _logs.add('📱 Ready to capture API logs...');
  }

  void addLog(String log) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $log');
      // Keep only last 100 logs
      if (_logs.length > 100) {
        _logs.removeAt(0);
      }
    });
    
    // Auto scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Console'),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _logs.clear();
                _logs.add('🔧 Debug Console cleared');
              });
            },
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8.0),
          itemCount: _logs.length,
          itemBuilder: (context, index) {
            final log = _logs[index];
            Color textColor = Colors.white;
            
            if (log.contains('✅') || log.contains('Success')) {
              textColor = Colors.green;
            } else if (log.contains('❌') || log.contains('Error') || log.contains('Failed')) {
              textColor = Colors.red;
            } else if (log.contains('🚀') || log.contains('API Call')) {
              textColor = Colors.blue;
            } else if (log.contains('🔐') || log.contains('Auth')) {
              textColor = Colors.orange;
            } else if (log.contains('📋') || log.contains('Routine')) {
              textColor = Colors.purple;
            } else if (log.contains('📝') || log.contains('Timeline')) {
              textColor = Colors.cyan;
            } else if (log.contains('📅') || log.contains('Calendar')) {
              textColor = Colors.yellow;
            }
            
            return Container(
              margin: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                log,
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
