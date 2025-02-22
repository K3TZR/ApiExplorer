//
//  Logging.swift
//
//
//  Created by Douglas Adams on 6/27/24.
//

import Foundation
import os

public let log = ApiLog()

public struct ApiLog: Sendable {
  
  private let apiLog = Logger(subsystem: "net.k3tzr.apiViewer", category: "Application")

  init() {}
  
  public func debug(_ message: String) {
    apiLog.debug("\(message)")
  }
  public func info(_ message: String) {
    apiLog.info("\(message)")
  }
  public func warning(_ message: String) {
    apiLog.warning("\(message)")
    NotificationCenter.default.post(name: Notification.Name.logAlert, object: AlertInfo("WARNING logged", message))
  }
  public func error(_ message: String) {
    apiLog.error("\(message)")
    NotificationCenter.default.post(name: Notification.Name.logAlert, object: AlertInfo("ERROR logged", message))
  }
}

extension Notification.Name {
  public static let logAlert = Notification.Name("LogAlert")
}

