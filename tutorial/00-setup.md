# 00 — Setup

**Goal:** generate a Flutter project in this repo and see it running on the iOS
Simulator, with hot reload working.

---

## 1. Confirm your toolchain

```sh
flutter --version
flutter doctor
```

You want the Flutter and Xcode lines healthy. You will probably see warnings.
Two of them don't matter for this tutorial:

- **Android toolchain issues** — we're building for iOS. Ignore.
- **`CocoaPods x.y.z out of date`** — CocoaPods only matters for projects that
  use native plugins. Tic-tac-toe uses none, so Flutter never invokes it. Ignore
  it here; update it later if you add a plugin.

Anything wrong with the **Flutter** or **Xcode** lines themselves, fix before
continuing.

## 2. Boot a simulator

Flutter can only see a simulator that is already running.

```sh
xcrun simctl list devices available | grep iPhone
```

Pick one and boot it, then open the Simulator app so you can actually see it:

```sh
xcrun simctl boot "iPhone 16 Pro"
open -a Simulator
```

Confirm Flutter sees it:

```sh
flutter devices
```

You should now get an `iPhone 16 Pro (mobile)` row alongside macOS and Chrome.

## 3. Generate the project

From the repo root:

```sh
cd /Users/aidanfarhi/Development/flutter-tic-tac-toe
flutter create --project-name tic_tac_toe .
```

Two things to notice about that command:

- The trailing `.` means "scaffold into the current directory" instead of
  creating a subfolder. Your existing `README.md` and `.git` are left alone.
- `--project-name tic_tac_toe` is **required** here. Without it Flutter derives
  the package name from the folder name, `flutter-tic-tac-toe`, and hyphens are
  illegal in Dart package names. Underscores are the convention.

Look at what you got:

```sh
ls
```

The parts that matter:

| Path | What it is |
|------|-----------|
| `lib/main.dart` | Your app. This is the only file you'll edit all tutorial. |
| `pubspec.yaml` | Dependencies and asset declarations. Think `build.gradle`. |
| `ios/` | The generated Xcode project. You won't touch it. |
| `test/` | Generated sample test. We'll delete it in Lesson 02. |
| `analysis_options.yaml` | Lint rules the analyzer enforces. |

## 4. Run it

```sh
flutter pub get
flutter run
```

The first iOS build compiles the engine bindings and takes a few minutes. Later
builds are seconds. When it finishes you'll get Flutter's demo counter app in
the simulator, and your terminal will be sitting at an interactive prompt.

## 5. Try hot reload

This is the single biggest quality-of-life feature in Flutter, and it's worth
feeling it before you learn anything else.

Leave `flutter run` going. In another editor window, open `lib/main.dart` and
find this line:

```dart
title: 'Flutter Demo Home Page',
```

Change the text to anything else and save. Now press **`r`** in the terminal
running `flutter run`.

The simulator updates in well under a second, **and the counter keeps its
value**. That's the distinction worth remembering:

- **`r` — hot reload.** Injects your changed code into the running app. State
  is preserved. This is what you'll use constantly.
- **`R` — hot restart.** Re-runs the app from scratch. State is lost. Use it
  when you change something hot reload can't patch, like the contents of
  `main()` or a class's field declarations.
- **`q` — quit.**

> **Android note:** hot reload is the thing Instant Run always wanted to be. It
> works because Dart's VM can swap in new code and Flutter simply re-runs your
> `build()` methods against the state it already has.

If hot reload ever seems to do nothing, press `R` before you go hunting for a
bug in your code.

## 6. Ignore the build output

`flutter create` writes a `.gitignore` for you that already covers `build/`,
`.dart_tool/`, and the iOS junk. Verify it landed:

```sh
git status --short
```

You should see the new project files but no `build/` directory.

---

## Where you are

A working Flutter app on the simulator, and a feedback loop of "edit, save,
press `r`, see it." Keep `flutter run` alive in a terminal for the rest of the
tutorial.

## Check yourself

1. Why did we pass `--project-name`?
2. You add a new field to a class and hot reload doesn't show your change. What
   do you press?

<details>
<summary>Answers</summary>

1. The directory is `flutter-tic-tac-toe`, and hyphens aren't legal in Dart
   package names, so the default derived name would be rejected.
2. `R` — hot restart. Field declarations are part of the class's initialization,
   which hot reload doesn't re-run on existing objects.

</details>

Next: [01 — Dart crash course](01-dart-crash-course.md)
