# 06 — Win and draw detection

**Goal:** the game recognizes a win or a draw, announces it, and stops accepting
moves.

The logic is already written — you did it in Lesson 01. This lesson is mostly
about wiring it in and letting the null-safe types drive the UI.

---

## Bring the logic across

**Type this** at the **top level** of `lib/main.dart` — outside every class,
just above `class GameScreen`:

```dart
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
```

It lives outside the class because it never changes and belongs to no particular
game. `const` means it's allocated once at compile time, not rebuilt per game.

## Add the state and the derived values

**Type this** — replace everything in `_GameScreenState` from the fields down
through `_handleTap`, leaving `build` alone:

```dart
  final List<String> _board = List.filled(9, '');
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
```

Press **`R`** and play a full game. Win with three in a row — the label
announces it and the board goes dead. Restart with `R` and play to a draw.

## Why it works

### One new field, two derived values

Only `_winner` was added to the actual state. `_isDraw` and `_statusText` are
**getters** — computed from `_board` and `_winner` every time they're read.

That's Lesson 05's "derive, don't store" scaled up. There's no way to reach a
state where the board says draw and the label disagrees, because the label
*asks* the board. Compare to the alternative: a `bool _gameOver` field you have
to remember to set at three different call sites.

### `_findWinner` barely changed

Compare with `scratch/logic.dart` — the only difference is that it reads
`_board` from the enclosing State object instead of taking a parameter.

Logic you can write and test as a plain function stays plain when it moves into
a widget. That's worth noticing: nothing about it needed to become
"Flutter-shaped." (Pulling it back out into its own class is a natural next
step; see Lesson 07's suggestions.)

### `String?` doing real work

```dart
String? _winner;
```

`null` means "no winner yet," and the type says so out loud. Because Dart knows
`_winner` might be null, `if (_winner != null) return 'Player $_winner wins!';`
only compiles thanks to **flow analysis** — inside that `if`, the compiler has
narrowed the type from `String?` to `String`, so interpolating it is safe.

You get a three-state game — playing, won, drawn — out of one nullable field and
one derived getter, with the compiler checking that you handled each.

### Order in `_statusText`

Win is checked before draw. A board that's full *and* has a winning line is a
win. Same ordering dependency as `isDraw` in Lesson 01, showing up again in the
UI layer.

### Freezing the board

```dart
if (_board[index] != '' || _winner != null || _isDraw) return;
```

Three reasons to ignore a tap: the square is taken, someone won, or the board is
full. Without the `_winner != null` clause you could keep playing into a
finished game.

### Only flip on a live game

```dart
_winner = _findWinner();
if (_winner == null) {
  _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
}
```

Check for a win *after* placing the mark, and skip the flip if the game just
ended. If you flipped unconditionally, X would win and the banner would read
"Player O wins!" — the winner is whoever just moved.

## Check yourself

1. Why is `_isDraw` a getter rather than a `bool` field set in `_handleTap`?
2. Why is the win check after the mark is placed rather than before?
3. Why does `_currentPlayer` only flip when `_winner == null`?
4. `winningLines` is declared outside the class. What would change if it were a
   field?

<details>
<summary>Answers</summary>

1. It's fully determined by `_board` and `_winner`, so recomputing it can't
   drift. A stored flag is a second source of truth you must keep in sync.
2. A move can only create a win by being made. Checking first would always test
   the previous board.
3. The winner is the player who just moved. Flipping first would attribute the
   win to their opponent.
4. It would be allocated per `_GameScreenState` instance rather than once at
   compile time. Harmless here, but there's no reason for a constant table to
   belong to an instance.

</details>

One thing left: you can only start a new game by restarting the app.

Next: [07 — Reset and wrap-up](07-reset-and-wrap-up.md)
