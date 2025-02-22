//
//  Equalizer.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 5/31/15.
//  Copyright (c) 2015 Douglas Adams, K3TZR
//

import Foundation

//import SharedFeature

@MainActor
@Observable
public final class Equalizer: Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization

  public init(_ id: String) {
    self.id = id
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: String

  public var eqEnabled = false
  public var hz63: Int = 0
  public var hz125: Int = 0
  public var hz250: Int = 0
  public var hz500: Int = 0
  public var hz1000: Int = 0
  public var hz2000: Int = 0
  public var hz4000: Int = 0
  public var hz8000: Int = 0
  
//  public enum Kind: String {
//    case rx = "rxsc"
//    case tx = "txsc"
//  }

  // ----------------------------------------------------------------------------
  // MARK: - Public types
  
  public enum Property: String {
    // properties received from the radio
    case hz63   = "63hz"
    case hz125  = "125hz"
    case hz250  = "250hz"
    case hz500  = "500hz"
    case hz1000 = "1000hz"
    case hz2000 = "2000hz"
    case hz4000 = "4000hz"
    case hz8000 = "8000hz"
    case eqEnabled = "mode"
  }

  public enum AltProperty: String {
    // properties sent to the radio
    case hz63   = "63Hz"
    case hz125  = "125Hz"
    case hz250  = "250Hz"
    case hz500  = "500Hz"
    case hz1000 = "1000Hz"
    case hz2000 = "2000Hz"
    case hz4000 = "4000Hz"
    case hz8000 = "8000Hz"
    case eqEnabled = "mode"
  }

//  static let altProperty: [Property : String] = [
//    // alternate properties REQUIRED when sending to the radio
//    .hz63 : "63Hz",
//    .hz125 : "125Hz",
//    .hz250 : "250Hz",
//    .hz500 : "500Hz",
//    .hz1000 : "1000Hz",
//    .hz2000 : "2000Hz",
//    .hz4000 : "4000Hz",
//    .hz8000 : "8000Hz"
//  ]

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _initialized = false

  // ----------------------------------------------------------------------------
  // MARK: - Public Static status method
  
  public static func status(_ objectModel: ObjectModel, _ properties: KeyValuesArray, _ inUse: Bool) {
    // get the id
    let id = properties[0].key
    if id == "tx" || id == "rx" { return } // legacy equalizer ids, ignore
    let index = objectModel.equalizers.firstIndex(where: { $0.id == id })
    // is it in use?
    if inUse {
      if index == nil {
        objectModel.equalizers.append(Equalizer(id))
        objectModel.equalizers.last!.parse(Array(properties.dropFirst(1)) )
      } else {
        // parse the properties
        objectModel.equalizers[index!].parse(Array(properties.dropFirst(1)) )
      }


    } else {
      // NO, remove it
      objectModel.equalizers.remove(at: index!)
      log.debug("Equalizer \(id): REMOVED")
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static command methods
  
  /* ----- from the FlexApi source -----
   eq " + id + "mode="   + 1/0
   eq " + id + "32Hz="   + hz32
   eq " + id + "63Hz="   + hz63
   eq " + id + "125Hz="  + hz125
   eq " + id + "250Hz="  + hz250
   eq " + id + "500Hz="  + hz500
   eq " + id + "1000Hz=" + hz1000
   eq " + id + "2000Hz=" + hz2000
   eq " + id + "4000Hz=" + hz4000
   eq " + id + "8000Hz=" + hz8000
   eq " + id + "info"
   eq apf gain=" + apfGain
   eq apf mode=" + apfMode
   eq apf qfactor=" + apfQFactor
   */

  public static func set(id: String, property: Property, value: String) -> String {
    "eq \(id) \(property.rawValue)=\(value)"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Parse methods
  
  /// Parse key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = Equalizer.Property(rawValue: property.key) else {
        // log it and ignore the Key
        log.warning("Equalizer: unknown property, \(property.key) = \(property.value)")
        continue
      }
      // known keys
      switch token {
        
      case .hz63:      hz63 = property.value.iValue
      case .hz125:    hz125 = property.value.iValue
      case .hz250:    hz250 = property.value.iValue
      case .hz500:    hz500 = property.value.iValue
      case .hz1000:  hz1000 = property.value.iValue
      case .hz2000:  hz2000 = property.value.iValue
      case .hz4000:  hz4000 = property.value.iValue
      case .hz8000:  hz8000 = property.value.iValue
        
      case .eqEnabled:        eqEnabled = property.value.bValue
      }
      // is it initialized?
      if _initialized == false {
        // NO, it is now
        _initialized = true
        log.debug("Equalizer: ADDED")
      }
    }
  }

  /* ----- from FlexApi -----
   eq " + id + "mode="   + 1/0
   eq " + id + "32Hz="   + hz32
   eq " + id + "63Hz="   + hz63
   eq " + id + "125Hz="  + hz125
   eq " + id + "250Hz="  + hz250
   eq " + id + "500Hz="  + hz500
   eq " + id + "1000Hz=" + hz1000
   eq " + id + "2000Hz=" + hz2000
   eq " + id + "4000Hz=" + hz4000
   eq " + id + "8000Hz=" + hz8000
   eq " + id + "info"
   eq apf gain=" + apfGain
   eq apf mode=" + apfMode
   eq apf qfactor=" + apfQFactor
   */
}
