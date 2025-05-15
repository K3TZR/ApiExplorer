//
//  ApiExplorerApp.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 2/21/25.
//

import SwiftUI
import os

import ApiPackage

@main
struct ApiExplorerApp: App {
#if os(macOS)
@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#else
@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif

  @State var viewModel = ViewModel(SettingsModel())

  var body: some Scene {
    WindowGroup() {
      ApiView()
        .environment(viewModel)
    }
#if os(macOS)
    .commands {
        CommandGroup(replacing: .newItem) {
            Button("Font") {
              var currentSize = viewModel.settings.fontSize
              currentSize += 1
              viewModel.settings.fontSize = currentSize.bracket(8, 14)
            }
            .keyboardShortcut("+", modifiers: .command)
        }
    }
#endif
    
#if os(macOS)
    Settings {
      SettingsView()
        .environment(viewModel)
    }
#endif
  }
}

// ----------------------------------------------------------------------------
// MARK: - App Delegate

#if os(macOS)
import AppKit
final class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApplication.shared.windows.forEach { $0.tabbingMode = .disallowed }
    UserDefaults.standard.register(defaults: ["NSQuitAlwaysKeepsWindows": false])
  }
  
  func applicationWillFinishLaunching(_ notification: Notification) {

  }
  
  func applicationWillTerminate(_ notification: Notification) {
    Task { await AppLog.info("ApiExplorer (macOS): application terminated") }
  }
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }
}

#else
import UIKit
final class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    return true
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    Task { await AppLog.info("ApiExplorer (iOS): application terminated") }
  }
}
#endif
