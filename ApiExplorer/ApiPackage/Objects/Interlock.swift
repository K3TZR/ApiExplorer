//
//  Interlock.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 8/16/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

//import SharedFeature


@MainActor
@Observable
public final class Interlock {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init() {}
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var accTxEnabled = false
  public var accTxDelay = 0
  public var accTxReqEnabled = false
  public var accTxReqPolarity = false
  public var amplifier = ""
  public var rcaTxReqEnabled = false
  public var rcaTxReqPolarity = false
  public var reason = ""
  public var source = ""
  public var state = ""
  public var timeout = 0
  public var txAllowed = false
  public var txClientHandle: UInt32 = 0
  public var txDelay = 0
  public var tx1Enabled = false
  public var tx1Delay = 0
  public var tx2Enabled = false
  public var tx2Delay = 0
  public var tx3Enabled = false
  public var tx3Delay = 0

  // ----------------------------------------------------------------------------
  // MARK: - Public types
  
  public enum Property: String {
    case accTxEnabled       = "acc_tx_enabled"
    case accTxDelay         = "acc_tx_delay"
    case accTxReqEnabled    = "acc_txreq_enable"
    case accTxReqPolarity   = "acc_txreq_polarity"
    case amplifier
    case rcaTxReqEnabled    = "rca_txreq_enable"
    case rcaTxReqPolarity   = "rca_txreq_polarity"
    case reason
    case source
    case state
    case timeout
    case txAllowed          = "tx_allowed"
    case txClientHandle     = "tx_client_handle"
    case txDelay            = "tx_delay"
    case tx1Enabled         = "tx1_enabled"
    case tx1Delay           = "tx1_delay"
    case tx2Enabled         = "tx2_enabled"
    case tx2Delay           = "tx2_delay"
    case tx3Enabled         = "tx3_enabled"
    case tx3Delay           = "tx3_delay"
  }
  public enum States: String {
    case receive            = "RECEIVE"
    case ready              = "READY"
    case notReady           = "NOT_READY"
    case pttRequested       = "PTT_REQUESTED"
    case transmitting       = "TRANSMITTING"
    case txFault            = "TX_FAULT"
    case timeout            = "TIMEOUT"
    case stuckInput         = "STUCK_INPUT"
    case unKeyRequested     = "UNKEY_REQUESTED"
  }
  public enum PttSources: String {
    case software           = "SW"
    case mic                = "MIC"
    case acc                = "ACC"
    case rca                = "RCA"
  }
  public enum Reasons: String {
    case rcaTxRequest       = "RCA_TXREQ"
    case accTxRequest       = "ACC_TXREQ"
    case badMode            = "BAD_MODE"
    case tooFar             = "TOO_FAR"
    case outOfBand          = "OUT_OF_BAND"
    case paRange            = "PA_RANGE"
    case clientTxInhibit    = "CLIENT_TX_INHIBIT"
    case xvtrRxOnly         = "XVTR_RX_OLY"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _initialized = false

  // ----------------------------------------------------------------------------
  // MARK: - Public Static command methods

  /* ----- from FlexApi -----
   "interlock acc_tx_delay=" + _txACCDelay
   "interlock acc_tx_enabled=" + Convert.ToByte(_txACCEnabled)
   "interlock acc_txreq_enable=" + Convert.ToByte(_txreqACCEnabled)
   "interlock acc_txreq_polarity=" + Convert.ToByte(_txreqACCPolarity)
   "interlock rca_txreq_enable=" + Convert.ToByte(_txreqRCAEnabled)
   "interlock rca_txreq_polarity=" + Convert.ToByte(_txreqRCAPolarity)
   "interlock timeout=" + _interlockTimeout
   "interlock tx_delay=" + _delayTX
   "interlock tx1_enabled=" + Convert.ToByte(_tx1Enabled)
   "interlock tx2_enabled=" + Convert.ToByte(_tx2Enabled)
   "interlock tx3_enabled=" + Convert.ToByte(_tx3Enabled)
   "interlock tx1_delay=" + _tx1Delay
   "interlock tx2_delay=" + _tx2Delay
   "interlock tx3_delay=" + _tx3Delay
   */

  public static func set(id: Int, property: Property, value: String) -> String {
    "interlock \(property.rawValue)=\(value)"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Parse methods
  
  /// Parse status message
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) {
    // NO, process each key/value pair, <key=value>
    for property in properties {
      // Check for Unknown Keys
      guard let token = Interlock.Property(rawValue: property.key)  else {
        // log it and ignore the Key
        log.warning("Interlock: unknown property, \(property.key) = \(property.value)")
        continue
      }
      // Known tokens, in alphabetical order
      switch token {
        
      case .accTxEnabled:     accTxEnabled = property.value.bValue
      case .accTxDelay:       accTxDelay = property.value.iValue
      case .accTxReqEnabled:  accTxReqEnabled = property.value.bValue
      case .accTxReqPolarity: accTxReqPolarity = property.value.bValue
      case .amplifier:        amplifier = property.value
      case .rcaTxReqEnabled:  rcaTxReqEnabled = property.value.bValue
      case .rcaTxReqPolarity: rcaTxReqPolarity = property.value.bValue
      case .reason:           reason = property.value
      case .source:           source = property.value
      case .state:            state = property.value
      case .timeout:          timeout = property.value.iValue
      case .txAllowed:        txAllowed = property.value.bValue
      case .txClientHandle:   txClientHandle = property.value.handle ?? 0
      case .txDelay:          txDelay = property.value.iValue
      case .tx1Delay:         tx1Delay = property.value.iValue
      case .tx1Enabled:       tx1Enabled = property.value.bValue
      case .tx2Delay:         tx2Delay = property.value.iValue
      case .tx2Enabled:       tx2Enabled = property.value.bValue
      case .tx3Delay:         tx3Delay = property.value.iValue
      case .tx3Enabled:       tx3Enabled = property.value.bValue
      }
    }
    // is it initialized?
    if _initialized == false {
      // NO, it is now
      _initialized = true
      log.debug("Interlock: initialized")
    }
  }
}
