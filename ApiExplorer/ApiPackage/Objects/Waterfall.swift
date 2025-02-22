//
//  Waterfall.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 5/31/15.
//

import Foundation

//import SharedFeature
//import VitaFeature


@MainActor
@Observable
public final class Waterfall: Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization

  public init(_ id: UInt32) {
    self.id = id
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: UInt32

  public var autoBlackEnabled = false
  public var autoBlackLevel: UInt32 = 0
  public var blackLevel = 0
  public var clientHandle: UInt32 = 0
  public var colorGain = 0
  public var gradientIndex = 0
  public var lineDuration = 0
  public var panadapterId: UInt32?
  
  public var selectedGradient = Waterfall.gradients[0]

  public static let gradients = [
    "Basic",
    "Dark",
    "Deuteranopia",
    "Grayscale",
    "Purple",
    "Tritanopia"
  ]

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _initialized = false

  // ----------------------------------------------------------------------------
  // MARK: - Public types
    
  public enum Property: String {
    case clientHandle         = "client_handle"   // New Api only
    
    // on Waterfall
    case autoBlackEnabled     = "auto_black"
    case blackLevel           = "black_level"
    case colorGain            = "color_gain"
    case gradientIndex        = "gradient_index"
    case lineDuration         = "line_duration"
    
    // unused here
    case available
    case band
    case bandZoomEnabled      = "band_zoom"
    case bandwidth
    case capacity
    case center
    case daxIq                = "daxiq"
    case daxIqChannel         = "daxiq_channel"
    case daxIqRate            = "daxiq_rate"
    case loopA                = "loopa"
    case loopB                = "loopb"
    case panadapterId         = "panadapter"
    case rfGain               = "rfgain"
    case rxAnt                = "rxant"
    case segmentZoomEnabled   = "segment_zoom"
    case wide
    case xPixels              = "x_pixels"
    case xvtr
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static status method
  
  public static func status(_ objectModel: ObjectModel, _ properties: KeyValuesArray, _ inUse: Bool) {
    // get the id
    if let id = properties[0].key.streamId {
      let index = objectModel.waterfalls.firstIndex(where: { $0.id == id })
      // is it in use?
      if inUse {
        // YES, add it if not already present
        if index == nil {
          objectModel.waterfalls.append(Waterfall(id))
          objectModel.waterfalls.last!.parse(Array(properties.dropFirst(1)) )
        } else {
          // parse the properties
          objectModel.waterfalls[index!].parse(Array(properties.dropFirst(1)) )
        }

      } else {
        // NO, remove it
        objectModel.waterfalls.remove(at: index!)
        log.debug("Waterfall \(id.hex): REMOVED")
      }
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static command methods
  
  /* ----- from the FlexApi source -----
   display panafall set 0x" + _stream_id.ToString("X") + " rxant=" + _rxant);
   display panafall set 0x" + _stream_id.ToString("X") + " rfgain=" + _rfGain);
   display panafall set 0x" + _stream_id.ToString("X") + " daxiq_channel=" + _daxIQChannel);
   display panafall set 0x" + _stream_id.ToString("X") + " fps=" + value);
   display panafall set 0x" + _stream_id.ToString("X") + " average=" + value);
   display panafall set 0x" + _stream_id.ToString("x") + " weighted_average=" + Convert.ToByte(_weightedAverage));
   display panafall set 0x" + _stream_id.ToString("X") + " loopa=" + Convert.ToByte(_loopA));
   display panafall set 0x" + _stream_id.ToString("X") + " loopb=" + Convert.ToByte(_loopB));
   display panafall set 0x" + _stream_id.ToString("X") + " line_duration=" + _fallLineDurationMs.ToString());
   display panafall set 0x" + _stream_id.ToString("X") + " black_level=" + _fallBlackLevel.ToString());
   display panafall set 0x" + _stream_id.ToString("X") + " color_gain=" + _fallColorGain.ToString());
   display panafall set 0x" + _stream_id.ToString("X") + " auto_black=" + Convert.ToByte(_autoBlackLevelEnable));
   display panafall set 0x" + _stream_id.ToString("X") + " gradient_index=" + _fallGradientIndex.ToString());
   display panafall remove 0x" + _stream_id.ToString("X"));
   */

  public static func remove(id: UInt32) -> String {
    "display panafall remove \(id.hex)"
  }
  public static func set(id: UInt32, property: Property, value: String) -> String {
    "display panafall set \(id.hex) \(property.rawValue)=\(value)"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Parse methods
  
  /// Parse Waterfall properties
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = Waterfall.Property(rawValue: property.key) else {
        // log it and ignore the Key
        log.warning("Waterfall: unknown property, \(property.key) = \(property.value)")
        continue
      }
      // Known keys, in alphabetical order
      switch token {
        
      case .autoBlackEnabled:   autoBlackEnabled = property.value.bValue
      case .blackLevel:         blackLevel = property.value.iValue
      case .clientHandle:       clientHandle = property.value.handle ?? 0
      case .colorGain:          colorGain = property.value.iValue
      case .gradientIndex:      gradientIndex = property.value.iValue
      case .lineDuration:       lineDuration = property.value.iValue
      case .panadapterId:       panadapterId = property.value.streamId ?? 0
        // the following are ignwater.ored here
      case .available, .band, .bandwidth, .bandZoomEnabled, .capacity, .center, .daxIq, .daxIqChannel,
          .daxIqRate, .loopA, .loopB, .rfGain, .rxAnt, .segmentZoomEnabled, .wide, .xPixels, .xvtr:  break
      }
    }
    // is it initialized?
    if _initialized == false && panadapterId != 0 {
      // NO, it is now
      _initialized = true
      log.debug("Waterfall: ADDED handle = \(self.clientHandle.hex)")
    }
  }
}
