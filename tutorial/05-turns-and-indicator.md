# 05 — Turns and the indicator

**Goal:** X and O alternate, and a label above the board says whose turn it is.

Short lesson. You already know the mechanism — this is practice, plus two new
Dart features.

---

## Add the turn state

**Type this** — add a field below `_board`, and replace `_handleTap`:

```dart
  final List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';

  String get _statusText => "Player $_currentPlayer's turn";

  void _handleTap(int index) {
    if (_board[index] != '') return;

    setState(() {
      _board[index] = _currentPlayer;
      _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
    });
  }
```

## Show it

The board is currently the direct child of `Padding`. We need to stack a label
above it, so wrap the whole thing in a `Column`.

**Type this** — replace the `body:` of the `Scaffold`:

```dart
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
          ],
        ),
      ),
```

Press **`R`**. Alternating X's and O's, with a live turn indicator.

## Why it works

### Flipping the player

```dart
_currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
```

Both mutations sit inside the same `setState` closure, so they're one atomic
update followed by one rebuild — not two.

Order matters: place the mark **then** flip. Reverse those lines and O's move
lands under X's name.

### Getters

```dart
String get _statusText => "Player $_currentPlayer's turn";
```

A **getter** is a method you call without parentheses — `_statusText`, not
`_statusText()`. It's computed fresh on every access, so it can't fall out of
sync with `_currentPlayer` the way a stored copy could.

This is the pattern worth internalizing: **derive, don't store.** The status
line isn't state — it's a function of state. One source of truth (`_board`,
`_currentPlayer`), everything else computed from it. Lesson 06 leans on this
hard.

Note the string: `"Player $_currentPlayer's turn"` uses double quotes so the
apostrophe in `player's` doesn't terminate it. Dart treats `'` and `"` alike.

### Column

`Column` lays children out vertically. Two things about it:

- **`mainAxisAlignment: MainAxisAlignment.center`** centers the group
  vertically. The main axis is the direction the widget lays out along — vertical
  for `Column`, horizontal for `Row`. `crossAxisAlignment` is the other one.
- **`const SizedBox(height: 24)`** is a 24px spacer. There's no margin property
  in Flutter; you either wrap in `Padding` or drop a `SizedBox` between children.
  Explicit, slightly verbose, entirely predictable.

### Theme text styles

```dart
style: Theme.of(context).textTheme.headlineSmall,
```

Rather than hardcoding a font size, pull a role from the theme's type scale —
`displayLarge` through `labelSmall`. It scales with the user's accessibility
settings and stays consistent across the app. Same ambient lookup you used for
the square's color.

## Check yourself

1. Why is `_statusText` a getter instead of a `String` field updated in
   `_handleTap`?
2. What goes wrong if you flip the player before placing the mark?
3. Tap the same square twice — why does nothing happen the second time?

<details>
<summary>Answers</summary>

1. A getter recomputes on every read, so it can never disagree with
   `_currentPlayer`. A stored field would need updating at every mutation site —
   one more thing to forget.
2. The mark gets placed for the wrong player. `_board[index] = _currentPlayer`
   would use the already-flipped value.
3. The `if (_board[index] != '') return;` guard rejects occupied squares before
   any state changes.

</details>

Next: [06 — Win and draw detection](06-win-and-draw.md)
