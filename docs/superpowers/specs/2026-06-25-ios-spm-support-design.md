# iOS Swift Package Manager Support Design

Date: 2026-06-25

## Goal

Add Swift Package Manager support for the iOS side of the `getuiflut` Flutter plugin while preserving the existing CocoaPods integration and existing Objective-C source layout.

The work is iOS-only. It does not add macOS support and does not change Dart, Android, or OHOS APIs.

## Context

The plugin currently declares an iOS Flutter plugin in `pubspec.yaml`, implements the native plugin in `ios/Classes/GetuiflutPlugin.h` and `ios/Classes/GetuiflutPlugin.m`, and exposes CocoaPods metadata through `ios/getuiflut.podspec`.

The podspec depends on:

- `Flutter`
- `GTSDK`

Flutter's current plugin-author guidance recommends adding SwiftPM compatibility for iOS/macOS plugins while continuing to support CocoaPods. The fully recommended layout moves native sources under `ios/<plugin>/Sources/<plugin>`, but this design intentionally chooses a lower-intrusion path to avoid moving existing files.

GTSDK already provides a SwiftPM package at:

`https://github.com/GetuiLaboratory/getui-sdk-ios-cocoapods.git`

## Selected Approach

Use a low-intrusion SwiftPM package under `ios/getuiflut/` while keeping `ios/Classes` as the source of truth.

The new package will:

- Add `ios/getuiflut/Package.swift`.
- Declare an iOS-only SwiftPM package named `getuiflut`.
- Build a static library product named `getuiflut`.
- Define a target named `getuiflut`.
- Point the target at the existing parent `ios` directory with explicit source and header paths.
- Compile `Classes/GetuiflutPlugin.m` without moving it.
- Expose `Classes/GetuiflutPlugin.h` as the Objective-C public plugin header.
- Depend on Flutter's generated local `FlutterFramework` package.
- Depend on the official GTSDK SwiftPM package.

The CocoaPods path remains unchanged:

- `ios/getuiflut.podspec` continues to use `Classes/**/*`.
- `ios/getuiflut.podspec` continues to depend on `Flutter` and `GTSDK`.
- `ios/Classes` remains compatible with existing CocoaPods consumers.

## Package Structure

Target structure after the change:

```text
ios/
  Classes/
    GetuiflutPlugin.h
    GetuiflutPlugin.m
  getuiflut.podspec
  getuiflut/
    Package.swift
```

The SwiftPM package uses `ios/getuiflut` as the package root, but the target's path points to the parent `ios` directory. This is deliberate so SwiftPM can compile the existing `Classes` files without moving them.

## Package Manifest Design

`ios/getuiflut/Package.swift` will use Swift tools version 5.9 because Flutter's current SPM plugin-author template uses 5.9.

The package will include:

- `platforms: [.iOS(.v8)]` to match the existing podspec deployment target.
- `.library(name: "getuiflut", type: .static, targets: ["getuiflut"])` to align with `s.static_framework = true`.
- `.package(name: "FlutterFramework", path: "../FlutterFramework")` for Flutter.
- `.package(url: "https://github.com/GetuiLaboratory/getui-sdk-ios-cocoapods.git", branch: "master")` for GTSDK, matching the official GTSDK README guidance to use the `master` branch for SPM.
- A target with dependencies on `FlutterFramework` and `GTSDK`.
- `path: ".."` so target paths resolve from `ios`.
- `sources: ["Classes/GetuiflutPlugin.m"]`.
- `publicHeadersPath: "Classes"`.
- `cSettings: [.headerSearchPath("Classes")]` so quoted local imports can resolve consistently in SwiftPM builds.

This parent-directory target layout was validated with a minimal local SwiftPM package using `swift package dump-package`; SwiftPM accepted a package root in a child directory with a target path pointing to its parent directory.

## Compatibility

The implementation does not change plugin runtime behavior. The Objective-C imports remain:

- Local plugin header: `#import "GetuiflutPlugin.h"`
- GTSDK header: `#import <GTSDK/GeTuiSdk.h>`

Because the source location is unchanged, CocoaPods behavior should remain stable. Because SwiftPM compiles the same Objective-C source, API behavior should remain consistent across package managers.

## Risks

This design is less future-proof than Flutter's recommended full migration layout. Flutter documentation expects public Objective-C plugin headers to live in `Sources/<target>/include/<target>` for the canonical SwiftPM structure. Keeping files in `ios/Classes` depends on SwiftPM accepting explicit target paths and may be more sensitive to future Flutter tooling assumptions.

The GTSDK SwiftPM dependency is branch-based because the official GTSDK README recommends the `master` branch. This avoids guessing a tag/version policy, but branch-based resolution can change over time. CocoaPods currently resolves GTSDK through podspec semantics, so the exact GTSDK version used by CocoaPods and SwiftPM can diverge unless the project later pins an SPM revision or tag.

## Verification Plan

Run these checks after implementation:

- `swift package dump-package --package-path ios/getuiflut` to validate the SwiftPM manifest structure.
- `flutter test` or the repository's equivalent Dart test command to ensure Dart-side tests still pass.
- CocoaPods validation or an example iOS build with SwiftPM disabled, if the local environment allows Flutter SDK writes and CocoaPods dependency resolution.
- Example iOS build with SwiftPM enabled, if the local environment allows Flutter SDK writes and network dependency resolution.

If Flutter commands fail because the sandbox prevents writes into the Flutter SDK cache, rerun them with explicit user approval for escalated execution.
