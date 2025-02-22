//
//  Xvtr.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 6/24/17.
//

import Foundation

//import SharedFeature


@MainActor
@Observable
public final class Xvtr {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: UInt32) {
    self.id = id
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public propertie
  
  public let id: UInt32
  
  public private(set) var isValid = false
  public private(set) var preferred = false
  public private(set) var twoMeterInt = 0
  public private(set) var ifFrequency: Hz = 0
  public private(set) var loError = 0
  public private(set) var name = ""
  public private(set) var maxPower = 0
  public private(set) var order = 0
  public private(set) var rfFrequency: Hz = 0
  public private(set) var rxGain = 0
  public private(set) var rxOnly = false

  // ----------------------------------------------------------------------------
  // MARK: - Public types
  
  public enum Property: String {
    case create
    case ifFrequency    = "if_freq"
    case isValid        = "is_valid"
    case loError        = "lo_error"
    case maxPower       = "max_power"
    case name
    case order
    case preferred
    case remove
    case rfFrequency    = "rf_freq"
    case rxGain         = "rx_gain"
    case rxOnly         = "rx_only"
    case twoMeterInt    = "two_meter_int"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _initialized = false

  // ----------------------------------------------------------------------------
  // MARK: - Public Static status method
  
  public static func status(_ objectModel: ObjectModel, _ properties: KeyValuesArray, _ inUse: Bool) {
    // get the id
    if let id = UInt32(properties[0].key, radix: 10) {
      let index = objectModel.xvtrs.firstIndex(where: { $0.id == id })
      // is it in use?
      if inUse {
        // YES, add it if not already present
        if index == nil {
          objectModel.xvtrs.append(Xvtr(id))
          objectModel.xvtrs.last!.parse(Array(properties.dropFirst(1)) )
        } else {
          // parse the properties
          objectModel.xvtrs[index!].parse(Array(properties.dropFirst(1)) )
        }
        
      } else {
        // NO, remove it
        objectModel.xvtrs.remove(at: index!)
        log.debug("Tnf \(id): REMOVED")
      }
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static command methods
  
  /* ----- from the FlexApi source -----
   xvtr create
   xvtr remove " + _index
   
   xvtr set " + _index + " name=" + _name
   xvtr set " + _index + " if_freq=" + StringHelper.DoubleToString(_ifFreq, "f6")
   xvtr set " + _index + " lo_error=" + StringHelper.DoubleToString(_loError, "f6")
   xvtr set " + _index + " max_power=" + StringHelper.DoubleToString(_maxPower, "f2")
   xvtr set " + _index + " order=" + _order
   xvtr set " + _index + " rf_freq=" + StringHelper.DoubleToString(_rfFreq, "f6")
   xvtr set " + _index + " rx_gain=" + StringHelper.DoubleToString(_rxGain, "f2")
   xvtr set " + _index + " rx_only=" + Convert.ToByte(_rxOnly)
   */
  public static func add() -> String {
    "xvtr create"
  }
  public static func remove(id: UInt32) -> String {
    "xvtr remove \(id.hex)"
  }
  public static func set(id: UInt32, property: Property, value: String) -> String {
    "xvtr set \(id.hex) \(property.rawValue)=\(value)"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Parse methods
  
  /// Parse Xvtr key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = Xvtr.Property(rawValue: property.key) else {
        // log it and ignore the Key
        log.warning("Xvtr: unknown property, \(property.key) = \(property.value)")
        continue
      }
      // Known keys, in alphabetical order
      switch token {
        
      case .name:         name = String(property.value.prefix(4))
      case .ifFrequency:  ifFrequency = property.value.mhzToHz
      case .isValid:      isValid = property.value.bValue
      case .loError:      loError = property.value.iValue
      case .maxPower:     maxPower = property.value.iValue
      case .order:        order = property.value.iValue
      case .preferred:    preferred = property.value.bValue
      case .rfFrequency:  rfFrequency = property.value.mhzToHz
      case .rxGain:       rxGain = property.value.iValue
      case .rxOnly:       rxOnly = property.value.bValue
      case .twoMeterInt:  twoMeterInt = property.value.iValue
        
      case .create:       break  // ignored here
      case .remove:       break  // ignored here
      }
    }
    // is it initialized?
    if _initialized == false {
      // NO, it is now
      _initialized = true
      log.debug("Xvtr: ADDED, name = \(self.name)")
    }
  }
}
