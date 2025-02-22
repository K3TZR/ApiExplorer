//
//  DaxIq.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 3/9/17.
//  Copyright © 2017 Douglas Adams & Mario Illgen. All rights reserved.
//

import Foundation

//import SharedFeature
//import VitaFeature


// DaxIq Class implementation
//      creates an DaxIq instance to be used by a Client to support the
//      processing of a UDP stream of IQ data from the Radio to the client. DaxIq
//      objects are added / removed by TCP messages. They are collected
//      in the objectModel.daxIqs collection.
@MainActor
@Observable
public final class DaxIq {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init() {}
  
  // ------------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var delegate: StreamHandler?
  
  public var channel = 0
  public var clientHandle: UInt32 = 0
  public var ip = ""
  public var isActive = false
  public var pan: UInt32 = 0
  public var rate = 0
  
  
  // ------------------------------------------------------------------------------
  // MARK: - Public types
  
  public enum Property: String {
    case channel        = "daxiq_channel"
    case clientHandle   = "client_handle"
    case ip
    case isActive       = "active"
    case pan
    case rate           = "daxiq_rate"
    case type
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _initialized = false
  
  private var _rxPacketCount      = 0
  private var _rxLostPacketCount  = 0
  private var _txSampleCount      = 0
  private var _rxSequenceNumber   = -1

  // ----------------------------------------------------------------------------
  // MARK: - Public static methods
  
  public static func status(_ objectModel: ObjectModel, _ properties: KeyValuesArray) {
    // get the id
    if let id = properties[0].key.streamId {
      // add it if not already present
      if objectModel.daxIqs[id] == nil { objectModel.daxIqs[id] = DaxIq() }
      // parse the properties
      objectModel.daxIqs[id]!.parse( Array(properties.dropFirst(1)) )
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Parse key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      
      guard let token = Property(rawValue: property.key) else {
        // unknown Key, log it and ignore the Key
        log.warning("DaxIq: unknown property, \(property.key) = \(property.value)")
        continue
      }
      // known keys, in alphabetical order
      switch token {
        
      case .clientHandle:     clientHandle = property.value.handle ?? 0
      case .channel:          channel = property.value.iValue
      case .ip:               ip = property.value
      case .isActive:         isActive = property.value.bValue
      case .pan:              pan = property.value.streamId ?? 0
      case .rate:             rate = property.value.iValue
      case .type:             break  // included to inhibit unknown token warnings
      }
    }
    // is it initialized?
    if _initialized == false && clientHandle != 0 {
      // NO, it is now
      _initialized = true
      log.debug("DaxIq ADDED: channel = \(self.channel)")
    }
  }
}
