# Seanime_TV

Native Apple TV (tvOS) client for Seanime, built with Swift/SwiftUI.

## Prerequisites
- Xcode 15+
- macOS

## How to use
1. Open Xcode and create a new "App" project for the **tvOS** platform.
2. Name the project `Seanime_TV`.
3. Delete the default generated files (`ContentView.swift`, etc.).
4. Drag and drop the `App`, `Core`, `Models`, `ViewModels`, and `Views` folders from this directory into your Xcode project.
5. In Xcode, ensure that `Seanime_TVApp.swift` is set as the main entry point.
6. In `Core/Constants.swift`, replace `127.0.0.1` with the local IP address of the machine running the Seanime server (e.g., `192.168.1.50`).
7. Start the Seanime server.
8. Build and run the app on an Apple TV simulator or your physical Apple TV!
