//
//  UsbCable.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 6/25/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

//import SharedFeature


@MainActor
@Observable
public final class UsbCable {
  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init() {}

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var autoReport = false
  public var band = ""
  public var cableType = "bcd"
  public var dataBits = 0
  public var enable = false
  public var flowControl = ""
  public var name = ""
  public var parity = ""
  public var pluggedIn = false
  public var polarity = ""
  public var preamp = ""
  public var source = ""
  public var sourceRxAnt = ""
  public var sourceSlice = 0
  public var sourceTxAnt = ""
  public var speed = 0
  public var stopBits = 0
  public var usbLog = false
  

  // ----------------------------------------------------------------------------
  // MARK: - Public types
  
//  public enum UsbCableType: String {
//    case bcd
//    case bit
//    case cat
//    case dstar
//    case invalid
//    case ldpa
//  }
  
  public enum Property: String {
    case autoReport  = "auto_report"
    case band
    case cableType   = "type"
    case dataBits    = "data_bits"
    case enable
    case flowControl = "flow_control"
    case name
    case parity
    case pluggedIn   = "plugged_in"
    case polarity
    case preamp
    case source
    case sourceRxAnt = "source_rx_ant"
    case sourceSlice = "source_slice"
    case sourceTxAnt = "source_tx_ant"
    case speed
    case stopBits    = "stop_bits"
    case usbLog      = "log"
    //        case usbLogLine = "log_line"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _initialized = false

  // ----------------------------------------------------------------------------
  // MARK: - Public Static methods
  
  public static func status(_ objectModel: ObjectModel, _ properties: KeyValuesArray, _ inUse: Bool) {
    // get the id
    let id = properties[0].key
    // is it in use?
    if inUse {
      // YES, add it if not already present
      if objectModel.usbCables[id] == nil { objectModel.usbCables[id] = UsbCable() }
      // parse the properties
      objectModel.usbCables[id]!.parse(Array(properties.dropFirst(1)) )
      
    } else {
      // NO, remove it
      objectModel.usbCables[id] = nil
      log.debug("USBCable \(id): REMOVED")
    }
  }

  // TODO: - incomplete
  
  public static func set(id: String, property: Property, value: String) -> String {
    "usb_cable set \(id) \(property.rawValue)=\(value)"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Parse methods
  
  /// Parse key/value pairs
  /// - Parameter properties:       a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) {
    // is the Status for a cable of this type?
//    if cableType.rawValue == properties[0].value {
      // YES,
      // process each key/value pair, <key=value>
      for property in properties {
        // check for unknown Keys
        guard let token = UsbCable.Property(rawValue: property.key) else {
          // log it and ignore the Key
          log.warning("USBCable: unknown property, \(property.key) = \(property.value)")
          continue
        }
        // Known keys, in alphabetical order
        switch token {
          
        case .autoReport:   autoReport = property.value.bValue
        case .band:         band = property.value
        case .cableType:    cableType = properties[0].value
        case .dataBits:     dataBits = property.value.iValue
        case .enable:       enable = property.value.bValue
        case .flowControl:  flowControl = property.value
        case .name:         name = property.value
        case .parity:       parity = property.value
        case .pluggedIn:    pluggedIn = property.value.bValue
        case .polarity:     polarity = property.value
        case .preamp:       preamp = property.value
        case .source:       source = property.value
        case .sourceRxAnt:  sourceRxAnt = property.value
        case .sourceSlice:  sourceSlice = property.value.iValue
        case .sourceTxAnt:  sourceTxAnt = property.value
        case .speed:        speed = property.value.iValue
        case .stopBits:     stopBits = property.value.iValue
        case .usbLog:       usbLog = property.value.bValue
        }
      }
      
//    } else {
//      // NO, log the error
//      log("USBCable, status type: \(properties[0].key) != Cable type: \(cableType.rawValue)", .warning, #function, #file, #line)
//    }
    
    // is it initialized?
    if _initialized == false {
      // NO, it is now
      _initialized = true
      log.debug("USBCable: ADDED, name = \(self.name)")
    }
  }
  
