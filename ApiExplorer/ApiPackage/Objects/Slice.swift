//
//  Slice.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 7/11/22.
//

import Foundation

//import SharedFeature


@MainActor
@Observable
public final class Slice {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization

  public init(_ id: UInt32) {
    self.id = id
    // set filterLow & filterHigh to default values
    setupDefaultFilters(mode)
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public let id: UInt32
  
  public var autoPan: Bool = false
  public var clientHandle: UInt32 = 0
  public var daxClients: Int = 0
  public var daxTxEnabled: Bool = false
  public var detached: Bool = false
  public var diversityChild: Bool = false
  public var diversityIndex: Int = 0
  public var diversityParent: Bool = false
  public var inUse: Bool = false
  public var modeList = [String]()
  public var nr2: Int = 0
  public var owner: Int = 0
  public var panadapterId: UInt32 = 0
  public var postDemodBypassEnabled: Bool = false
  public var postDemodHigh: Int = 0
  public var postDemodLow: Int = 0
  public var qskEnabled: Bool = false
  public var recordLength: Float = 0
  public var rxAntList = [String]()
  public var sliceLetter: String?
  public var txAntList = [String]()
  public var wide: Bool = false
  
  public var active: Bool = false
  public var agcMode: String = AgcMode.off.rawValue
  public var agcOffLevel: Int = 0
  public var agcThreshold = 0
  public var anfEnabled: Bool = false
  public var anfLevel = 0
  public var apfEnabled: Bool = false
  public var apfLevel: Int = 0
  public var audioGain = 0
  public var audioMute: Bool = false
  public var audioPan = 0
  public var daxChannel = 0
  public var dfmPreDeEmphasisEnabled: Bool = false
  public var digitalLowerOffset: Int = 0
  public var digitalUpperOffset: Int = 0
  public var diversityEnabled: Bool = false
  public var filterHigh: Int = 0
  public var filterLow: Int = 0
  public var fmDeviation: Int = 0
  public var fmRepeaterOffset: Float = 0
  public var fmToneBurstEnabled: Bool = false
  public var fmToneFreq: Float = 0
  public var fmToneMode: String = ""
  public var frequency: Hz = 0
  public var locked: Bool = false
  public var loopAEnabled: Bool = false
  public var loopBEnabled: Bool = false
  public var mode: String = ""
  public var nbEnabled: Bool = false
  public var nbLevel = 0
  public var nrEnabled: Bool = false
  public var nrLevel = 0
  public var playbackEnabled: Bool = false
  public var recordEnabled: Bool = false
  public var repeaterOffsetDirection: String = ""
  public var rfGain: Int = 0
  public var ritEnabled: Bool = false
  public var ritOffset: Int = 0
  public var rttyMark: Int = 0
  public var rttyShift: Int = 0
  public var rxAnt: String = ""
  public var sampleRate: Int = 0
  public var splitId: UInt32?
  public var step: Int = 0
  public var stepList: String = "1, 10, 50, 100, 500, 1000, 2000, 3000"
  public var squelchAvgFactor = 0  
  public var squelchEnabled: Bool = false
  public var squelchHangDelay = 0
  public var squelchLevel: Int = 0
  public var squelchTriggeredWeight = 0
  public var txAnt: String = ""
  public var txEnabled: Bool = false
  public var txOffsetFreq: Float = 0
  public var wnbEnabled: Bool = false
  public var wnbLevel = 0
  public var xitEnabled: Bool = false
  public var xitOffset: Int = 0
  
  public let daxChoices = Radio.kDaxChannels
  public var filters = [(low: Int, high: Int)]()
  
  let filterDefaults =     // Values of filters (by mode) (low, high)
  [
    "AM":   [(-1500,1500), (-2000,2000), (-2800,2800), (-3000,3000), (-4000,4000), (-5000,5000), (-6000,6000), (-7000,7000), (-8000,8000), (-10000,10000)],
    "SAM":  [(-1500,1500), (-2000,2000), (-2800,2800), (-3000,3000), (-4000,4000), (-5000,5000), (-6000,6000), (-7000,7000), (-8000,8000), (-10000,10000)],
    "CW":   [(450,500), (450,525), (450,550), (450,600), (450,700), (450,850), (450,1250), (450,1450), (450,1950), (450,3450)],
    "USB":  [(300,1500), (300,1700), (300,1900), (300,2100), (300,2400), (300,2700), (300,3000), (300,3200), (300,3600), (300,4300)],
    "LSB":  [(-1500,-300), (-1700,-300), (-1900,-300), (-2100,-300), (-2400,-300), (-2700,-300), (-3000,-300), (-3200,-300), (-3600,-300), (-4300,-300)],
    "FM":   [(-8000,8000), (-8000,8000), (-8000,8000), (-8000,8000), (-8000,8000), (-8000,8000), (-8000,8000), (-8000,8000), (-8000,8000), (-8000,8000)],
    "NFM":  [(-8000,8000), (-8000,8000), (-8000,8000), (-8000,8000), (-8000,8000), (-8000,8000), (-8000,8000), (-8000,8000), (-8000,8000), (-8000,8000)],
    "DFM":  [(-1500,1500), (-2000,2000), (-2800,2800), (-3000,3000), (-4000,4000), (-5000,5000), (-6000,6000), (-7000,7000), (-8000,8000), (-10000,10000)],
    "DIGU": [(300,1500), (300,1700), (300,1900), (300,2100), (300,2400), (300,2700), (300,3000), (300,3200), (300,3600), (300,4300)],
    "DIGL": [(-1500,-300), (-1700,-300), (-1900,-300), (-2100,-300), (-2400,-300), (-2700,-300), (-3000,-300), (-3200,-300), (-3600,-300), (-4300,-300)],
    "RTTY": [(-285, 115), (-285, 115), (-285, 115), (-285, 115), (-285, 115), (-285, 115), (-285, 115), (-285, 115), (-285, 115), (-285, 115)]
  ]

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _initialized = false

  // ----------------------------------------------------------------------------
  // MARK: - Public Static status method
  
  public static func status(_ objectModel: ObjectModel, _ properties: KeyValuesArray, _ inUse: Bool) {
    // get the id
    if let id = properties[0].key.objectId {
      let index = objectModel.slices.firstIndex(where: { $0.id == id })
      // is it in use?
      if inUse {
        if index == nil {
          objectModel.slices.append(Slice(id))
          objectModel.slices.last!.parse(Array(properties.dropFirst(1)) )
        } else {
          // parse the properties
          objectModel.slices[index!].parse(Array(properties.dropFirst(1)) )
        }

      } else {
        // NO, remove it
        objectModel.slices.remove(at: index!)
        log.debug("Slice \(id) REMOVED")
      }
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static command methods
  
  public static func add(panadapterId: UInt32? = nil, mode: String = "", frequency: Hz = 0,  rxAntenna: String = "", usePersistence: Bool = false, replyHandler: ReplyHandler? = nil) -> String {
    var cmd = "slice create"
    if panadapterId != nil  { cmd += " pan=\(panadapterId!.hex)" }
    if frequency != 0     { cmd += " freq=\(frequency.hzToMhz)" }
    if rxAntenna != ""    { cmd += " rxant=\(rxAntenna)" }
    if mode != ""         { cmd += " mode=\(mode)" }
    if usePersistence     { cmd += " load_from=PERSISTENCE" }
    return cmd
  }
  public static func remove(id: UInt32) -> String {
    "slice remove \(id)"
  }
  public static func set(id: UInt32, property: Property, value: String) -> String {
    "tnf set \(id) \(property.rawValue)=\(value)"
  }


  // ----------------------------------------------------------------------------
  // MARK: - Public Parse methods
  
  /// Parse key/value pairs
  /// - Parameter properties: a KeyValuesArray
  public func parse(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = Slice.Property(rawValue: property.key) else {
        // log it and ignore the Key
        log.warning("Slice: unknown property, \(property.key) = \(property.value)")
        continue
      }
      // Known keys, in alphabetical order
      switch token {
        
      case .active:                   active = property.value.bValue
      case .agcMode:                  agcMode = property.value
      case .agcOffLevel:              agcOffLevel = property.value.iValue
      case .agcThreshold:             agcThreshold = property.value.iValue
      case .anfEnabled:               anfEnabled = property.value.bValue
      case .anfLevel:                 anfLevel = property.value.iValue
      case .apfEnabled:               apfEnabled = property.value.bValue
      case .apfLevel:                 apfLevel = property.value.iValue
      case .audioGain:                audioGain = property.value.iValue
      case .audioLevel:               audioGain = property.value.iValue
      case .audioMute:                audioMute = property.value.bValue
      case .audioPan:                 audioPan = property.value.iValue
      case .clientHandle:             clientHandle = property.value.handle ?? 0
      case .daxChannel:
        if daxChannel != 0 && property.value.iValue == 0 {
          // remove this slice from the AudioStream it was using
          //          if let daxRxAudioStream = radio.findDaxRxAudioStream(with: daxChannel) { daxRxAudioStream.slice = nil }
        }
        daxChannel = property.value.iValue
      case .daxTxEnabled:             daxTxEnabled = property.value.bValue
      case .detached:                 detached = property.value.bValue
      case .dfmPreDeEmphasisEnabled:  dfmPreDeEmphasisEnabled = property.value.bValue
      case .digitalLowerOffset:       digitalLowerOffset = property.value.iValue
      case .digitalUpperOffset:       digitalUpperOffset = property.value.iValue
      case .diversityEnabled:         diversityEnabled = property.value.bValue
      case .diversityChild:           diversityChild = property.value.bValue
      case .diversityIndex:           diversityIndex = property.value.iValue
      case .filterHigh:               filterHigh = property.value.iValue
      case .filterLow:                filterLow = property.value.iValue
      case .fmDeviation:              fmDeviation = property.value.iValue
      case .fmRepeaterOffset:         fmRepeaterOffset = property.value.fValue
      case .fmToneBurstEnabled:       fmToneBurstEnabled = property.value.bValue
      case .fmToneMode:               fmToneMode = property.value
      case .fmToneFreq:               fmToneFreq = property.value.fValue
      case .frequency:                frequency = property.value.mhzToHz
      case .inUse:                    inUse = property.value.bValue
      case .locked:                   locked = property.value.bValue
      case .loopAEnabled:             loopAEnabled = property.value.bValue
      case .loopBEnabled:             loopBEnabled = property.value.bValue
      case .mode:                     mode = property.value.uppercased() ; filters = filterDefaults[mode]!
      case .modeList:                 modeList = property.value.list
      case .nbEnabled:                nbEnabled = property.value.bValue
      case .nbLevel:                  nbLevel = property.value.iValue
      case .nrEnabled:                nrEnabled = property.value.bValue
      case .nrLevel:                  nrLevel = property.value.iValue
      case .nr2:                      nr2 = property.value.iValue
      case .owner:                    nr2 = property.value.iValue
      case .panadapterId:             panadapterId = property.value.streamId ?? 0
      case .playbackEnabled:          playbackEnabled = (property.value == "enabled") || (property.value == "1")
      case .postDemodBypassEnabled:   postDemodBypassEnabled = property.value.bValue
      case .postDemodLow:             postDemodLow = property.value.iValue
      case .postDemodHigh:            postDemodHigh = property.value.iValue
      case .qskEnabled:               qskEnabled = property.value.bValue
      case .recordEnabled:            recordEnabled = property.value.bValue
      case .repeaterOffsetDirection:  repeaterOffsetDirection = property.value
      case .rfGain:                   rfGain = property.value.iValue
      case .ritOffset:                ritOffset = property.value.iValue
      case .ritEnabled:               ritEnabled = property.value.bValue
      case .rttyMark:                 rttyMark = property.value.iValue
      case .rttyShift:                rttyShift = property.value.iValue
      case .rxAnt:                    rxAnt = property.value
      case .rxAntList:                rxAntList = property.value.list
      case .sampleRate:               sampleRate = property.value.iValue         // FIXME: ????? not in v3.2.15 source code
      case .sliceLetter:              sliceLetter = property.value
      case .squelchAvgFactor:         squelchAvgFactor = property.value.iValue
      case .squelchEnabled:           squelchEnabled = property.value.bValue
      case .squelchHangDelay:         squelchHangDelay = property.value.iValue
      case .squelchLevel:             squelchLevel = property.value.iValue
      case .squelchTriggeredWeight:   squelchTriggeredWeight = property.value.iValue
      case .step:                     step = property.value.iValue
      case .stepList:                 stepList = property.value
      case .txEnabled:                txEnabled = property.value.bValue
      case .txAnt:                    txAnt = property.value
      case .txAntList:                txAntList = property.value.list
      case .txOffsetFreq:             txOffsetFreq = property.value.fValue
      case .wide:                     wide = property.value.bValue
      case .wnbEnabled:               wnbEnabled = property.value.bValue
      case .wnbLevel:                 wnbLevel = property.value.iValue
      case .xitOffset:                xitOffset = property.value.iValue
      case .xitEnabled:               xitEnabled = property.value.bValue
        
        // the following are ignored here
      case .daxClients:               break
      case .diversityParent:          break
      case .recordTime:               break
      case .ghost /*, .tune */:             break
      }
    }
    // is it initialized?
    if _initialized == false && panadapterId != 0 && frequency != 0 && mode != "" {
      // NO, it is now
      _initialized = true
      log.debug("Slice: ADDED, frequency = \(self.frequency.hzToMhz), panadapter = \(self.panadapterId.hex)")
    }
  }
  
  /* ----- from FlexApi -----
   "slice m " + StringHelper.DoubleToString(clicked_freq_MHz, "f6") + " pan=0x" + _streamID.ToString("X")
   "slice create"
   "slice set " + _index + " active=" + Convert.ToByte(_active)
   "slice set " + _index + " rxant=" + _rxant
   "slice set" + _index + " rfgain=" + _rfGain
   "slice set " + _index + " txant=" + _txant
   "slice set " + _index + " mode=" + _demodMode
   "slice set " + _index + " dax=" + _daxChannel
   "slice set " + _index + " rtty_mark=" + _rttyMark
   "slice set " + _index + " rtty_shift=" + _rttyShift
   "slice set " + _index + " digl_offset=" + _diglOffset
   "slice set " + _index + " digu_offset=" + _diguOffset
   "slice set " + _index + " audio_pan=" + _audioPan
   "slice set " + _index + " audio_level=" + _audioGain
   "slice set " + _index + " audio_mute=" + Convert.ToByte(value)
   "slice set " + _index + " anf=" + Convert.ToByte(value)
   "slice set " + _index + " apf=" + Convert.ToByte(value)
   "slice set " + _index + " anf_level=" + _anf_level
   "slice set " + _index + " apf_level=" + _apf_level
   "slice set " + _index + " diversity=" + Convert.ToByte(value)
   "slice set " + _index + " wnb=" + Convert.ToByte(value)
   "slice set " + _index + " nb=" + Convert.ToByte(value)
   "slice set " + _index + " wnb_level=" + _wnb_level)
   "slice set " + _index + " nb_level=" + _nb_level
   "slice set " + _index + " nr=" + Convert.ToByte(_nr_on)
   "slice set " + _index + " nr_level=" + _nr_level
   "slice set " + _index + " agc_mode=" + AGCModeToString(_agc_mode)
   "slice set " + _index + " agc_threshold=" + _agc_threshold
   "slice set " + _index + " agc_off_level=" + _agc_off_level
   "slice set " + _index + " tx=" + Convert.ToByte(_isTransmitSlice)
   "slice set " + _index + " loopa=" + Convert.ToByte(_loopA)
   "slice set " + _index + " loopb=" + Convert.ToByte(_loopB)
   "slice set " + _index + " rit_on=" + Convert.ToByte(_ritOn)
   "slice set " + _index + " rit_freq=" + _ritFreq
   "slice set " + _index + " xit_on=" + Convert.ToByte(_xitOn)
   "slice set " + _index + " xit_freq=" + _xitFreq
   "slice set " + _index + " step=" + _tuneStep
   "slice set " + _index + " record=" + Convert.ToByte(_record_on)
   "slice set " + _index + " play=" + Convert.ToByte(_playOn)
   "slice set " + _index + " fm_tone_mode=" + FMToneModeToString(_toneMode)
   "slice set " + _index + " fm_tone_value=" + _fmToneValue
   "slice set " + _index + " fm_deviation=" + _fmDeviation
   "slice set " + _index + " dfm_pre_de_emphasis=" + Convert.ToByte(_dfmPreDeEmphasis)
   "slice set " + _index + " squelch=" + Convert.ToByte(_squelchOn)
   "slice set " + _index + " squelch_level=" + _squelchLevel
   "slice set " + _index + " tx_offset_freq=" + StringHelper.DoubleToString(_txOffsetFreq, "f6")
   "slice set " + _index + " fm_repeater_offset_freq=" + StringHelper.DoubleToString(_fmRepeaterOffsetFreq, "f6")
   "slice set " + _index + " repeater_offset_dir=" + FMTXOffsetDirectionToString(_repeaterOffsetDirection)
   "slice set " + _index + " fm_tone_burst=" + Convert.ToByte(_fmTX1750)
   "slice remove " + _index
   "slice waveform_cmd " + _index + " " + s
   */
}

// ----------------------------------------------------------------------------
// MARK: - Private methods

extension Slice {
  /// Set the default Filter widths
  /// - Parameters:
  ///   - mode:       demod mode
  ///
  private func setupDefaultFilters(_ mode: String) {
    if let modeValue = Mode(rawValue: mode) {
      switch modeValue {
        
      case .CW:
        filterLow = 450
        filterHigh = 750
      case .RTTY:
        filterLow = -285
        filterHigh = 115
      case .AM, .SAM:
        filterLow = -3_000
        filterHigh = 3_000
      case .FM, .NFM, .DFM:
        filterLow = -8_000
        filterHigh = 8_000
      case .LSB, .DIGL:
        filterLow = -2_400
        filterHigh = -300
      case .USB, .DIGU:
        filterLow = 300
        filterHigh = 2_400
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Static properties

extension Slice {
  static let kMinOffset = -99_999 // frequency offset range
  static let kMaxOffset = 99_999
}

// ----------------------------------------------------------------------------
// MARK: - Public enums and structs

extension Slice {
  
  public enum Offset: String {
    case up
    case down
    case simplex
  }
  public enum AgcMode: String, CaseIterable {
    case off
    case slow
    case med
    case fast
    
    //    static func names() -> [String] {
    //      return [AgcMode.off.rawValue, AgcMode.slow.rawValue, AgcMode.med.rawValue, AgcMode.fast.rawValue]
    //    }
  }
  public enum Mode: String, CaseIterable {
    case AM
    case SAM
    case CW
    case USB
    case LSB
    case FM
    case NFM
    case DFM
    case DIGU
    case DIGL
    case RTTY
    //    case dsb
    //    case dstr
    //    case fdv
  }
  
  public enum Property: String, Equatable {
    case active
    case agcMode                    = "agc_mode"
    case agcOffLevel                = "agc_off_level"
    case agcThreshold               = "agc_threshold"
    case anfEnabled                 = "anf"
    case anfLevel                   = "anf_level"
    case apfEnabled                 = "apf"
    case apfLevel                   = "apf_level"
    case audioGain                  = "audio_gain"
    case audioLevel                 = "audio_level"
    case audioMute                  = "audio_mute"
    case audioPan                   = "audio_pan"
    case clientHandle               = "client_handle"
    case daxChannel                 = "dax"
    case daxClients                 = "dax_clients"
    case daxTxEnabled               = "dax_tx"
    case detached
    case dfmPreDeEmphasisEnabled    = "dfm_pre_de_emphasis"
    case digitalLowerOffset         = "digl_offset"
    case digitalUpperOffset         = "digu_offset"
    case diversityEnabled           = "diversity"
    case diversityChild             = "diversity_child"
    case diversityIndex             = "diversity_index"
    case diversityParent            = "diversity_parent"
    case filterHigh                 = "filter_hi"
    case filterLow                  = "filter_lo"
    case fmDeviation                = "fm_deviation"
    case fmRepeaterOffset           = "fm_repeater_offset_freq"
    case fmToneBurstEnabled         = "fm_tone_burst"
    case fmToneMode                 = "fm_tone_mode"
    case fmToneFreq                 = "fm_tone_value"
    case frequency                  = "rf_frequency"
    case ghost
    case inUse                      = "in_use"
    case locked                     = "lock"
    case loopAEnabled               = "loopa"
    case loopBEnabled               = "loopb"
    case mode
    case modeList                   = "mode_list"
    case nbEnabled                  = "nb"
    case nbLevel                    = "nb_level"
    case nrEnabled                  = "nr"
    case nrLevel                    = "nr_level"
    case nr2
    case owner
    case panadapterId               = "pan"
    case playbackEnabled            = "play"
    case postDemodBypassEnabled     = "post_demod_bypass"
    case postDemodHigh              = "post_demod_high"
    case postDemodLow               = "post_demod_low"
    case qskEnabled                 = "qsk"
    case recordEnabled              = "record"
    case recordTime                 = "record_time"
    case repeaterOffsetDirection    = "repeater_offset_dir"
    case rfGain                     = "rfgain"
    case ritEnabled                 = "rit_on"
    case ritOffset                  = "rit_freq"
    case rttyMark                   = "rtty_mark"
    case rttyShift                  = "rtty_shift"
    case rxAnt                      = "rxant"
    case rxAntList                  = "ant_list"
    case sampleRate                 = "sample_rate"
    case sliceLetter                = "index_letter"
    case squelchAvgFactor           = "squelch_avg_factor"
    case squelchHangDelay           = "squelch_hang_delay_ms"
    case squelchEnabled             = "squelch"
    case squelchLevel               = "squelch_level"
    case squelchTriggeredWeight     = "squelch_triggered_weight"

    case step
    case stepList                   = "step_list"
    //    case tune
    case txEnabled                  = "tx"
    case txAnt                      = "txant"
    case txAntList                  = "tx_ant_list"
    case txOffsetFreq               = "tx_offset_freq"
    case wide
    case wnbEnabled                 = "wnb"
    case wnbLevel                   = "wnb_level"
    case xitEnabled                 = "xit_on"
    case xitOffset                  = "xit_freq"
  }
}
