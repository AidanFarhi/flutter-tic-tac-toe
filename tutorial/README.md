# Flutter Tutorial: Build Tic-Tac-Toe

A hands-on tutorial that builds the app described in the [root README](../README.md),
one concept at a time. You type all the code yourself — nothing is pre-written in
this repo.

## Who this is for

You can program, and you've seen Android development before. So this tutorial
skips "what is a variable" and spends its time on the two things that are
genuinely new: **Dart's syntax quirks** and **Flutter's declarative widget
model**. Where a Flutter idea has an Android counterpart, there's a comparison
callout.

## How to work through it

Do them in order. Each lesson ends with a running app you can see in the
simulator, and every code listing has been compiled and checked before being
written down.

| # | Lesson | What you'll end up with |
|---|--------|-------------------------|
| 00 | [Setup](00-setup.md) | A generated Flutter project running on the iOS Simulator |
| 01 | [Dart crash course](01-dart-crash-course.md) | The game's win/draw logic, written and tested in pure Dart |
| 02 | [Widgets and the tree](02-widgets-and-the-tree.md) | Your own app scaffold, replacing the counter demo |
| 03 | [Laying out the board](03-layout-the-board.md) | A static 3x3 grid of squares on screen |
| 04 | [State and taps](04-state-and-taps.md) | Tapping a square places an X |
| 05 | [Turns and the indicator](05-turns-and-indicator.md) | X and O alternate; a label says whose turn it is |
| 06 | [Win and draw detection](06-win-and-draw.md) | The game recognizes a winner or a draw and locks the board |
| 07 | [Reset and wrap-up](07-reset-and-wrap-up.md) | A finished, resettable game |

## Conventions

- **Type this** blocks are code you should enter yourself.
- **Android note** callouts map a Flutter idea onto something you already know.
- **Why it works** sections explain the mechanism after you've seen the result.
- **Check yourself** questions have answers at the bottom of each lesson.

Total time: roughly 3-4 hours if you actually type everything, which you should.
