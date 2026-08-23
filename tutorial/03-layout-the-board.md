# 03 — Laying out the board

**Goal:** get a real 3x3 grid of squares on screen, with hardcoded contents.
No interaction yet — just layout.

---

## Layout is composition

There is no `LinearLayout` with twelve XML attributes. Instead each layout
concern is its own small widget that wraps a child:

| You want | You wrap in |
|----------|-------------|
| Space around something | `Padding` |
| Something centered | `Center` |
| A vertical stack | `Column` |
| A horizontal row | `Row` |
| A fixed gap | `SizedBox` |
| A forced square | `AspectRatio` |
| A background, border, rounded corners | `Container` |

Single-child widgets take `child:`. Multi-child ones take `children:`. Nesting
four widgets deep to get "centered, padded, square" is normal and idiomatic,
not a code smell.

## Build the grid

**Type this** — replace the `GameScreen` class, and add a new `Square` class
below it:

```dart
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const board = ['X', 'O', 'X', '', 'O', '', '', '', 'X'];

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
              itemBuilder: (context, index) => Square(value: board[index]),
            ),
          ),
        ),
      ),
    );
  }
}

class Square extends StatelessWidget {
  const Square({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
```

Save and press **`r`**. You get a proper board with a scattering of X's and O's.

## Why it works

### The layout chain

Read the nesting outward-in — each layer does exactly one job:

```
Center          → put it in the middle of the screen
 Padding        → 24px of breathing room on the sides
  AspectRatio   → whatever width you got, make the height match
   GridView     → chop that square into 9 cells
    Square      → draw one cell
```

`AspectRatio(aspectRatio: 1)` is what keeps the board square on every device.
Without it the grid would stretch to fill the tall screen and you'd get
rectangles.

### GridView.builder

Three parameters carry the weight:

- **`gridDelegate`** decides the cell geometry.
  `SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3)` means "3 across,
  and figure out the rest." The spacing parameters put 8px gutters between cells,
  which is where the grid lines come from — we never draw any.
- **`itemCount: 9`** — how many cells.
- **`itemBuilder`** — a function that turns an index into that cell's widget.
  This is the payoff from Lesson 01's flat list: index 0-8 maps straight onto
  grid position with no arithmetic.

`physics: NeverScrollableScrollPhysics()` disables scrolling. A `GridView`
assumes it's scrollable; ours is exactly the size of its contents, so bouncing
would just look broken.

> **Android note:** `itemBuilder` is your `RecyclerView.Adapter`, minus the
> ViewHolder ceremony. Same lazy-construction idea — build the cell when it's
> needed.

### How `itemBuilder` "knows" about the board

Worth slowing down on, because nothing in these two lines loops over `board`:

```dart
itemCount: 9,
itemBuilder: (context, index) => Square(value: board[index]),
```

Three separate things are happening.

**`itemCount` defines the range.** The `GridView` is the thing doing the
iterating, and it knows how far to go because you told it `9`. `board` plays no
part in that decision. Write `itemCount: 4` and it only ever asks for four
squares — the last five entries of `board` are never read.

**`itemBuilder` is a function you hand over, not a loop body you run.** That
arrow expression creates an anonymous function taking `(BuildContext, int)` and
returning a `Widget`, and stores it on the `GridView`. You never call it.
Later, when Flutter lays out the grid and decides it needs the cell at position
3, *it* calls your function with `index: 3`. You wrote the recipe; the framework
owns the loop. That's why there is no `for` anywhere on screen.

**`board` is visible inside the function because of closure.** The function is
defined inside `build()`, where the local `board` is in scope, so it captures
that variable. When Flutter later calls it with `3`, the body evaluates
`board[3]` → `''`. The only thing connecting the grid to the board is that you
wrote `board[index]` in the body — swap it for `Square(value: 'hi')` and you get
nine identical squares with `board` never touched.

So the model is: **`itemCount` sets the range, Flutter runs the loop, your
closure maps an index to a widget.**

Two consequences worth internalizing now, because they bite later:

- `itemCount` and `board.length` are coupled only by your discipline. Once the
  board becomes dynamic, `itemCount: board.length` is safer than a hardcoded
  `9` — a mismatch is a runtime `RangeError`, not a compile error.
- `itemBuilder` can be called repeatedly, at unpredictable times, and out of
  order. All nine of ours are on screen, so they get built up front, but a long
  scrolling list only builds what's visible. Keep it cheap and side-effect-free
  — never mutate state or kick off work inside it.

### Extracting the Square widget

`Square` is a widget you wrote, and Flutter can't tell it apart from a built-in
one. That's the composition model working as intended: build small widgets, nest
them.

Look at how it takes its input:

```dart
const Square({super.key, required this.value});

final String value;
```

Widget fields are **`final`** — always. A widget is immutable; to show something
different you build a new `Square` with a different `value`. That's not a
limitation you work around, it's the model. Lesson 04 is entirely about where
mutable state is allowed to live.

`Theme.of(context)` is that ambient lookup from Lesson 02 in action — `Square`
walks up the tree to find the nearest theme and pulls a surface color out of the
palette that `ColorScheme.fromSeed` generated. Change the seed color and the
squares re-tint too, because nothing here hardcodes a color.

## Experiment

Hot reload is instant, so poke at it:

- Set `crossAxisCount: 4` — the grid reflows. Set it back.
- Change `aspectRatio` to `0.5` and watch the board go tall.
- Bump `mainAxisSpacing` to `24` for fat gutters.
- Delete `physics:` and drag the board to see why it's there.
- Swap `board[index]` for `'$index'` to watch the indices Flutter hands you.

## Check yourself

1. Why is `Square.value` `final`?
2. What actually draws the grid lines?
3. `board` is `const` here. Why will that have to change?
4. What decides how many times `itemBuilder` runs?

<details>
<summary>Answers</summary>

1. Widgets are immutable configuration. Displaying a different value means
   constructing a new widget, not mutating an existing one.
2. Nothing — the 8px `mainAxisSpacing`/`crossAxisSpacing` gutters let the
   background show through between rounded squares.
3. Because the player is about to start changing it. `const` demands a
   compile-time value, and a board that responds to taps isn't one.
4. `itemCount` — not `board`. The `GridView` owns the loop and calls your
   closure once per index it needs; `board` only enters the picture because the
   closure body happens to read it.

</details>

Next: [04 — State and taps](04-state-and-taps.md)
