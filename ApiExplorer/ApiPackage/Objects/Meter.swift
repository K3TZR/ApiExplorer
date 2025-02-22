//
//  Meter.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 6/2/15.
//  Copyright (c) 2015 Douglas Adams, K3TZR
//

import Foundation

//import SharedFeature
//import VitaFeature


@MainActor
public final class Meter: ObservableObject, Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization

  public init(_ id: UInt32) {
    self.id = id
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  @Published public var value: Float = 0    // uses ObservableObject to facilitate throttling

  public let id: UInt32

  public var desc: String = ""
  public var fps: Int = 0
  public var high: Float = 0
  public var low: Float = 0
  public var group: String = ""
  public var name: String = ""
  public var peak: Float = 0
  public var source: String = ""
  public var units: String = ""
  
//  public static var streamId: UInt32?
//  public static var isStreaming = false
  
  // ----------------------------------------------------------------------------
  // MARK: - Public types
  
  public enum Source: String {
    case codec      = "cod"
    case tx
    case slice      = "slc"
    case radio      = "rad"
    case amplifier  = "amp"
  }
  public enum ShortName: String, CaseIterable {
    case codecOutput            = "codec"
    case hwAlc                  = "hwalc"
    case microphoneAverage      = "mic"
    case microphoneOutput       = "sc_mic"
    case microphonePeak         = "micpeak"
    case postClipper            = "comppeak"
    case postFilter1            = "sc_filt_1"
    case postFilter2            = "sc_filt_2"
    case postGain               = "gain"
    case postRamp               = "aframp"
    case postSoftwareAlc        = "alc"
    case powerForward           = "fwdpwr"
    case powerReflected         = "refpwr"
    case preRamp                = "b4ramp"
    case preWaveAgc             = "pre_wave_agc"
    case preWaveShim            = "pre_wave"
    case signal24Khz            = "24khz"
    case signalPassband         = "level"
    case signalPostNrAnf        = "nr/anf"
    case signalPostAgc          = "agc+"
    case swr                    = "swr"
    case temperaturePa          = "patemp"
    case voltageAfterFuse       = "+13.8b"
    case voltageBeforeFuse      = "+13.8a"
  }
  
  public enum Property: String {
    case desc
    case fps
    case high       = "hi"
    case low
    case name       = "nam"
    case group      = "num"
    case source     = "src"
    case units      = "unit"
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  public var _initialized = false

  // ----------------------------------------------------------------------------
  // MARK: - Public Static status method
  
  public static func status(_ objectModel: ObjectModel, _ properties: KeyValuesArray, _ inUse: Bool) {
    // get the id
    if let id = UInt32(properties[0].key.components(separatedBy: ".")[0], radix: 10) {
      let index = objectModel.meters.firstIndex(where: { $0.id == id })
      // is it in use?
      if inUse {
        if index == nil {
          objectModel.meters.append(Meter(id))
          objectModel.meters.last!.parse(Array(properties.dropFirst(1)) )
        } else {
          // parse the properties
          objectModel.meters[index!].parse(Array(properties.dropFirst(1)) )
        }

      } else {
        // NO, remove it
        objectModel.meters.remove(at: index!)
        log.debug("Meter \(id): REMOVED")
      }
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Parse methods
  
  /// Parse Meter key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) {
    // process each key/value pair, <n.key=value>
    for property in properties {
      // separate the Meter Number from the Key
      let numberAndKey = property.key.components(separatedBy: ".")
      
      // get the Key
      let key = numberAndKey[1]
      
      // check for unknown Keys
      guard let token = Meter.Property(rawValue: key) else {
        // unknown, log it and ignore the Key
        log.warning("Meter: unknown property, \(property.key) = \(property.value)")
        continue
      }
      // known Keys, in alphabetical order
      switch token {
        
      case .desc:     desc = property.value
      case .fps:      fps = property.value.iValue
      case .high:     high = property.value.fValue
      case .low:      low = property.value.fValue
      case .name:     name = property.value.lowercased()
      case .group:    group = property.value
      case .source:   source = property.value.lowercased()
      case .units:    units = property.value.lowercased()
      }
    }
    // is it initialized?
    if _initialized == false && group != "" && units != "" {
      //NO, it is now
      _initialized = true
      log.debug("Meter: ADDED, name = \(self.name), source = \(self.source), group = \(self.group)")
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public set property methods
  
  public func setValue(_ value: Float) {
    self.value = value
  }  
}
