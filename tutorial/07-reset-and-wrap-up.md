# 07 — Reset and wrap-up

**Goal:** add a Reset button. That's the last item in the README's scope, so
this lesson also steps back and reviews what you've built.

---

## Make the board reassignable

`_reset` needs to swap in a brand-new empty board, and right now `_board` is
`final` — which forbids exactly that.

**Type this** — delete the word `final` from the board field:

```dart
  List<String> _board = List.filled(9, '');
```

This is the Lesson 01 distinction landing for real. `final` was correct while the
only operation was `_board[i] = 'X'` (mutating contents). Reset replaces the
list itself, so the variable has to be reassignable. The analyzer told you to add
`final` back in Lesson 04 precisely because nothing had needed this yet.

## Add the reset method

**Type this** — put it just above `build`:

```dart
  void _reset() {
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = 'X';
      _winner = null;
    });
  }
```

## Add the button

**Type this** — add two children at the end of the `Column`'s `children` list,
after the `Padding` that holds the board:

```dart
            const SizedBox(height: 24),
            FilledButton(onPressed: _reset, child: const Text('Reset')),
```

Press **`R`**. Play a game, hit Reset, play again.

## Why it works

**Reset restores every piece of state.** Three fields in, three fields out. Miss
`_winner = null` and the board clears but stays frozen — the tap guard still sees
a winner. Miss `_currentPlayer = 'X'` and the new game starts on whoever's turn
it happened to be.

Notice you don't reset `_isDraw` or `_statusText`. They're getters — derived
values fix themselves the moment their inputs change. Every field you *don't*
store is a field you can't forget to reset, which is the practical argument for
"derive, don't store."

**`onPressed: _reset`** passes the method itself, not a call to it. No
parentheses — `_reset()` would run it during `build` and hand `onPressed` the
result. Lesson 04 used `() => _handleTap(index)` because that one needed an
argument baked in; this one takes none, so the bare name works.

> Passing `null` to `onPressed` is how you disable a Material button — it greys
> out automatically. That's the idiom for a conditionally-enabled button.

**`FilledButton`** is one of Material 3's button widgets (alongside
`ElevatedButton`, `OutlinedButton`, `TextButton`). It picks up your seed color
without configuration.

---

## The finished app

Your `lib/main.dart`, in full. This exact listing was compiled and analyzed
clean:

```dart
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
            Text(
              _statusText,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
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
```

Confirm your own copy is clean:

```sh
flutter analyze
```

That's the full README scope: 3x3 board, tap to place, turn indicator, win and
draw detection, reset. About 130 lines, no state management library, plain
`setState`.

You can delete the Lesson 01 scratch file now:

```sh
rm -rf scratch
```

## The four ideas worth keeping

Strip away the specifics and this is what Flutter is:

1. **Describe, don't mutate.** `build()` returns a description of the UI for the
   current state. You never reach into a widget to change it — you change state
   and let Flutter re-describe. Everything else follows from this.

2. **Widgets are cheap and immutable; State is durable.** The widget is a
   disposable recipe rebuilt constantly. `createState()` runs once, and that
   object holds anything that has to survive.

3. **`setState` is a notification, not a mutation.** The assignment inside it
   would work on its own — what `setState` adds is "tell Flutter to rebuild."
   Forgetting it is the #1 Flutter bug.

4. **Derive, don't store.** `_statusText` and `_isDraw` are getters over
   `_board` and `_winner`. Two fields of real state, everything else computed.
   Fewer fields means fewer chances for the UI to disagree with reality.

## Where to go next

Roughly in order of how much they'll teach you:

- **Extract the game logic.** Move `_board`, `_findWinner`, `_isDraw`, and the
  turn flip into a plain `Game` class with no Flutter import, and let
  `_GameScreenState` hold one. This is the shape every larger Flutter app takes,
  and it makes the logic testable without a widget.
- **Write tests.** `flutter test` with `WidgetTester` lets you tap widgets and
  assert on what's on screen — `tester.tap(find.byType(Square).first)`. The
  extraction above makes most of it plain Dart unit testing.
- **Highlight the winning line.** Have `_findWinner` return the winning
  `List<int>` instead of just the mark, and tint those three squares. A small
  change that touches state, derived values, and rendering at once.
- **Animate the marks.** `AnimatedOpacity` or `AnimatedScale` around the `Text`
  in `Square` — one widget, no controllers.
- **Add state management** only once something actually hurts. `setState` is the
  right tool at this size; try `ValueNotifier` or Provider on the next app, when
  state needs to cross screens.

Two references worth bookmarking:

- [Flutter widget catalog](https://docs.flutter.dev/ui/widgets) — browse it once
  end to end; knowing what exists is most of the battle.
- [Dart language tour](https://dart.dev/language) — the parts we skipped:
  `async`/`await`, streams, mixins, pattern matching.

Back to the [tutorial index](README.md).
