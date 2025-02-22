//
//  Radio.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 1/12/22.
//

import Foundation
import SwiftUI

//import SharedFeature

public typealias RadioId = String

@MainActor
@Observable
public final class Radio: Identifiable, Equatable {
  public nonisolated static func == (lhs: Radio, rhs: Radio) -> Bool {
    return lhs.id == rhs.id
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization & Dependencies
  
  public init(_ packet: Packet, _ guiClients: [GuiClient], _ discoveryData: Data?) {
    self.packet = packet
    self.guiClients = guiClients
    self.discoveryData = discoveryData
    id = packet.id
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static status method
  
  public static func status(_ objectModel: ObjectModel, _ properties: KeyValuesArray, _ inUse: Bool) {
    // get the id
    let id = objectModel.activeSelection!.radio.id
    if let index = objectModel.radios.firstIndex(where: { $0.id == id }) {
      // in use?
      if inUse {
        // YES, parse the properties
        objectModel.radios[index].parse(Array(properties.dropFirst(1)) )
      } else {
        // NO, remove it
        objectModel.radios.remove(at: index)
        log.debug("Radio \(id): REMOVED")
      }
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Static command methods
  
  /* ----- from FlexApi -----
   "radio oscillator " + _selectedOscillator.ToString()
   
   "radio set binaural_rx=" + Convert.ToByte(_binauralRX)
   "radio set cal_freq=" + StringHelper.DoubleToString(_calFreq, "f6")
   "radio set enforce_private_ip_connections=" + Convert.ToByte(_enforcePrivateIPConnections)
   "radio set freq_error_ppb=" + _freqErrorPPB
   "radio set full_duplex_enabled=" + Convert.ToByte(_fullDuplexEnabled)
   "radio set mute_local_audio_when_remote=" + Convert.ToByte(_isMuteLocalAudioWhenRemoteOn)
   "radio set remote_on_enabled=" + Convert.ToByte(_remoteOnEnabled)
   "radio set rtty_mark_default=" + _rttyMarkDefault
   "radio set snap_tune_enabled=" + Convert.ToByte(_snapTune)
   "radio set tnf_enabled=" + _tnfEnabled
   
   "radio backlight " + _backlight
   "radio callsign " + _callsign
   "radio gps install"
   "radio gps uninstall"
   "radio name " + _nickname
   "radio pll_start"    // ?????
   "radio reboot"
   "radio screensaver " + ScreensaverModeToString(_screensaver)
   
   "radio filter_sharpness voice level=" + _filterSharpnessVoice
   "radio filter_sharpness voice auto_level=" + Convert.ToByte(_filterSharpnessVoiceAuto)
   "radio filter_sharpness cw level=" + _filterSharpnessCW
   "radio filter_sharpness cw auto_level=" + Convert.ToByte(_filterSharpnessCWAuto)
   "radio filter_sharpness digital level=" + _filterSharpnessDigital
   "radio filter_sharpness digital auto_level=" + Convert.ToByte(_filterSharpnessDigitalAuto)
   */

  public static func set(property: Property, value: String) -> String {
    switch property {
    case .backlight, .callsign, .gps, .name, .nickname, .screensaver:
      return "radio \(property.rawValue) \(value)"
    case .reboot:
      return "radio \(property.rawValue)"
    default:
      return "radio set \(property.rawValue)=\(value)"
    }
  }
  public static func filterVoice(property: Property, value: String) -> String {
    "radio filter_sharpness voice \(property.rawValue)=\(value)"
  }
  public static func filterCw(property: Property, value: String) -> String {
    "radio filter_sharpness cw \(property.rawValue)=\(value)"
  }
  public static func filterDigital(property: Property, value: String) -> String {
    "radio filter_sharpness digital \(property.rawValue)=\(value)"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: RadioId

  
  public var discoveryData: Data?
  public var packet: Packet
  public var guiClients: [GuiClient] = []
  public var lastSeen = Date()
  
  public var addressType = "DHCP"
  public internal(set) var alpha = false
  public internal(set) var calFreq: Hz = 0
  public internal(set) var freqErrorPpb = 0
  public internal(set) var mox = false
  public internal(set) var rfGainList = [String]()
  public var tnfsEnabled = false
  
  public nonisolated static let kDaxChannels = [0, 1, 2, 3, 4, 5, 6, 7, 8]
  public nonisolated static let kDaxIqChannels = [0, 1, 2, 3, 4]
  
  // FIXME: needs to be dynamic
  public var pingerEnabled = true
  
  public internal(set) var atuPresent = false
  public internal(set) var availablePanadapters = 0
  public internal(set) var availableSlices = 0
  public internal(set) var backlight = 0
  public internal(set) var bandPersistenceEnabled = false
  public internal(set) var binauralRxEnabled = false
  public internal(set) var callsign = ""
  public internal(set) var chassisSerial = ""
  public internal(set) var daxIqAvailable = 0
  public internal(set) var daxIqCapacity = 0
  public var enforcePrivateIpEnabled = false
  public internal(set) var extPresent = false
  public internal(set) var filterCwAutoEnabled = false
  public internal(set) var filterDigitalAutoEnabled = false
  public internal(set) var filterVoiceAutoEnabled = false
  public internal(set) var filterCwLevel = 0
  public internal(set) var filterDigitalLevel = 0
  public internal(set) var filterVoiceLevel = 0
  public internal(set) var flexControlEnabled = false
  public internal(set) var frontSpeakerMute = false
  public var fullDuplexEnabled = false
  public internal(set) var gateway = ""
  public internal(set) var gpsPresent = false
  public internal(set) var gpsdoPresent = false
  public var headphoneGain = 0
  public var headphoneMute = false
  public internal(set) var ipAddress = ""
  public var lineoutGain = 0
  public var lineoutMute = false
  public internal(set) var localPtt = false
  public internal(set) var location = ""
  public internal(set) var locked = false
  public internal(set) var lowLatencyDigital = false
  public internal(set) var macAddress = ""
  public internal(set) var multiflexEnabled = false
  public internal(set) var muteLocalAudio = false
  public internal(set) var netmask = ""
  public internal(set) var name = ""
  public internal(set) var numberOfScus = 0
  public internal(set) var numberOfSlices = 0
  public internal(set) var numberOfTx = 0
  public internal(set) var oscillator = ""
  public var program = ""
  public internal(set) var radioAuthenticated = false
  public internal(set) var radioModel = ""
  public internal(set) var radioOptions = ""
  public internal(set) var region = ""
  public internal(set) var radioScreenSaver = ""
  public internal(set) var remoteOnEnabled = false
  public internal(set) var rttyMark = 0
  public internal(set) var serverConnected = false
  public internal(set) var setting = ""
  public internal(set) var snapTuneEnabled = false
  public internal(set) var softwareVersion = ""
  public internal(set) var startCalibration = false
  public internal(set) var state = ""
  public internal(set) var staticGateway = ""
  public internal(set) var staticIp = ""
  public internal(set) var staticMask = ""
  public internal(set) var station = ""
  public internal(set) var tcxoPresent = false
  
  public var regionList = ["USA"]

  public var fpgaMbVersion = ""
  public var picDecpuVersion = ""
  public var psocMbPa100Version = ""
  public var psocMbtrxVersion = ""
  public var smartSdrMB = ""

  public internal(set) var antList = [String]()
  public internal(set) var sliceList = [UInt32]()               // FIXME: may not belong here
  public internal(set) var micList = [String]()
  
  public internal(set) var uptime = 0


  // ----------------------------------------------------------------------------
  // MARK: - Public types
  
  public enum Property: String {
    case alpha
    case antList                  = "ant_list"
    case atuPresent               = "atu_present"
    case backlight
    case bandPersistenceEnabled   = "band_persistence_enabled"
    case binauralRxEnabled        = "binaural_rx"
    case calFreq                  = "cal_freq"
    case calibrate
    case callsign
    case chassisSerial            = "chassis_serial"
    case daxIqAvailable           = "daxiq_available"
    case daxIqCapacity            = "daxiq_capacity"
    case enforcePrivateIpEnabled  = "enforce_private_ip_connections"
    case flexControlEnabled
    case freqErrorPpb             = "freq_error_ppb"
    case frontSpeakerMute         = "front_speaker_mute"
    case fullDuplexEnabled        = "full_duplex_enabled"
    case gateway
    case gps
    case headphoneGain            = "headphone_gain"
    case headphoneMute            = "headphone_mute"
    case ipAddress                = "ip"
    case lineoutGain              = "lineout_gain"
    case lineoutMute              = "lineout_mute"
    case location
    case lowLatencyDigital        = "low_latency_digital_modes"
    case macAddress               = "mac"
    case micList                  = "mic_list"
    case model
    case multiflexEnabled         = "mf_enable"
    case muteLocalAudio           = "mute_local_audio_when_remote"
    case name
    case netmask
    case nickname   
    case numberOfScus             = "num_scu"
    case numberOfSlices           = "num_slice"
    case numberOfTx               = "num_tx"
    case options
    case panadapters
    case pllDone                  = "pll_done"
    case radioAuthenticated       = "radio_authenticated"
    case reboot
    case region
    case remoteOnEnabled          = "remote_on_enabled"
    case rttyMark                 = "rtty_mark_default"
    case screensaver
    case serverConnected          = "server_connected"
    case slices
    case snapTuneEnabled          = "snap_tune_enabled"
    case softwareVersion          = "software_ver"
    case tnfsEnabled              = "tnf_enabled"
    case uptime

    case cw                       = "CW"
    case digital                  = "DIGITAL"
    case voice                    = "VOICE"
    case autoLevel                = "auto_level"
    case level

    case filterSharpness          = "filter_sharpness"
    case staticNetParams          = "static_net_params"
    case oscillator

    case staticGateway
    case staticIp
    case staticMask
    
    case extPresent               = "ext_present"
    case gpsdoPresent             = "gpsdo_present"
    case locked
    case setting
    case state
    case tcxoPresent              = "tcxo_present"


    case headphonegain            = "headphone gain"
    case headphonemute            = "headphone mute"
    case lineoutgain              = "lineout gain"
    case lineoutmute              = "lineout mute"
    
    case addressType
    
    case fpgaMb                   = "fpga-mb"
    case psocMbPa100              = "psoc-mbpa100"
    case psocMbTrx                = "psoc-mbtrx"
    case smartSdrMB               = "smartsdr-mb"
    case picDecpu                 = "pic-decpu"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties

  private var _cw = false
  private var _digital = false
  private var _initialized = false
//  private let _objectModel: ObjectModel
  private var _voice = false

  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Parse a Radio status message
  /// - Parameters:
  ///   - properties:      a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) {
      // process each key/value pair, <key=value>
      for property in properties {
        // Check for Unknown Keys
        guard let token = Radio.Property(rawValue: property.key)  else {
          // log it and ignore the Key
          log.warning("Radio: unknown property, \(property.key) = \(property.value)")
          continue
        }
        // Known tokens, in alphabetical order
        switch token {
          
        case .alpha:                    alpha = property.value.bValue                               //
        case .antList:                  antList = property.value.valuesArray()
        case .atuPresent:               atuPresent = property.value.bValue
        case .backlight:                backlight = property.value.iValue                           //
        case .bandPersistenceEnabled:   bandPersistenceEnabled = property.value.bValue              //
        case .binauralRxEnabled:        binauralRxEnabled = property.value.bValue                   //
        case .calFreq:                  calFreq = Int(property.value.dValue * 1_000_000)            //
        case .callsign:                 callsign = property.value                                   //
        case .chassisSerial:            chassisSerial = property.value
        case .daxIqAvailable:           daxIqAvailable = property.value.iValue
        case .daxIqCapacity:            daxIqCapacity = property.value.iValue                       //
        case .enforcePrivateIpEnabled:  enforcePrivateIpEnabled = property.value.bValue             //
        case .freqErrorPpb:             freqErrorPpb = property.value.iValue                        //
        case .fullDuplexEnabled:        fullDuplexEnabled = property.value.bValue                   //
        case .frontSpeakerMute:         frontSpeakerMute = property.value.bValue
        case .gateway:                  gateway = property.value
        case .gps:                      gpsPresent = (property.value != "\"Not Present\"")
        case .headphoneGain, .headphonegain:            headphoneGain = property.value.iValue       //
        case .headphoneMute, .headphonemute:            headphoneMute = property.value.bValue       //
        case .ipAddress:                ipAddress = property.value
        case .lineoutGain, .lineoutgain:              lineoutGain = property.value.iValue           //
        case .lineoutMute, .lineoutmute:              lineoutMute = property.value.bValue           //
        case .location:                 location = property.value
        case .lowLatencyDigital:        lowLatencyDigital = property.value.bValue                   //
        case .macAddress:               macAddress = property.value
        case .micList:                  micList = property.value.valuesArray()
        case .model:                    radioModel = property.value
        case .multiflexEnabled:         multiflexEnabled = property.value.bValue
        case .muteLocalAudio:           muteLocalAudio = property.value.bValue                      //
        case .name:                     name = property.value
        case .nickname:                 name = property.value                                       //
        case .netmask:                  netmask = property.value
        case .numberOfScus:             numberOfScus = property.value.iValue
        case .numberOfSlices:           numberOfSlices = property.value.iValue
        case .numberOfTx:               numberOfTx = property.value.iValue
        case .options:                  radioOptions = property.value
        case .panadapters:              availablePanadapters = property.value.iValue                //
        case .pllDone:                  startCalibration = property.value.bValue                    //
//        case .radioAuthenticated:       radioAuthenticated = property.value.bValue
        case .region:                   region = property.value
        case .screensaver:              radioScreenSaver = property.value
        case .remoteOnEnabled:          remoteOnEnabled = property.value.bValue                     //
        case .rttyMark:                 rttyMark = property.value.iValue                            //
//        case .serverConnected:          serverConnected = property.value.bValue
        case .slices:                   availableSlices = property.value.iValue                     //
//        case .snapTuneEnabled:          snapTuneEnabled = property.value.bValue
        case .softwareVersion:          softwareVersion = property.value
        case .tnfsEnabled:              tnfsEnabled = property.value.bValue                         //
        case .uptime:                   uptime = property.value.iValue
          
//        case .flexControlEnabled:       flexControlEnabled = property.value.bValue
          
          
        case .cw:                       _cw = true
        case .digital:                  _digital = true
        case .voice:                    _voice = true
          
        case .autoLevel:
          if _cw                   { filterCwAutoEnabled = property.value.bValue ; _cw = false }
          if _digital              { filterDigitalAutoEnabled = property.value.bValue ; _digital = false }
          if _voice                { filterVoiceAutoEnabled = property.value.bValue ; _voice = false }
        case .level:
          if _cw                   { filterCwLevel = property.value.iValue ; _cw = false}
          if _digital              { filterDigitalLevel = property.value.iValue ; _digital = false}
          if _voice                { filterVoiceLevel = property.value.iValue ; _voice = false}
          
//        case .staticGateway:            staticGateway = property.value
//        case .staticIp:                 staticIp = property.value
//        case .staticMask:               staticMask = property.value
          
        case .extPresent:               extPresent = property.value.bValue
        case .gpsdoPresent:             gpsdoPresent = property.value.bValue
        case .locked:                   locked = property.value.bValue
        case .setting:                  setting = property.value
        case .state:                    state = property.value
        case .tcxoPresent:              tcxoPresent = property.value.bValue
          
        case .filterSharpness:          break
        case .staticNetParams:          break
        case .oscillator:               break
//        case .calibrate:                break
//        case .reboot:                   break
//        case .addressType:              addressType = property.value

        case .smartSdrMB:   smartSdrMB = property.value
        case .picDecpu:     picDecpuVersion = property.value
        case .psocMbTrx:    psocMbtrxVersion = property.value
        case .psocMbPa100:  psocMbPa100Version = property.value
        case .fpgaMb:       fpgaMbVersion = property.value
        default:            log.warning("Radio: token not processed, \(property.key)")
        }
      }
    // is the Radio initialized?
    if !_initialized {
      // YES, notify all observers
      _initialized = true
      log.debug("Radio: initialized, name = \(self.name)")
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public set property methods
  
  public func set(_ property: Property, _ value: String = "") {
    parse([(property.rawValue, value)])
    send(property, value)
  }
  
  public func setFilter(_ type: Property, _ property: Radio.Property, _ value: String) {
    guard type == .cw || type == .voice || type == .digital else { return }
    parse([(type.rawValue, "")])
    parse([(property.rawValue, value)])
//    _objectModel.sendTcp("radio filter_sharpness \(type.rawValue) \(property.rawValue)=\(value)")
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Send methods
  
  private func send(_ property: Property, _ value: String) {
    switch property {
    case .binauralRxEnabled, .calFreq, .enforcePrivateIpEnabled, .freqErrorPpb, .fullDuplexEnabled,
        .multiflexEnabled, .muteLocalAudio, .remoteOnEnabled, .rttyMark, .snapTuneEnabled, .tnfsEnabled:
//      _objectModel.sendTcp("radio set \(property.rawValue)=\(value)")
      break
    case .backlight, .callsign, .gps, .name, .reboot, .screensaver:
//      _objectModel.sendTcp("radio \(property.rawValue) \(value)")
      break
    case .calibrate:
//      _objectModel.sendTcp("radio pll_start")
      break
    case .lineoutgain, .lineoutmute, .headphonegain, .headphonemute:
//      _objectModel.sendTcp("mixer \(property.rawValue) \(value)")
      break
    case .addressType:
      break   // FIXME:
      
      // not sendable
    case .alpha, .atuPresent, .bandPersistenceEnabled, .chassisSerial, .daxIqAvailable:
      break
    case .daxIqCapacity, .flexControlEnabled, .frontSpeakerMute, .gateway, .headphoneGain, .headphoneMute:
      break
    case .ipAddress, .lineoutGain, .lineoutMute, .location, .lowLatencyDigital, .macAddress:
      break
    case .model, .netmask, .nickname, .numberOfScus, .numberOfSlices, .numberOfTx, .options:
      break
    case .panadapters, .pllDone, .radioAuthenticated, .region, .serverConnected, .slices:
      break
    case .softwareVersion, .cw, .digital, .voice, .autoLevel, .level, .filterSharpness:
      break
    case .staticNetParams, .oscillator, .staticGateway, .staticIp, .staticMask, .extPresent:
      break
    case .gpsdoPresent, .locked, .setting, .state, .tcxoPresent:
      break
    case .fpgaMb, .picDecpu, .psocMbTrx, .psocMbPa100, .smartSdrMB:
      break
    case .antList, .micList, .uptime:
      break
    }
  }
}
