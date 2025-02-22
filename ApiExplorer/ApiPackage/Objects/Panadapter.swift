//
//  Panadapter.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 5/31/15.
//  Copyright (c) 2015 Douglas Adams, K3TZR
//

import Foundation

//import SharedFeature
//import VitaFeature


@MainActor
@Observable
public final class Panadapter: Identifiable {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization

  public init(_ id: UInt32) {
    self.id = id
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: UInt32

  public var antList = [String]()
  public var clientHandle: UInt32 = 0
  public var dbmValues = [LegendValue]()
  public var fillLevel: Int = 0
  public var freqLegends = [Legend]()      // FIXME: remove when panadapter draw logic is updated
  public var freqOffset: CGFloat = 0
  public var maxBw: Hz = 0
  public var minBw: Hz = 0
  public var preamp = ""
  public var rfGainHigh = 0
  public var rfGainLow = 0
  public var rfGainStep = 0
  public var rfGainValues = ""
  public var waterfallId: UInt32 = 0
  public var wide = false
  public var wnbUpdating = false
  public var xvtrLabel = ""
  
  public var average: Int = 0
  public var band: String = ""
  // FIXME: Where does autoCenter come from?
  public var bandwidth: Hz = 0
  public var bandZoomEnabled: Bool  = false
  public var center: Hz = 0
  public var daxIqChannel: Int = 0
  public var fps: Int = 0
  public var loggerDisplayEnabled: Bool = false
  public var loggerDisplayIpAddress: String = ""
  public var loggerDisplayPort: Int = 0
  public var loggerDisplayRadioNumber: Int = 0
  public var loopAEnabled: Bool = false
  public var loopBEnabled: Bool = false
  public var maxDbm: CGFloat = 0
  public var minDbm: CGFloat = 0
  public var rfGain: Int = 0
  public var rxAnt: String = ""
  public var segmentZoomEnabled: Bool = false
  public var weightedAverageEnabled: Bool = false
  public var wnbEnabled: Bool = false
  public var wnbLevel: Int = 0
  public var xPixels: CGFloat = 0
  public var yPixels: CGFloat = 0
    
  public let daxIqChoices = Radio.kDaxIqChannels

  // ----------------------------------------------------------------------------
  // MARK: - Public types
  
  public enum Property: String {
    //   NOTE: the Radio sends these tokens to the API
    case antList                    = "ant_list"
    case average
    case band
    case bandwidth
    case bandZoomEnabled            = "band_zoom"
    case center
    case clientHandle               = "client_handle"
    case daxIq                      = "daxiq"
    case daxIqChannel               = "daxiq_channel"
//    case fillLevel
    case fps
    case loopAEnabled               = "loopa"
    case loopBEnabled               = "loopb"
    case maxBw                      = "max_bw"
    case maxDbm                     = "max_dbm"
    case minBw                      = "min_bw"
    case minDbm                     = "min_dbm"
    case preamp                     = "pre"
    case rfGain                     = "rfgain"
    case rxAnt                      = "rxant"
    case segmentZoomEnabled         = "segment_zoom"
    case waterfallId                = "waterfall"
    case weightedAverageEnabled     = "weighted_average"
    case wide
    case wnbEnabled                 = "wnb"
    case wnbLevel                   = "wnb_level"
    case wnbUpdating                = "wnb_updating"
    case xvtrLabel                  = "xvtr"
    
    //   NOTE: ignored here
    case available
    case capacity
    case daxIqRate                  = "daxiq_rate"
    case xpixels                    = "x_pixels"
    case ypixels                    = "y_pixels"

    //   NOTE: the Radio requires these tokens from the API
    case xPixels                    = "xpixels"
    case yPixels                    = "ypixels"
    
    //   NOTE: not sent in status messages
    case n1mmSpectrumEnable         = "n1mm_spectrum_enable"
    case n1mmAddress                = "n1mm_address"
    case n1mmPort                   = "n1mm_port"
    case n1mmRadio                  = "n1mm_radio"
  }
  
  public struct LegendValue: Identifiable {
    public var id: CGFloat         // relative position 0...1
    public var label: String       // value to display
    public var value: CGFloat      // actual value
    public var lineCount: CGFloat
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _initialized = false
  
  private static let dbmMax: CGFloat = 20
  private static let dbmMin: CGFloat = -180

  // ----------------------------------------------------------------------------
  // MARK: - Public Static status method
  
  public static func status(_ objectModel: ObjectModel, _ properties: KeyValuesArray, _ inUse: Bool) {
    // get the id
    if let id = properties[0].key.streamId {
      let index = objectModel.panadapters.firstIndex(where: { $0.id == id })
      // is it in use?
      if inUse {
        if index == nil {
          objectModel.panadapters.append(Panadapter(id))
          objectModel.panadapters.last!.parse(Array(properties.dropFirst(1)) )
        } else {
          // parse the properties
          objectModel.panadapters[index!].parse(Array(properties.dropFirst(1)) )
        }

      } else {
        // NO, remove it
        objectModel.panadapters.remove(at: index!)
        log.debug("Panadapter \(id.hex): REMOVED")
      }
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static command methods
  
  /* ----- from the FlexApi source -----
   "display pan set 0x" + _streamID.ToString("X") + " wnb=" + Convert.ToByte(value)
   "display pan set 0x" + _streamID.ToString("X") + " wnb_level=" + _wnb_level
   "display pan set 0x" + _streamID.ToString("X") + " rxant=" + _rxant
   "display pan set 0x" + _streamID.ToString("X") + " rfgain=" + _rfGain
   "display pan set 0x" + _streamID.ToString("X") + " daxiq_channel=" + _daxIQChannel
   "display pan set 0x" + _streamID.ToString("X") + " xpixels=" + _width
   "display pan set 0x" + _streamID.ToString("X") + " ypixels=" + _height
   "display pan set 0x" + _streamID.ToString("X") + " band=" + _band
   "display pan set 0x" + _streamID.ToString("X") + " fps=" + value
   "display pan set 0x" + _streamID.ToString("X") + " average=" + value
   "display pan set 0x" + _streamID.ToString("x") + " weighted_average=" + Convert.ToByte(_weightedAverage)
   "display pan set 0x" + _streamID.ToString("x") + " n1mm_spectrum_enable=" + Convert.ToByte(_loggerDisplayEnabled)
   "display pan set 0x" + _streamID.ToString("x") + " n1mm_address=" + _loggerDisplayIPAddress.ToString()
   "display pan set 0x" + _streamID.ToString("x") + " n1mm_port=" + _loggerDisplayPort
   "display pan set 0x" + _streamID.ToString("x") + " n1mm_radio=" + _loggerDisplayRadioNum
   "display pan set 0x" + _streamID.ToString("X") + " loopa=" + Convert.ToByte(_loopA)
   "display pan set 0x" + _streamID.ToString("X") + " loopb=" + Convert.ToByte(_loopB)
   */
  
  public static func set(id: UInt32, property: Property, value: String) -> String {
    "display pan set \(id.hex) \(property.rawValue)=\(value)"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Parse methods
  
  /// Parse key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) {
    for property in properties {
      // check for unknown Keys
      guard let token = Panadapter.Property(rawValue: property.key) else {
        // unknown, log it and ignore the Key
        log.warning("Panadapter: unknown property, \(property.key) = \(property.value)")
        continue
      }
      // Known keys, in alphabetical order
      switch token {
      case .antList:                antList = property.value.list
      case .average:                average = property.value.iValue
      case .band:                   band = property.value
      case .bandwidth:              bandwidth = property.value.mhzToHz
      case .bandZoomEnabled:        bandZoomEnabled = property.value.bValue
      case .center:                 center = property.value.mhzToHz
      case .clientHandle:           clientHandle = property.value.handle ?? 0
      case .daxIq:                  daxIqChannel = property.value.iValue
      case .daxIqChannel:           daxIqChannel = property.value.iValue
      case .fps:                    fps = property.value.iValue
      case .loopAEnabled:           loopAEnabled = property.value.bValue
      case .loopBEnabled:           loopBEnabled = property.value.bValue
      case .maxBw:                  maxBw = property.value.mhzToHz
      case .maxDbm:                 maxDbm = min(property.value.cgValue, Panadapter.dbmMax)
      case .minBw:                  minBw = property.value.mhzToHz
      case .minDbm:                 minDbm = max(property.value.cgValue, Panadapter.dbmMin)
      case .preamp:                 preamp = property.value
      case .rfGain:                 rfGain = property.value.iValue
      case .rxAnt:                  rxAnt = property.value
      case .segmentZoomEnabled:     segmentZoomEnabled = property.value.bValue
      case .waterfallId:            waterfallId = property.value.streamId ?? 0
      case .wide:                   wide = property.value.bValue
      case .weightedAverageEnabled: weightedAverageEnabled = property.value.bValue
      case .wnbEnabled:             wnbEnabled = property.value.bValue
      case .wnbLevel:               wnbLevel = property.value.iValue
      case .wnbUpdating:            wnbUpdating = property.value.bValue
      case .xvtrLabel:              xvtrLabel = property.value
        
      case .available, .capacity, .daxIqRate, .xpixels, .ypixels:     break // ignored by Panadapter
      case .xPixels, .yPixels:                                        break // not sent in status messages
      case .n1mmSpectrumEnable, .n1mmAddress, .n1mmPort, .n1mmRadio:  break // not sent in status messages
//      case .fillLevel:                                                break // not sent in status messages
      }
    }
    // is it initialized?∫
    if _initialized == false && center != 0 && bandwidth != 0 && (minDbm != 0.0 || maxDbm != 0.0) {
      // NO, it is now
      _initialized = true
      log.debug("Panadapter: ADDED, center = \(self.center.hzToMhz), bandwidth = \(self.bandwidth.hzToMhz)")
      
      // FIXME: ????
//      _apiModel.activePanadapter = self
    }
  }

  /// Process the Reply to an Rf Gain Info command, reply format: <value>,<value>,...<value>
  /// - Parameters:
  ///   - seqNum:         the Sequence Number of the original command
  ///   - responseValue:  the response value
  ///   - reply:          the reply
  public func rfGainReplyHandler(_ command: String, sequenceNumber: UInt, responseValue: String, reply: String) {
    // Anything other than 0 is an error
    guard responseValue == kNoError else {
      // log it and ignore the Reply
//      log("Panadapter, non-zero reply: \(command), \(responseValue), \(flexErrorString(errorCode: responseValue))", .warning, #function, #file, #line)
      return
    }
    // parse out the values
    let rfGainInfo = reply.valuesArray( delimiter: "," )
    rfGainLow = rfGainInfo[0].iValue
    rfGainHigh = rfGainInfo[1].iValue
    rfGainStep = rfGainInfo[2].iValue
  }
  
  public func setFillLevel(_ level: Int) {
    fillLevel = level
  }

  
  // FIXME: remove when Panadapter draw logic is updated
  
  
  func updateFreqLegends(_ center: Int, _ bandWidth: Int, _ step: Int) {
    let halfBandWidth = CGFloat(bandWidth)/2
    let low = CGFloat(center) - halfBandWidth
    let high = CGFloat(center) + halfBandWidth
    var legends = [Legend]()
    var offset: CGFloat = 0

    var value = (low + CGFloat(step)) - (low + CGFloat(step)).truncatingRemainder(dividingBy: CGFloat(step))
    var i = 0
    repeat {
      legends.append( Legend(id: i, value: String(format: "%2.3f", value/1_000_000)))
      value = value + CGFloat(step)
      i += 1
    } while value <= high

    offset = -1 + ((low + CGFloat(step)).truncatingRemainder(dividingBy: CGFloat(step))) / CGFloat(step)

    freqLegends = legends
    freqOffset = offset
  }
}

public struct Legend: Identifiable {
  public var id: Int
  public var value: String
}

