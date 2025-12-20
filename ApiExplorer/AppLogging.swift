//
//  AppLogging.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 4/18/25.
//

import Foundation
import os

import ApiPackage

//public enum LogLevel: String, Codable {
//  case debug, info, warning, propertyWarning, error
//}

public func appLog(_ level: LogLevel, _ message: String, _ key: String = "") {
  switch level {
  case .debug: Task { await AppLog.shared.debug(message) }
  case .info: Task { await AppLog.shared.info(message) }
  case .warning:  Task { await AppLog.shared.warning(message) }
  case .propertyWarning: Task { await AppLog.shared.propertyWarning(message, key) }
  case .error: Task { await AppLog.shared.error(message) }
  }
}

public actor AppLog: LoggingActor {
  private let _logger: Logger
  
  public static let shared = AppLog()
  
  private init() {
    _logger = Logger(subsystem: "net.k3tzr.ApiExplorer", category: "Application")
  }
  
  public func debug(_ message: String) async {
    _logger.debug("\(message)")
  }
  
  public func info(_ message: String) async {
    _logger.info("\(message)")
  }
  
  public func warning(_ message: String) async {
    _logger.warning("\(message)")
    NotificationCenter.default.post(
      name: Notification.Name.logAlertWarning,
      object: AlertInfo("A Warning has been logged", message)
    )
  }
  public func propertyWarning(_ message: String, _ key: String) async {
    _logger.warning("\(message)")
    NotificationCenter.default.post(
      name: Notification.Name.logAlertWarning,
      object: AlertInfo("A Warning has been logged", message)
    )
  }

  public func error(_ message: String) async {
    _logger.error("\(message)")
    NotificationCenter.default.post(
      name: Notification.Name.logAlertError,
      object: AlertInfo("An Error has been logged", message)
    )
  }
}

//extension AppLog {
//  public static func debug(_ message: String) async {
//    await shared.debug(message)
//  }
//  public static func info(_ message: String) async {
//    await shared.info(message)
//  }
//  public static func warning(_ message: String) async {
//    await shared.warning(message)
//  }
//  public static func propertyWarning(_ key: String, _ message: String) async {
//    await shared.propertyWarning(key, message)
//  }
//  public static func error(_ message: String) async {
//    await shared.error(message)
//  }
//}
