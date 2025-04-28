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

  /// Struct to hold a Semantic Version number
  private struct Version {
    var major: Int = 1
    var minor: Int = 0
    var build: Int = 0
    
    // can be used directly in packages
    init(_ versionString: String = "1.0.0") {
      let components = versionString.components(separatedBy: ".")
      major = Int(components[0]) ?? 1
      minor = Int(components[1]) ?? 0
      build = Int(components[2]) ?? 0
    }
    
    // only useful for Apps & Frameworks (which have a Bundle), not Packages
    init() {
      let versions = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "?"
      let build   = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as? String ?? "?"
      self.init(versions + ".\(build)")
    }
    
    var string: String { "\(major).\(minor).\(build)" }
  }
  
  var body: some Scene {
    WindowGroup("ApiExplorer  (v" + Version().string + ")") {
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