  /* ----- from FlexApi -----
   UsbBcdCable.cs
   "usb_cable set " + _serialNumber + " polarity=" + (_isActiveHigh ? "active_high" : "active_low")
   "usb_cable set " + _serialNumber + " source=" + UsbCableFreqSourceToString(_source)
   "usb_cable set " + _serialNumber + " source_rx_ant=" + _selectedRxAnt
   "usb_cable set " + _serialNumber + " source_tx_ant=" + _selectedTxAnt
   "usb_cable set " + _serialNumber + " source_slice=" + _selectedSlice
   "usb_cable set " + _serialNumber + " type=" + BcdCableTypeToString(_bcdType)
   
   UsbBitCable.cs
   "usb_cable setbit " + _serialNumber + " " + bit + " source=" + UsbCableFreqSourceToString(_bitSource[bit])
   "usb_cable setbit " + _serialNumber + " " + bit + " output=" + UsbBitCableOutputTypeToString(_bitOutput[bit])
   "usb_cable setbit " + _serialNumber + " " + bit + " polarity=" + (_bitActiveHigh[bit] ? "active_high" : "active_low")
   "usb_cable setbit " + _serialNumber + " " + bit + " enable=" + (_bitEnable[bit] ? "1" : "0")
   "usb_cable setbit " + _serialNumber + " " + bit + " ptt_dependent=" + (_bitPtt[bit] ? "1" : "0")
   "usb_cable setbit " + _serialNumber + " " + bit + " ptt_delay=" + delay
   "usb_cable setbit " + _serialNumber + " " + bit + " tx_delay=" + delay
   "usb_cable setbit " + _serialNumber + " " + bit + " source_rx_ant=" + _bitOrdinalRxAnt[bit]
   "usb_cable setbit " + _serialNumber + " " + bit + " source_tx_ant=" + _bitOrdinalTxAnt[bit]
   "usb_cable setbit " + _serialNumber + " " + bit + " source_slice=" + _bitOrdinalSlice[bit]
   "usb_cable setbit " + _serialNumber + " " + bit + " low_freq=" + Math.Round(_bitLowFreq[bit], 6).ToString("0.######") + " high_freq=" + Math.Round(_bitHighFreq[bit], 6).ToString("0.######")
   "usb_cable setbit " + _serialNumber + " " + bit + " band=" + _bitBand[bit].ToLower().Replace("m", "")
   
   UsbCable.cs
   "usb_cable set " + _serialNumber + " type=" + CableTypeToString(_cableType)
   "usb_cable set " + _serialNumber + " enable=" + Convert.ToByte(_enabled)
   "usb_cable set " + _serialNumber + " name=" + EncodeSpaceCharacters(_name)
   "usb_cable set " + _serialNumber + " log=" + (_loggingEnabled ? "1" : "0")
   "usb_cable remove " + _serialNumber
   
   UsbCatCable.cs
   "usb_cable set " + _serialNumber + " data_bits=" + (_dataBits == SerialDataBits.seven ? "7" : "8")
   "usb_cable set " + _serialNumber + " speed=" + SerialSpeedToString(_speed)
   "usb_cable set " + _serialNumber + " parity=" + _parity.ToString()
   "usb_cable set " + _serialNumber + " stop_bits=" + (_stopBits == SerialStopBits.one ? "1" : "2")
   "usb_cable set " + _serialNumber + " flow_control=" + _flowControl.ToString()
   "usb_cable set " + _serialNumber + " source=" + UsbCableFreqSourceToString(_source)
   "usb_cable set " + _serialNumber + " source_rx_ant=" + _selectedRxAnt
   "usb_cable set " + _serialNumber + " source_tx_ant=" + _selectedTxAnt
   "usb_cable set " + _serialNumber + " source_slice=" + _selectedSlice
   "usb_cable set " + _serialNumber + " auto_report=" + Convert.ToByte(_autoReport)
   
   UsbLdpaCable.cs
   "usb_cable set " + _serialNumber + " source=" + UsbCableFreqSourceToString(_source)
   "usb_cable set " + _serialNumber + " band=" + bandStr
   "usb_cable set " + _serialNumber + " preamp=" + Convert.ToByte(_isPreampOn)
   */
}
