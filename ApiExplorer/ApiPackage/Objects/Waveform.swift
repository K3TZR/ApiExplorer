//
//  Waveform.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 8/17/17.
//

import Foundation

//import SharedFeature


@MainActor
@Observable
public final class Waveform {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization

  public init() {}

  // ----------------------------------------------------------------------------
  // MARK: - Public properties

  public var list = ""

  // ----------------------------------------------------------------------------
  // MARK: - Public types
  
  public enum Property: String {
    case list = "installed_list"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _initialized  = false

  // ----------------------------------------------------------------------------
  // MARK: - Public Static command methods
  
  /* ----- from the FlexApi source -----
   "waveform uninstall " + waveform_name
   */

  public static func uninstall(name: String) -> String {
    "waveform uninstall \(name)"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Parse methods
  
  /// Parse a Waveform status message
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // Check for Unknown Keys
      guard let token = Waveform.Property(rawValue: property.key)  else {
        // log it and ignore the Key
        log.warning("Waveform: unknown property, \(property.key) = \(property.value)")
        continue
      }
      // Known tokens, in alphabetical order
      switch token {
        
      case .list:   list = property.value
      }
    }
    // is it initialized?
    if _initialized == false {
      // NO, it is now
      _initialized = true
      log.debug("Waveform: initialized")
    }
  }
}
