# 01 — Dart crash course

**Goal:** learn the Dart syntax you'll actually use, by writing the game's
win/draw logic as a plain command-line program — no Flutter involved.

Doing the logic first means that when we get to the UI, the only new thing is
the UI.

---

## The syntax tour

Dart will feel like Java with type inference and better null handling. Here's
the subset that matters.

### Variables

```dart
var name = 'X';        // inferred String, reassignable
String player = 'O';   // explicit type, same thing
final board = [1, 2];  // can't be reassigned; set at runtime
const size = 3;        // can't be reassigned; fixed at compile time
```

`final` vs `const` trips people up. `final` means *this variable never points at
anything else*. `const` means *this value is baked into the binary at compile
time*. `final now = DateTime.now()` is fine; `const now = DateTime.now()` won't
compile, because the value isn't knowable until the program runs.

Prefer `final` by default. You'll see `const` everywhere in Flutter code, and
Lesson 02 explains why it earns its keep there.

### Null safety

A type doesn't include null unless you say so with `?`:

```dart
String player = 'X';
player = null;         // compile error

String? winner;        // implicitly null, and that's allowed
winner = 'X';          // fine
```

That distinction drives the whole game. `String? winner` is exactly the right
model for "there might be a winner, or the game might still be going," and the
compiler will force you to handle both cases.

Two operators you'll want:

```dart
final w = winner ?? 'nobody';   // ?? : use the right side if the left is null
print(winner!.length);          // !  : "I promise this isn't null" — crashes if it is
```

Reach for `??` freely. Reach for `!` rarely — it's you overriding the compiler.

### Functions

```dart
String? findWinner(List<String> board) {
  return null;
}

// Single-expression functions can use =>
bool isDraw(List<String> b) => !b.contains('');
```

`=>` is just `{ return ...; }` with less typing. It shows up constantly in
Flutter callbacks.

### Named and required parameters

```dart
void move({required int index, String player = 'X'}) { }

move(index: 4);                      // player defaults to 'X'
move(index: 0, player: 'O');         // order doesn't matter
```

Curly braces in the parameter list make parameters **named**. Named ones are
optional unless marked `required`. Flutter's entire API is built on this — it's
why widget code reads as `Text('hi', style: ..., textAlign: ...)`.

> **Android note:** this is Dart's answer to the Builder pattern. Instead of
> `new AlertDialog.Builder(ctx).setTitle(..).setMessage(..).create()`, you get
> one constructor with twenty optional named parameters.

### Collections

```dart
final board = List.filled(9, '');   // 9 empty strings
board[4] = 'X';                     // elements are mutable
print(board.length);                // 9
print(board.contains(''));          // true
print(board[0] == '');              // true

final nested = [[0, 1, 2], [3, 4, 5]];
print(nested[1][0]);                // 3
```

One wrinkle worth knowing now, because it will bite you later: `List.filled`
returns a **fixed-length** list. You can reassign elements, but `.add()` throws.
That's fine for a 3x3 board that's always exactly 9 cells.

### Loops and strings

```dart
for (final line in winningLines) {
  print(line);
}

final player = 'X';
print('Player $player wins');          // interpolation
print('The winner is ${player.toLowerCase()}');  // ${} for expressions
```

Note `for (final x in xs)` — the `final` is idiomatic and means the loop
variable isn't reassigned inside the body.

### Ternaries

```dart
final next = player == 'X' ? 'O' : 'X';
```

Nothing surprising, but you'll use exactly this line to flip turns in Lesson 05.

---

## Now write the logic

Create a scratch file **outside** `lib/` — it's a throwaway, not part of the app:

```sh
mkdir -p scratch
```

**Type this** into `scratch/logic.dart`:

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

String? findWinner(List<String> board) {
  for (final line in winningLines) {
    final first = board[line[0]];
    if (first != '' && first == board[line[1]] && first == board[line[2]]) {
      return first;
    }
  }
  return null;
}

bool isDraw(List<String> board) =>
    findWinner(board) == null && !board.contains('');

void main() {
  final empty = List.filled(9, '');
  print('empty  -> winner: ${findWinner(empty)}, draw: ${isDraw(empty)}');

  final topRow = ['X', 'X', 'X', 'O', 'O', '', '', '', ''];
  print('topRow -> winner: ${findWinner(topRow)}, draw: ${isDraw(topRow)}');

  final diag = ['O', 'X', 'X', '', 'O', 'X', '', '', 'O'];
  print('diag   -> winner: ${findWinner(diag)}, draw: ${isDraw(diag)}');

  final full = ['X', 'O', 'X', 'X', 'O', 'O', 'O', 'X', 'X'];
  print('full   -> winner: ${findWinner(full)}, draw: ${isDraw(full)}');
}
```

Run it:

```sh
dart run scratch/logic.dart
```

Expected output:

```
empty  -> winner: null, draw: false
topRow -> winner: X, draw: false
diag   -> winner: O, draw: false
full   -> winner: null, draw: true
```

## Why it works

**The board is a flat list, not a 2D array.** Index 0-8, reading left to right,
top to bottom:

```
 0 | 1 | 2
---+---+---
 3 | 4 | 5
---+---+---
 6 | 7 | 8
```

A flat list is simpler to reset, simpler to check for a draw, and — as you'll
see in Lesson 03 — exactly what Flutter's grid widget wants to be handed.

**Eight lines is the whole game.** Rather than writing separate row, column, and
diagonal checks, we enumerate the 8 winning index triples once and loop. Adding
a rule would mean adding a row to the table, not writing new logic.

**`first != ''` guards against empty lines.** Without it, three empty cells would
"match" each other and report `''` as the winner.

**`isDraw` checks `findWinner` first.** A full board with a winning line is a
win, not a draw. Order matters.

**The return type `String?` carries the meaning.** "No winner" is `null`, not
`''` or `'none'` — and because the type says `String?`, Dart won't let a caller
forget that null is possible.

## Check yourself

1. Why does `findWinner` return `String?` rather than `String`?
2. What breaks if you drop the `first != ''` check?
3. `final board = List.filled(9, ''); board.add('X');` — what happens?

<details>
<summary>Answers</summary>

1. Because an in-progress game has no winner, and `null` represents that
   honestly. Null safety then forces callers to handle the "still playing" case.
2. An empty board reports `''` as the winner, since cells 0, 1, and 2 are all
   equal to each other. Every game would end on move zero.
3. Runtime error — `List.filled` is fixed-length. Assignment (`board[0] = 'X'`)
   works; growing the list doesn't.

</details>

You'll port `winningLines` and `findWinner` into the app in Lesson 06 nearly
unchanged. Keep the scratch file around until then.

Next: [02 — Widgets and the tree](02-widgets-and-the-tree.md)
