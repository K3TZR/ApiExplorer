//
//  BandSetting.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 4/6/19.
//  Copyright © 2019 Douglas Adams. All rights reserved.
//

import Foundation

//import SharedFeature


@MainActor
@Observable
public final class BandSetting: Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization

  public init(_ id: UInt32) {
    self.id = id
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: UInt32
  
  public var accTxEnabled: Bool = false
  public var accTxReqEnabled: Bool = false
  public var name = 999
  public var hwAlcEnabled: Bool = false
  public var inhibit: Bool = false
  public var rcaTxReqEnabled: Bool = false
  public var rfPower: Int = 0
  public var tunePower: Int = 0
  public var tx1Enabled: Bool = false
  public var tx2Enabled: Bool = false
  public var tx3Enabled: Bool  = false

  // ------------------------------------------------------------------------------
  // MARK: - Public types
  
  public enum Property: String {
    // transmit
    case hwAlcEnabled       = "hwalc_enabled" //
    case inhibit            //
    case rfPower            = "rfpower" //
    case tunePower          = "tunepower" //
    // interlock
    case accTxEnabled       = "acc_tx_enabled"
    case accTxReqEnabled    = "acc_txreq_enable"
    case rcaTxReqEnabled    = "rca_txreq_enable"
    case tx1Enabled         = "tx1_enabled"
    case tx2Enabled         = "tx2_enabled"
    case tx3Enabled         = "tx3_enabled"

    case name               = "band_name"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  public var _initialized = false

  // ----------------------------------------------------------------------------
  // MARK: - Public Static status method
  
  public static func status(_ objectModel: ObjectModel, _ properties: KeyValuesArray, _ inUse: Bool) {
    // get the id
    if let id = properties[0].key.objectId {
      let index = objectModel.bandSettings.firstIndex(where: { $0.id == id })
      // is it in use?
      if inUse {
        if index == nil {
          objectModel.bandSettings.append(BandSetting(id))
          objectModel.bandSettings.last!.parse(Array(properties.dropFirst(1)) )
        } else {
          // parse the properties
          objectModel.bandSettings[index!].parse(Array(properties.dropFirst(1)) )
        }

      } else {
        // NO, remove it
        objectModel.bandSettings.remove(at: index!)
        log.debug("BandSetting \(id): REMOVED")
      }
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static command methods

  /* ----- from the FlexApi source -----
   "transmit bandset {BandId} hwalc_enabled={Convert.ToByte(_isHwAlcEnabled)}"
   "transmit bandset {BandId} inhibit={Convert.ToByte(_isPttInhibit)}"
   "transmit bandset {BandId} rfpower={_powerLevel}"
   "transmit bandset {BandId} tunepower={_tuneLevel}"
   
   "interlock bandset {BandId} acc_tx_enabled={Convert.ToByte(_isAccTxEnabled)}"
   "interlock bandset {BandId} acc_txreq_enable={Convert.ToByte(_isAccTxReqEnabled)}")
   "interlock bandset {BandId} rca_txreq_enable={Convert.ToByte(_isRcaTxReqEnabled)}"
   "interlock bandset {BandId} tx1_enabled={Convert.ToByte(_isRcaTx1Enabled)}"
   "interlock bandset {BandId} tx2_enabled={Convert.ToByte(_isRcaTx2Enabled)}"
   "interlock bandset {BandId} tx3_enabled={Convert.ToByte(_isRcaTx3Enabled)}"
   */

  public static func set(id: UInt32, property: Property, value: String) -> String {
    switch property {
    case .hwAlcEnabled, .inhibit, .rfPower, .tunePower: 
      "transmit bandset \(id) \(property.rawValue)=\(value)"
    default:  
      "interlock bandset \(id) \(property.rawValue)=\(value)"
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Parse methods
  
  /// Parse BandSetting key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = BandSetting.Property(rawValue: property.key) else {
        // log it and ignore the Key
        log.warning("BandSetting: unknown property, \(property.key) = \(property.value)")
        continue
      }
      // known keys
      switch token {
        
      case .accTxEnabled:     accTxEnabled = property.value.bValue
      case .accTxReqEnabled:  accTxReqEnabled = property.value.bValue
      case .name:             name = property.value == "GEN" ? 999 : property.value.iValue
      case .hwAlcEnabled:     hwAlcEnabled = property.value.bValue
      case .inhibit:          inhibit = property.value.bValue
      case .rcaTxReqEnabled:  rcaTxReqEnabled = property.value.bValue
      case .rfPower:          rfPower = property.value.iValue
      case .tunePower:        tunePower = property.value.iValue
      case .tx1Enabled:       tx1Enabled = property.value.bValue
      case .tx2Enabled:       tx2Enabled = property.value.bValue
      case .tx3Enabled:       tx3Enabled = property.value.bValue
      }
      // is it initialized?
      if _initialized == false {
        // NO, it is now
        _initialized = true
        log.debug("BandSetting: ADDED, name = \(self.name)")
      }
    }
  }
}
