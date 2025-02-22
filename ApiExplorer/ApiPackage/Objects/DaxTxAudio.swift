//
//  DaxTxAudio.swift
//  FlexApiFeature/Objects
//
//  Created by Mario Illgen on 27.03.17.
//  Copyright © 2017 Douglas Adams & Mario Illgen. All rights reserved.
//

import AVFoundation
import Foundation

//import SharedFeature
//import VitaFeature


// DaxTxAudio
//      creates a DaxTxAudio instance to be used by a Client to support the
//      processing of a UDP stream of Tx Audio from the client to the Radio. The DaxTxAudio
//      is added / removed by TCP messages.
@MainActor
@Observable
public final class DaxTxAudio {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: UInt32) { self.id = id}
  
  // ------------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var id: UInt32
  public var delegate: DaxAudioInputHandler?
  
  public var clientHandle: UInt32 = 0
  public var ip = ""
  public var isTransmitChannel = false
  public var txGain = 0 {
    didSet { if txGain != oldValue {
      if txGain == 0 {
        txGainScalar = 0.0
        return
      }
      let db_min:Float = -10.0
      let db_max:Float = +10.0
      let db:Float = db_min + (Float(txGain) / 100.0) * (db_max - db_min)
      txGainScalar = pow(10.0, db / 20.0)
    }}}
  public var txGainScalar: Float = 0
  
  // ------------------------------------------------------------------------------
  // MARK: - Public types
  
  public enum Property: String {
    case clientHandle      = "client_handle"
    case ip
    case isTransmitChannel = "tx"
    case type
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _initialized = false
  private var _txSequenceNumber: UInt8 = 0
  private var _vita: Vita?

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  public static func status(_ objectModel: ObjectModel, _ properties: KeyValuesArray) {
    // get the id
    if let id = properties[0].key.streamId {
      // add it if not already present
      if objectModel.daxTxAudio == nil { objectModel.daxTxAudio = DaxTxAudio(id) }
      // parse the properties
      objectModel.daxTxAudio?.parse( Array(properties.dropFirst(1)) )
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Parse key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown keys
      guard let token = Property(rawValue: property.key) else {
        // unknown Key, log it and ignore the Key
        log.warning("DaxTxAudio: unknown property, \(property.key) = \(property.value)")
        continue
      }
      // known keys, in alphabetical order
      switch token {
        
      case .clientHandle:       clientHandle = property.value.handle ?? 0
      case .ip:                 ip = property.value
      case .isTransmitChannel:  isTransmitChannel = property.value.bValue
      case .type:               break  // included to inhibit unknown token warnings
      }
    }
    // is it initialized?
    if _initialized == false && clientHandle != 0 {
      // NO, it is now
      _initialized = true
      log.debug("DaxTxAudio ADDED: handle = \(self.clientHandle.hex)")
    }
  }
}
