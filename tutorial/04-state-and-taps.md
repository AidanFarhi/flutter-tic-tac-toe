# 04 — State and taps

**Goal:** make the board respond. Tapping an empty square places an X.

This is the most important lesson in the tutorial. Everything else is detail.

---

## Where mutable state lives

Lesson 03 ended on the problem: widgets are immutable, but the board has to
change. Flutter's answer is `StatefulWidget`, which splits the job in two:

- **The widget** — still immutable, still thrown away and rebuilt constantly.
- **A `State` object** — created once, *survives* rebuilds, and holds your
  mutable fields.

The widget is disposable; its State persists. When you want the UI to reflect a
change, you mutate a field inside `setState()`, and Flutter re-runs `build()`.

```
_handleTap() ──▶ setState(() { _board[i] = 'X'; }) ──▶ build() re-runs ──▶ new UI
```

You still never touch a view. You change data and let `build()` re-describe.

## Convert the screen

**Type this** — replace the whole `GameScreen` class. Leave `Square` alone for
the moment:

```dart
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<String> _board = List.filled(9, '');

  void _handleTap(int index) {
    if (_board[index] != '') return;

    setState(() {
      _board[index] = 'X';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tic Tac Toe')),
      body: Center(
        child: Padding(
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
      ),
    );
  }
}
```

Now make `Square` tappable. **Type this** — replace the `Square` class:

```dart
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

Press **`R`** (you changed class declarations). Tap squares. X's appear.

## Why it works

### The two-class split

```dart
class GameScreen extends StatefulWidget {
  State<GameScreen> createState() => _GameScreenState();
}
```

The widget's only job is to say what kind of State it needs. Flutter calls
`createState()` **once**, when the widget first enters the tree. From then on
that State object stays put, even as the `GameScreen` widget itself is rebuilt
and discarded around it. That's precisely why `_board` survives while the
widgets don't.

The leading underscore in `_GameScreenState` means **library-private** in Dart —
private to the file, not to the class. Same for `_board` and `_handleTap`.
There's no `private` keyword.

### setState

```dart
setState(() {
  _board[index] = 'X';
});
```

Two things happen: your closure runs (mutating the field), then Flutter marks
this State dirty and schedules a rebuild.

The mutation is not magic — `_board[index] = 'X'` on its own would change the
data perfectly well and the screen would show nothing. **`setState` is the
notification.** Forgetting it, or mutating outside the closure, is the single
most common Flutter bug. The rule: any change that should be visible goes inside
`setState`.

Keep the closure tiny. Do computation before it, mutate inside it.

### Why `_board` is `final`

```dart
final List<String> _board = List.filled(9, '');
```

`final` here means the variable always points at *this* list — but the list's
contents are still mutable, which is why `_board[index] = 'X'` is legal. The
distinction from Lesson 01, doing real work.

Leave off `final` and the analyzer will tell you to add it, because nothing in
the app reassigns `_board` yet. Something will, in Lesson 07.

### The guard clause

```dart
if (_board[index] != '') return;
```

An occupied square is ignored. Note it returns *before* `setState` — no state
change, no rebuild, nothing to repaint.

### Passing a callback down

`Square` doesn't know what a game is. It gets a string to display and a function
to call when tapped:

```dart
final VoidCallback onTap;   // just: void Function()
```

and the parent supplies the meaning:

```dart
onTap: () => _handleTap(index),
```

`() => _handleTap(index)` is a zero-argument closure that captures `index`. It
matches `VoidCallback`'s signature while remembering which cell it belongs to.

This is the standard Flutter shape: **data flows down, events flow up.** `Square`
stays dumb and reusable; all the game rules live in one place. If you'd put a
`String _value` inside `Square` and mutated it there, nine squares would each own
a scrap of game state and nothing could tell whether the game was over.

> **Android note:** `onTap: onTap` is `setOnClickListener`, but declared as part
> of the widget's description rather than attached to a view afterward. There's
> nothing to detach — the callback is rebuilt with the widget.

### Why GestureDetector

`GestureDetector` is the raw, invisible gesture layer — taps, drags, long
presses. It draws nothing, so you'll see no ripple when you tap. (Material's
`InkWell` adds one; it needs an `Ink` surface to paint on, which is a small extra
piece of machinery we're skipping.)

## Check yourself

1. Why does the board survive a rebuild when the widget doesn't?
2. What happens if you mutate `_board` without `setState`?
3. Why does `Square` take a callback instead of tracking its own value?

<details>
<summary>Answers</summary>

1. `createState()` runs once. The State object lives across rebuilds; the
   `GameScreen` widget is disposable configuration.
2. The data changes, the UI doesn't. Nothing told Flutter to rebuild, so the
   screen keeps showing the last-described version.
3. Because game rules — turns, wins, draws — need a view of the *whole* board.
   State split across nine widgets couldn't answer "did someone win?"

</details>

Next: [05 — Turns and the indicator](05-turns-and-indicator.md)
