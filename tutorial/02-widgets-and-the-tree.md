# 02 — Widgets and the tree

**Goal:** throw away the counter demo and replace it with your own app shell.
Along the way, understand what a widget actually is.

---

## The one big idea

In Android you build a layout in XML, inflate it, hold references to views, and
then **mutate** those views when things change: `textView.setText("X")`.

Flutter doesn't work that way. You write a function that takes your current
state and **returns a description of the entire UI**. When state changes,
Flutter calls that function again and figures out the minimal set of actual
changes to make on screen.

```
state ──▶ build() ──▶ widget tree ──▶ what you see
```

You never say "update this label." You change the state, and re-describe.

A **widget is not a view.** It's an immutable, cheap configuration object — a
recipe. Flutter creates thousands of them per second and throws them away.
The heavyweight objects that actually render live underneath, and Flutter reuses
them across rebuilds. That's why constructing widgets in `build()` isn't
wasteful the way `new TextView()` in `onDraw()` would be.

> **Android note:** the closest thing you've seen is probably Jetpack Compose,
> which took this model from React and Flutter. If you learned Android with XML
> layouts and `findViewById`, the mental shift here is the whole lesson.

Everything is a widget. Padding is a widget. Centering is a widget. The app
itself is a widget. You compose behavior by **nesting** rather than by setting
attributes.

## Clear the decks

`flutter create` left a sample test that references a class we're about to
delete. Remove it, or `flutter analyze` will complain for the rest of the
tutorial:

```sh
rm test/widget_test.dart
```

## Write your app

**Type this** as the complete contents of `lib/main.dart` — delete everything
that's there first:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tic Tac Toe')),
      body: const Center(child: Text('Board goes here')),
    );
  }
}
```

You changed `main()`, so hot reload won't cut it. Press **`R`** (hot restart) in
your `flutter run` terminal.

You should see an indigo app bar reading "Tic Tac Toe" and centered text.

## Why it works

Read it from the outside in — the nesting *is* the structure.

**`runApp(...)`** hands Flutter the root widget and starts the show.

**`StatelessWidget`** is a widget whose appearance depends only on its
constructor arguments. Given the same inputs it always builds the same output.
Neither of ours has anything to remember yet — that changes in Lesson 04.

**`build(BuildContext context)`** is the function from the diagram above. It
returns a description. It must be fast and side-effect free, because Flutter
calls it whenever it pleases.

**`MaterialApp`** wraps the app in Material Design plumbing: theming,
navigation, text direction, the default font. Its `home:` is the first screen.

**`ColorScheme.fromSeed`** generates a full, contrast-checked Material 3 palette
from one color. Change `Colors.indigo` and hot reload to watch the whole app
re-tint. You get light and dark variants for free.

**`Scaffold`** is the standard screen skeleton — it knows where an app bar goes,
where the body goes, where a floating action button would go. Roughly the job
your Activity's root layout did.

**`BuildContext`** is your widget's handle on its position in the tree. It's how
a widget asks "what's the theme here?" — you'll use it in the next lesson via
`Theme.of(context)`. It's ambient dependency lookup by tree position.

### Two bits of syntax

**`const` constructors.** Notice `const TicTacToeApp()` and `const Text(...)`.
When every argument to a widget is known at compile time, Dart builds *one*
instance and reuses it forever. On rebuild, Flutter sees the identical object,
knows nothing changed, and skips that whole subtree. It's a real optimization,
and the linter will nag you when you miss one. Add `const` wherever it's
accepted.

**`super.key`.** The `Key` is how Flutter tells sibling widgets apart when a list
gets reordered. You won't need one in this app, but the convention is to accept
and forward it, and the linter expects it.

## Check yourself

1. What's the difference between a widget and the thing on screen?
2. Why did this change need `R` instead of `r`?
3. Where would you change the app's accent color?

<details>
<summary>Answers</summary>

1. A widget is an immutable, disposable description. Flutter maintains separate,
   long-lived render objects underneath and updates them to match your latest
   description.
2. `main()` changed. Hot reload patches code into a running app but doesn't
   re-run `main()`, so the old root widget would still be mounted.
3. The `seedColor` in `ColorScheme.fromSeed` — one value drives the whole
   palette.

</details>

Next: [03 — Laying out the board](03-layout-the-board.md)
