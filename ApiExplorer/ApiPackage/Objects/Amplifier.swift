//
//  Amplifier.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 8/7/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

//import SharedFeature


@MainActor
@Observable
public final class Amplifier: Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization

  public init(_ id: UInt32) {
    self.id = id
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: UInt32

  public var ant: String = ""
  public var antennaDict = [String:String]()
  public var handle: UInt32 = 0
  public var ip: String = ""
  public var model: String = ""
  public var port: Int = 0
  public var serialNumber: String = ""
  public var state: String = ""
  
  // ----------------------------------------------------------------------------
  // MARK: - Public types
  
  public enum Property: String {
    case ant
    case handle
    case ip
    case model
    case port
    case serialNumber  = "serial_num"
    case state
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  public var _initialized = false

  // ----------------------------------------------------------------------------
  // MARK: - Public Static status method
  
  public static func status(_ objectModel: ObjectModel, _ properties: KeyValuesArray, _ inUse: Bool) {
    // get the id
    if let id = properties[0].key.objectId {
      let index = objectModel.amplifiers.firstIndex(where: { $0.id == id })
      // is it in use?
      if inUse {
        if index == nil {
          objectModel.amplifiers.append(Amplifier(id))
          objectModel.amplifiers.last!.parse(Array(properties.dropFirst(1)) )
        } else {
          // parse the properties
          objectModel.amplifiers[index!].parse(Array(properties.dropFirst(1)) )
        }
        
      } else {
        // NO, remove it
        objectModel.amplifiers.remove(at: index!)
        log.debug("Amplifier \(id.hex): REMOVED")
      }
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static command methods
  
  //TODO:
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Parse methods
  
  /// Parse Tnf key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = Amplifier.Property(rawValue: property.key) else {
        // log it and ignore the Key
        log.warning("Amplifier: unknown propety, \(property.key) = \(property.value)")
        continue
      }
      // known keys
      switch token {
        
      case .ant:          ant = property.value ; antennaDict = antennaSettings( property.value)
      case .handle:       handle = property.value.handle ?? 0
      case .ip:           ip = property.value
      case .model:        model = property.value
      case .port:         port = property.value.iValue
      case .serialNumber: serialNumber = property.value
      case .state:        state = property.value
      }
      // is it initialized?
      if _initialized == false {
        // NO, it is now
        _initialized = true
        log.debug("Amplifier: ADDED, model = \(self.model)")
      }
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Helper methods
  
  /// Parse a list of antenna pairs
  /// - Parameter settings:     the list
  private func antennaSettings(_ settings: String) -> [String:String] {
    var antDict = [String:String]()
    
    // pairs are comma delimited
    let pairs = settings.split(separator: ",")
    // each setting is <ant:ant>
    for setting in pairs {
      if !setting.contains(":") { continue }
      let parts = setting.split(separator: ":")
      if parts.count != 2 {continue }
      antDict[String(parts[0])] = String(parts[1])
    }
    return antDict
  }
}
