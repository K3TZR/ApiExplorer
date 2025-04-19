//
//  AppLogging.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 4/18/25.
//

import Foundation
import os

import ApiPackage

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
      name: Notification.Name.logAlert,
      object: AlertInfo("WARNING logged", message)
    )
  }
  
  public func error(_ message: String) async {
    _logger.error("\(message)")
    NotificationCenter.default.post(
      name: Notification.Name.logAlert,
      object: AlertInfo("ERROR logged", message)
    )
  }
}

extension AppLog {
  public static func debug(_ message: String) async {
    await shared.debug(message)
  }
  public static func info(_ message: String) async {
    await shared.info(message)
  }
  public static func warning(_ message: String) async {
    await shared.warning(message)
  }
  public static func error(_ message: String) async {
    await shared.error(message)
  }
}
