# DNSBaseStage Release Notes

All notable changes to DNSBaseStage are documented here. Versions follow [Semantic Versioning](https://semver.org/).

---

## 1.12.5 — 2026-04-21

**Release Type**
-   BUGFIX

**Issues Resolved**
-   **XDNS-0009** — `DNSBaseStageViewController.displayTitle(_:)` is now properly overridable from cross-module subclasses. Previously the method was declared `public` inside an extension, which forces Swift static dispatch regardless of access modifier. Consumer `override func displayTitle` declarations compiled without error but never dispatched to the subclass — the superclass's extension method always ran instead. This fix moves `displayTitle(_:)` into the class body with `open` access, restoring dynamic dispatch via vtable so overrides actually fire.
-   Fixes root cause behind production crashes **#3464** and **#3855**, allowing consumer apps to drop the `DispatchQueue.main` FIFO workaround introduced in MainEventApp PR #634.

**New Features**
-   NONE (behavior change is override mechanics only; the method's public signature and runtime behavior for non-overriding callers is unchanged)

**Technical Improvements**
-   Added DocC documentation on `displayTitle(_:)` with `- Important:` callout describing the override contract (main-thread guarantee via `DNSUIThread.run`).
-   Added `DNSBaseStageViewControllerOverrideTests` with three cross-module override tests validating dispatch semantics. Tests use a separate private subclass (not `@testable import`) to exercise the real `public`/`open` boundary.
-   Committed a proper shared `.swiftpm/xcode/xcshareddata/xcschemes/DNSBaseStage.xcscheme` with a `TestAction` configured — enables `xcodebuild test` from CLI and unblocks future CI. Previously the auto-generated scheme had no test action configured.
-   Narrowed `.gitignore` entry for `/.swiftpm` to track the `xcshareddata/xcschemes/` subdirectory while still ignoring user-specific state.

**Known Problems**
-   iOS Simulator test bootstrap crash with SEGV on Xcode 26.3 beta — environmental issue unrelated to this release. Tests pass reliably on Mac Catalyst (`platform=macOS,variant=Mac Catalyst`).
-   49 pre-existing test failures in unmodified test files (DNSBaseStageFormViewTests, DNSCoordinatorTests, etc.) are newly visible now that the scheme has a TestAction — these are existing framework issues, not regressions from this release. See [PR #2](https://github.com/DoubleNode/DNSBaseStage/pull/2) for the full pre-existing failure inventory.

---
