////
////  ApiViewerApp.swift
////  ApiViewer
////
////  Created by Douglas Adams on 10/6/24.
////
//
//import SwiftUI
//import os
//
//@main
//struct ApiViewerApp: App {
//  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//  
//  @State var viewModel = ViewModel()
//
//  /// Struct to hold a Semantic Version number
//  private struct Version {
//    var major: Int = 1
//    var minor: Int = 0
//    var build: Int = 0
//    
//    // can be used directly in packages
//    init(_ versionString: String = "1.0.0") {
//      let components = versionString.components(separatedBy: ".")
//      major = Int(components[0]) ?? 1
//      minor = Int(components[1]) ?? 0
//      build = Int(components[2]) ?? 0
//    }
//    
//    // only useful for Apps & Frameworks (which have a Bundle), not Packages
//    init() {
//      let versions = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "?"
//      let build   = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as? String ?? "?"
//      self.init(versions + ".\(build)")
//    }
//    
//    var string: String { "\(major).\(minor).\(build)" }
//  }
//  
//  var body: some Scene {
//    WindowGroup("ApiViewer  (v" + Version().string + ")") {
//      ApiView()
//        .environment(viewModel)
//
//    }
//  }
//}
//
//// ----------------------------------------------------------------------------
//// MARK: - App Delegate
//
//final class AppDelegate: NSObject, NSApplicationDelegate {
//  
//  func applicationDidFinishLaunching(_ notification: Notification) {
//    // disable tab view
//    NSWindow.allowsAutomaticWindowTabbing = false
//    // disable restoring windows
//    UserDefaults.standard.register(defaults: ["NSQuitAlwaysKeepsWindows" : false])
//
//  }
//  
//  func applicationWillTerminate(_ notification: Notification) {
//    log.debug("ApiViewer: application terminated")
//  }
//  
//  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
//    true
//  }
//}
//
