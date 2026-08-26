import 'package:flutter/material.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        colorScheme: colorScheme,
        appBarTheme: AppBarThemeData(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
      home: const GameScreen(),
    );
  }
}

const List<List<int>> winningLines = [
  [0, 1, 2], // top row
  [3, 4, 5], // middle row
  [6, 7, 8], // bottom row
  [0, 3, 6], // left column
  [1, 4, 7], // middle column
  [2, 5, 8], // right column
  [0, 4, 8], // diagonal
  [2, 4, 6], // anti-diagonal
];

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  String? _winner;

  bool get _isDraw => _winner == null && !_board.contains('');

  String get _statusText {
    if (_winner != null) return 'Player $_winner wins!';
    if (_isDraw) return "It's a draw";
    return "Player $_currentPlayer's turn";
  }

  String? _findWinner() {
    for (final line in winningLines) {
      final first = _board[line[0]];
      if (first != '' && first == _board[line[1]] && first == _board[line[2]]) {
        return first;
      }
    }
    return null;
  }

  void _handleTap(int index) {
    if (_board[index] != '' || _winner != null || _isDraw) return;
    setState(() {
      _board[index] = _currentPlayer;
      _winner = _findWinner();
      if (_winner == null) {
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
      }
    });
  }

  void _reset() {
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = 'X';
      _winner = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tic Tac Toe')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_statusText, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) => Square(
                    value: _board[index],
                    onTap: () => _handleTap(index),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _reset, child: const Text('Reset')),
          ],
        ),
      ),
    );
  }
}

class Square extends StatelessWidget {
  const Square({super.key, required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
