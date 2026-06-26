# Notification System — Build Errors & Fixes

> **Scope:** `flutter_local_notifications` integration on the `features/notifications` branch.
> All issues form a chain — each fix exposes the next layer.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Error 1 — Missing Package](#2-error-1--missing-package-flutter_local_notifications)
3. [Error 2 — Build Failure (Core Library Desugaring)](#3-error-2--build-failure-core-library-desugaring)
4. [Bonus Fix — iOS Foreground Notifications Silently Dropped](#4-bonus-fix--ios-foreground-notifications-silently-dropped)
5. [Warnings — Java 8 Obsolete Source/Target](#5-warnings--java-8-obsolete-sourcetarget)
6. [Failed Fix Attempts for the Warnings (What NOT to Do)](#6-failed-fix-attempts-for-the-warnings-what-not-to-do)
7. [Full Diff Summary](#7-full-diff-summary)

---

## 1. Overview

Five separate issues appeared when integrating `flutter_local_notifications`. They were not independent — they stacked in a chain. Fixing one exposed the next.

**The full chain:**

```Shell
Missing pubspec entry
    └── 13 fake "undefined" errors in the IDE
          └── flutter pub get → Build starts
                └── Gradle fails: desugaring not enabled
                      └── Build succeeds → Java 8 warnings appear
                            └── Fix attempt 1: subprojects { afterEvaluate }
                                  └── FAILS: "project already evaluated"
                                        └── Fix attempt 2: gradle.projectsEvaluated
                                              └── FAILS: android.content does not exist (100 errors)
                                                    └── Final resolution: remove the block — warnings are unavoidable noise
```

Understanding the dependency between them is critical. Fixing them out of order wastes time — always start from the root.

---

## 2. Error 1 — Missing Package (`flutter_local_notifications`)

### What happened

`notification_service.dart` imports and uses `flutter_local_notifications`, but the package was **never added to `pubspec.yaml`**.

### The error messages

The IDE reported 13 errors all at once:

```
Target of URI doesn't exist:
  'package:flutter_local_notifications/flutter_local_notifications.dart'

The imported package 'flutter_local_notifications' isn't a dependency
  of the importing package.

The method 'FlutterLocalNotificationsPlugin' isn't defined for the type 'NotificationService'.
The method 'AndroidNotificationChannel' isn't defined for the type 'NotificationService'.
The method 'AndroidNotificationDetails' isn't defined for the type 'NotificationService'.
The method 'NotificationDetails' isn't defined for the type 'NotificationService'.
The method 'AndroidInitializationSettings' isn't defined for the type 'NotificationService'.
The method 'DarwinInitializationSettings' isn't defined for the type 'NotificationService'.
The name 'AndroidFlutterLocalNotificationsPlugin' isn't a type.
The name 'InitializationSettings' isn't a class.
Undefined name 'Importance'. (×2)
Undefined name 'Priority'.
Const variables must be initialized with a constant value.
```

### Why 13 errors from 1 missing line?

These are **not 13 independent bugs.** They are all phantom errors caused by the one broken import on line 3. When Dart cannot resolve the import, it has no knowledge of any class or enum that package exports. Every usage of those classes then reports as "undefined."

**Fix one line → all 13 errors disappear at once.**

### Root cause

The code was authored (or merged) without the corresponding `pubspec.yaml` entry. The `firebase_messaging` line was present, but `flutter_local_notifications` was missing entirely.

### Fix

**File:** `pubspec.yaml`

```yaml
# Before
  firebase_messaging: ^16.4.1

# After
  firebase_messaging: ^16.4.1
  flutter_local_notifications: ^18.0.0
```

Then run:

```bash
flutter pub get
```

---

## 3. Error 2 — Build Failure (Core Library Desugaring)

### What happened

After adding the package and running the app, Gradle failed during the `:app:checkDevelopmentDebugAarMetadata` task.

### The exact error

```
FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:checkDevelopmentDebugAarMetadata'.
> A failure occurred while executing
    com.android.build.gradle.internal.tasks.CheckAarMetadataWorkAction
   > An issue was found when checking AAR metadata:

       1.  Dependency ':flutter_local_notifications' requires core library
           desugaring to be enabled for :app.

BUILD FAILED in 2m 8s
Error: Gradle task assembleDevelopmentDebug failed with exit code 1
```

### Why this happens — the root cause

`flutter_local_notifications` uses **Java 8+ time APIs** internally (`java.time.*` classes such as `LocalDateTime`, `ZonedDateTime`, etc.).

These APIs **do not exist natively** on Android devices below API 26 (Android 7.0 Nougat).

Android's **core library desugaring** solves this: it is a build-time process where the Android Gradle Plugin rewrites the compiled bytecode, replacing `java.time.*` calls with backported implementations that work on older Android versions.

**Without enabling it, Gradle refuses to build** — it detects the mismatch during the AAR metadata check phase and stops before compilation even starts.

Two things were missing from `android/app/build.gradle.kts`:

| What's missing                                                        | Effect                                                    |
| --------------------------------------------------------------------- | --------------------------------------------------------- |
| `isCoreLibraryDesugaringEnabled = true`                             | Tells the compiler to perform bytecode rewriting          |
| `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` | Provides the actual backported implementations at runtime |

Both are required. The flag without the library gives a different build error. The library without the flag does nothing.

### Fix

**File:** `android/app/build.gradle.kts`

```kotlin
// Before
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
}

// After
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
    isCoreLibraryDesugaringEnabled = true   // ← add this
}
```

```kotlin
// Add this block before the flutter {} block
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

---

## 4. Bonus Fix — iOS Foreground Notifications Silently Dropped

### What was wrong

This bug was found while reviewing `notification_service.dart` during the fix above. It is a **silent logic error** — no crash, no warning, just missing notifications on iOS.

### The problematic code

```dart
void _handleForegroundMessage(RemoteMessage message) {
  final notification = message.notification;
  final android = message.notification?.android;

  // ❌ android is ALWAYS null on iOS devices
  if (notification != null && android != null) {
    _localNotifications.show(...);
  }
}
```

### Why this is a bug

`message.notification?.android` returns `null` on every Apple device — there is no Android-specific notification object on iOS. So the `if` condition is **never true on iOS**, meaning `_localNotifications.show()` is never called for foreground messages on that platform.

`setForegroundNotificationPresentationOptions` (set elsewhere in `initialize()`) only controls whether the **system** shows a banner. It does **not** trigger the `onMessage` listener or call `show()` — that is the job of `_handleForegroundMessage`.

### Fix

**File:** `lib/core/notifications/service/notification_service.dart`

```dart
// After — platform-agnostic, works on both Android and iOS
void _handleForegroundMessage(RemoteMessage message) {
  final notification = message.notification;
  if (notification == null) return;   // only guard that matters

  _localNotifications.show(
    notification.hashCode,
    notification.title,
    notification.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(  // ← was entirely missing
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: _encodePayload(message.data),
  );
}
```

---

## 5. Warnings — Java 8 Obsolete Source/Target

### What the warnings look like

```
Note: Some input files use or override a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
warning: [options] source value 8 is obsolete and will be removed in a future release
warning: [options] target value 8 is obsolete and will be removed in a future release
warning: [options] To suppress warnings about obsolete options, use -Xlint:-options.
3 warnings
```

### Why this happens — the root cause

The project uses **JDK 21** (OpenJDK Temurin 21.0.7 LTS).

`android/app/build.gradle.kts` correctly sets Java 11 for the **app module**. But Flutter plugin packages (`flutter_local_notifications`, `firebase_messaging`, `firebase_core`, etc.) each compile as **separate Android library subprojects**. They ship their own internal `build.gradle` files which set:

```groovy
// Inside each plugin's own build.gradle (you don't own these files)
compileOptions {
    sourceCompatibility JavaVersion.VERSION_1_8
    targetCompatibility JavaVersion.VERSION_1_8
}
```

When **JDK 21** compiles those subprojects with `--source 8 --target 8`, it emits the obsolete warning. Java 8 as a source/target was deprecated since Java 17 and will be removed in a future JDK.

**Your app code is not the source of these warnings. The plugin packages are.**

### Why you can't just edit the plugin files

The plugin `build.gradle` files live inside Flutter's pub cache (`~/.pub-cache/hosted/pub.dev/...`). Editing them directly would:

- Be overwritten on the next `flutter pub get`
- Not be tracked by the repo
- Be machine-specific

### Why there is no safe root-level fix

Two approaches were attempted to override the plugin `JavaCompile` tasks from the root. **Both caused worse build failures than the warnings themselves.** See [Section 6](#6-failed-fix-attempts-for-the-warnings-what-not-to-do) for the full breakdown.

### Final resolution

**Accept the warnings.** They are cosmetic — they come from third-party plugin authors whose packages have not yet updated their `build.gradle` files. They do not affect the build output, app behavior, or release artifacts. The only lasting fix is for the plugin authors to update their own files, which is outside this project's control.

---

## 6. Failed Fix Attempts for the Warnings (What NOT to Do)

This section documents two approaches that were tried and failed. Both are recorded here so they are never attempted again.

---

### Attempt 1 — `subprojects { afterEvaluate { tasks.withType<JavaCompile>() } }`

#### What was tried

Added to `android/build.gradle.kts`:

```kotlin
subprojects {
    afterEvaluate {
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = JavaVersion.VERSION_11.toString()
            targetCompatibility = JavaVersion.VERSION_11.toString()
        }
    }
}
```

#### The error it caused

```
FAILURE: Build failed with an exception.

* Where:
Build file '...\android\build.gradle.kts' line: 25

* What went wrong:
Cannot run Project.afterEvaluate(Action) when the project is already evaluated.
```

#### Why it failed

The root `build.gradle.kts` already contains:

```kotlin
subprojects {
    project.evaluationDependsOn(":app")
}
```

`evaluationDependsOn(":app")` forces Gradle to **fully evaluate `:app` immediately and eagerly** before any other subproject is configured. So by the time the `afterEvaluate` block runs for `:app`, that project is already evaluated. Calling `afterEvaluate` on an already-evaluated project is illegal in Gradle — it throws immediately.

**`afterEvaluate` and `evaluationDependsOn` cannot coexist in the same root build file.**

---

### Attempt 2 — `gradle.projectsEvaluated { subprojects { tasks.withType<JavaCompile>() } }`

#### What was tried

Replaced Attempt 1 with:

```kotlin
gradle.projectsEvaluated {
    subprojects {
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = JavaVersion.VERSION_11.toString()
            targetCompatibility = JavaVersion.VERSION_11.toString()
        }
    }
}
```

`gradle.projectsEvaluated` fires after all projects finish evaluating, avoiding the "already evaluated" error.

#### The error it caused

```
Execution failed for task ':flutter_local_notifications:compileDebugJavaWithJavac'.
> Compilation failed; see the compiler output below.

error: package android.content does not exist
error: package android.app does not exist
error: package android.os does not exist
... (100 errors total)
```

Every single Android SDK package disappeared from the compile classpath of `flutter_local_notifications`.

#### Why it failed — deep explanation

In **AGP 8.9.1**, the `android.jar` (the file that provides every `android.*` package) is added to each plugin subproject's `JavaCompile` task using a **lazy classpath provider**. This provider is registered and wired during Gradle's **task graph resolution phase** — which runs *after* `projectsEvaluated`.

The sequence without our block:

```
projectsEvaluated fires
    └── task graph resolution begins
          └── AGP registers android.jar lazy provider on compileDebugJavaWithJavac
                └── task executes → android.jar is on the classpath ✓
```

The sequence with our block:

```
projectsEvaluated fires
    └── tasks.withType<JavaCompile>() → forces EAGER realization of compileDebugJavaWithJavac NOW
          └── task is realized before AGP registers the android.jar provider
                └── task graph resolution begins
                      └── AGP tries to wire android.jar → task already realized, window is closed ✗
                            └── task executes → android.jar is MISSING → 100 errors
```

`tasks.withType<JavaCompile>()` inside `projectsEvaluated` forces the task out of its lazy state too early. The AGP never gets to attach the bootclasspath. The result is that `android.content`, `android.app`, `android.os`, and every other Android SDK package vanish from the classpath entirely.

#### Why only `flutter_local_notifications` and not other plugins?

Gradle processes subprojects in dependency order. `flutter_local_notifications` was the first plugin whose `JavaCompile` task was realized inside the critical window — before the AGP had finished its lazy wiring. Other plugins were realized later, after the AGP's provider was already registered, so they compiled fine.

#### The fix for this error

Remove the `gradle.projectsEvaluated` block entirely. The Java 8 warnings are cosmetic. A broken build is not.

**File:** `android/build.gradle.kts` — remove the block completely. No replacement.

---

## 7. Full Diff Summary

| File                             | What changed                                                           | Why                                                                            |
| -------------------------------- | ---------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| `pubspec.yaml`                 | Added`flutter_local_notifications: ^18.0.0`                          | Package was used in code but missing from dependencies                         |
| `android/app/build.gradle.kts` | Added`isCoreLibraryDesugaringEnabled = true` in `compileOptions`   | Required for plugins that use Java 8+ time APIs on Android < 26                |
| `android/app/build.gradle.kts` | Added`dependencies { coreLibraryDesugaring(...) }` block             | Provides the actual backported`java.time.*` implementations                  |
| `notification_service.dart`    | Removed`android != null` guard; added `DarwinNotificationDetails`  | Foreground notifications were silently dropped on iOS                          |
| `android/build.gradle.kts`     | **Nothing** — two approaches tried and reverted (see Section 6) | Any root-level`JavaCompile` override breaks AGP 8.9.1's lazy classpath setup |

### Correct order to apply the real fixes

```
1. pubspec.yaml          → add flutter_local_notifications → flutter pub get
2. build.gradle.kts      → enable desugaring flag + add dependency
3. notification_service  → remove android-only guard, add DarwinNotificationDetails
4. flutter clean && flutter run --flavor development
```

### Known remaining warnings (accepted, not fixable)

```
warning: [options] source value 8 is obsolete and will be removed in a future release
warning: [options] target value 8 is obsolete and will be removed in a future release
```

These come from third-party plugin packages. They cannot be suppressed from this project's root build file without breaking the Android bootclasspath setup (see Section 6). They are harmless and do not affect the build output.

---

*Document written for the `features/notifications` branch — GroundScope Graduation Project.*
