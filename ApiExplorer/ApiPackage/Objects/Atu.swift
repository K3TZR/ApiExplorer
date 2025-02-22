//
//  Atu.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 8/15/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

//import SharedFeature


//@MainActor
@Observable
public final class Atu {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init() {}

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var enabled: Bool = false
  public var memoriesEnabled: Bool = false
  public var status: Status = .none
  public var usingMemory: Bool = false
  
  // ----------------------------------------------------------------------------
  // MARK: - Public types
  
  public enum Status: String {
    case none             = "NONE"
    case tuneNotStarted   = "TUNE_NOT_STARTED"
    case tuneInProgress   = "TUNE_IN_PROGRESS"
    case tuneBypass       = "TUNE_BYPASS"           // Success Byp
    case tuneSuccessful   = "TUNE_SUCCESSFUL"       // Success
    case tuneOK           = "TUNE_OK"
    case tuneFailBypass   = "TUNE_FAIL_BYPASS"      // Byp
    case tuneFail         = "TUNE_FAIL"
    case tuneAborted      = "TUNE_ABORTED"
    case tuneManualBypass = "TUNE_MANUAL_BYPASS"    // Byp
  }
  
  public enum Property: String {
    case status
    case enabled            = "atu_enabled"
    case memoriesEnabled    = "memories_enabled"
    case usingMemory        = "using_mem"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _initialized = false

  // ----------------------------------------------------------------------------
  // MARK: - Public Static command methods

  /* ----- from the FlexApi source -----
   "atu bypass"
   "atu clear"
   "atu set memories_enabled=" + Convert.ToByte(_atuMemoriesEnabled)
   "atu start"
   */

  public static func bypass() -> String {
    "atu bypass"
  }
  public static func clear() -> String {
    "atu clear"
  }
  public static func set(id: UInt32, property: Property, value: String) -> String {
    "atu set \(property.rawValue)=\(value)"
  }
  public static func start() -> String {
    "atu start"
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Parse methods
  
  /// Parse status message
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // Check for Unknown Keys
      guard let token = Atu.Property(rawValue: property.key)  else {
        // log it and ignore the Key
        log.warning("Atu: unknown property, \(property.key) = \(property.value)")
        continue
      }
      // Known tokens, in alphabetical order
      switch token {
        
      case .enabled:          enabled = property.value.bValue
      case .memoriesEnabled:  memoriesEnabled = property.value.bValue
      case .status:           status = Atu.Status(rawValue: property.value) ?? .none
      case .usingMemory:      usingMemory = property.value.bValue
      }
    }
    // is it initialized?
    if _initialized == false{
      // NO, it is now
      _initialized = true
      log.debug("Atu: initialized")
    }
  }
}
