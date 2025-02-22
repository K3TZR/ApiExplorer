//
//  Gps.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 8/15/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

//import SharedFeature


@MainActor
@Observable
public final class Gps {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init() {}

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var altitude = ""
  public var frequencyError: Double = 0
  public var grid = ""
  public var installed = false
  public var latitude = ""
  public var longitude = ""
  public var speed = ""
  public var time = ""
  public var track: Double = 0
  public var tracked = false
  public var visible = false

  // ----------------------------------------------------------------------------
  // MARK: - Public types
  
  public  enum Property: String {
    case altitude
    case frequencyError = "freq_error"
    case grid
    case latitude = "lat"
    case longitude = "lon"
    case speed
    case installed = "status"
    case time
    case track
    case tracked
    case visible
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  public var _initialized = false

  // ----------------------------------------------------------------------------
  // MARK: - Public Parse methods
  
  /// Parse a Gps status message
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // Check for Unknown Keys
      guard let token = Gps.Property(rawValue: property.key)  else {
        // log it and ignore the Key
        log.warning("Gps: unknown property, \(property.key) = \(property.value)")
        continue
      }
      // Known tokens, in alphabetical order
      switch token {
      case .altitude:       altitude = property.value
      case .frequencyError: frequencyError = property.value.dValue
      case .grid:           grid = property.value
      case .installed:      installed = property.value == "present" ? true : false
      case .latitude:       latitude = property.value
      case .longitude:      longitude = property.value
      case .speed:          speed = property.value
      case .time:           time = property.value
      case .track:          track = property.value.dValue
      case .tracked:        tracked = property.value.bValue
      case .visible:        visible = property.value.bValue
      }
    }
    // is it initialized?
    if _initialized == false{
      // NO, it is now
      _initialized = true
      log.debug("Gps: initialized")
    }
  }
}
