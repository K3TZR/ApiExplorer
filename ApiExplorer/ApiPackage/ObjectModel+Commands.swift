//
//  ApiModel+Commands.swift
//  
//
//  Created by Douglas Adams on 5/25/23.
//

import Foundation

//import SharedFeature

extension ObjectModel {
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Request methods
  
  public func setMtuLimit(_ size: Int, replyhandler: ReplyHandler? = nil) {
    sendTcp("client set enforce_network_mtu=1 network_mtu=\(size)")
  }
  
  public func setLowBandwidthDax(_ enable: Bool, replyhandler: ReplyHandler? = nil) {
    sendTcp("client set send_reduced_bw_dax=\(enable.as1or0)")
  }
  
  public func requestAntennaList(replyHandler: ReplyHandler? = nil) {
    if replyHandler == nil {
      sendTcp("ant list", replyHandler: commandsReplyHandler )
    } else {
      sendTcp("ant list", replyHandler: replyHandler )
    }
  }
  
  public func setCwKeyImmediate(state: Bool, replyHandler: ReplyHandler? = nil) {
    sendTcp("cw key immediate" + " \(state.as1or0)", replyHandler: replyHandler)
  }

  // ----------------------------------------------------------------------------
  // MARK: - Amplifier methods
  
  public func amplifierRequest(ip: String, port: Int, model: String, serialNumber: String, antennaPairs: String, replyhandler: ReplyHandler? = nil) {
    // TODO: add request code
  }
  
  public func amplifierSet(_ id: UInt32, _ property: Amplifier.Property, _ value: String) {
//    amplifiers[id]?.parse([(property.rawValue, value)])
    // FIXME: add send code
  }

  // ----------------------------------------------------------------------------
  // MARK: - Atu methods
  
  public func atuSet(_ property: Atu.Property, _ value: String) {
    guard property == .enabled || property == .memoriesEnabled else { return }
    atu.parse([(property.rawValue, value)])
    switch property {
    case .enabled:            sendTcp("atu \(value == "1" ? "start": "bypass")")
    case .memoriesEnabled:    sendTcp("atu set \(property.rawValue)=\(value)")
    default:                  break
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - BandSetting methods
  
  public func bandSettingRequest(_ channel: String, replyhandler: ReplyHandler? = nil) {
    // FIXME: need information
  }
  
  public func bandSettingRemove(_ id: UInt32, replyhandler: ReplyHandler? = nil) {
    // TODO: test this
    
    // tell the Radio to remove a Stream
    sendTcp("transmit band remove " + "\(id)")
    
    // notify all observers
    //    NC.post(.bandSettingWillBeRemoved, object: self as Any?)
  }
  
  public func bandSettingSet(_ id: UInt32, _ property: BandSetting.Property, _ value: String) {
//    bandSettings[id]?.parse([(property.rawValue, value)])
//    switch property {
//    case .inhibit, .hwAlcEnabled, .rfPower, .tunePower:
//      sendTcp("transmit bandset \(id) \(property.rawValue)=\(value)")
//    case .accTxEnabled, .accTxReqEnabled, .rcaTxReqEnabled, .tx1Enabled, .tx2Enabled, .tx3Enabled:
//      sendTcp("interlock bandset \(id) \(property.rawValue)=\(value)")
//    case .name:
//      break
//    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - CWX methods
  
  public func cwxSet(_ property: Cwx.Property, _ value: String) {
    cwx.parse([(property.rawValue, value)])
    sendTcp("cwx \(property.rawValue) \(value)")
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Equalizer methods
  
  public func equalizerInfo(_ eqType: String, replyHandler: ReplyHandler? = nil) {
    // ask the Radio for an Equalizer's settings
    sendTcp("eq " + eqType + " info", replyHandler: replyHandler)
  }

  public func equalizerSet(_ id: String, _ property: Equalizer.Property, _ value: String) {
//    equalizers[id]?.parse([(property.rawValue, value)])
//    var rawProperty = property.rawValue
//    
//    // is there an alternate property REQUIRED when sending to the radio?
//    if let altValue = Equalizer.altProperty[property] {
//      // YES
//      rawProperty = altValue
//    }
//    sendTcp("eq \(id) \(rawProperty)=\(value)")
//  }
//
//  public func equalizerFlat(_ id: String) {
//    equalizerSet(id, .hz63, "0")
//    equalizerSet(id, .hz125, "0")
//    equalizerSet(id, .hz250, "0")
//    equalizerSet(id, .hz500, "0")
//    equalizerSet(id, .hz1000, "0")
//    equalizerSet(id, .hz2000, "0")
//    equalizerSet(id, .hz4000, "0")
//    equalizerSet(id, .hz8000, "0")
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Memory methods
  
  public func memorySet(_ id: UInt32, _ property: Memory.Property, _ value: String) {
//    memories[id]?.parse([(property.rawValue, value)])
//    switch property {
//    case .apply, .remove:   sendTcp("memory \(property.rawValue) \(id)")
//    case .create:           sendTcp("memory create")
//    default:                sendTcp("memory set \(id) \(property.rawValue)=\(value)")
//    }
//    sendTcp("memory set \(id) \(property.rawValue)=\(value)")
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Panadapter methods
  
  public func panadapterRemove(_ id: UInt32, replyHandler: ReplyHandler? = nil) {
    sendTcp("display panafall remove \(id)", replyHandler: replyHandler)
  }
  
  public func panadapterRequest(replyHandler: ReplyHandler? = nil) {
    sendTcp("display panafall create x=50, y=50", replyHandler: replyHandler)
  }

  public func panadapterRfGainList(_ streamId: UInt32, replyHandler: ReplyHandler? = nil) {
    sendTcp("display pan rfgain_info \(streamId.hex)", replyHandler: replyHandler)
  }

  public func panadapterSet(_ id: UInt32, _ property: Panadapter.Property, _ value: String) {
    var adjustedValue = value
    
//    if property == .rxAnt { adjustedValue = apiModel.stdAntennaName(value) }

//    switch property {
//    case .band:
//      if value == "WWV" { adjustedValue = "33"}
//      if value == "GEN" { adjustedValue = "34"}
//    default: break
//    }
//    panadapters[id]?.parse([(property.rawValue, adjustedValue)])
//    sendTcp("display pan set \(id.hex) \(property.rawValue)=\(value)")
  }
  
//  public enum ZoomType {
//    case band
//    case minus
//    case plus
//    case segment
//  }
  
//  public func panadapterZoom(_ id: UInt32, _ type: ZoomType) {
//    
//    switch type {
//    case .band:
//      print("zoom to band")
//      
//    case .minus:
//      if bandwidth * 2 > maxBw {
//        // TOO Wide, make the bandwidth maximum value
//        panadapterSet(id, .bandwidth, maxBw.hzToMhz)
//        
//      } else {
//        // OK, make the bandwidth twice its current value
//        panadapterSet(id, .bandwidth, (bandwidth * 2).hzToMhz)
//      }
//    
//    case .plus:
//      if bandwidth / 2 < minBw {
//        // TOO Narrow, make the bandwidth minimum value
//        panadapterSet(id, .bandwidth, minBw.hzToMhz)
//        
//      } else {
//        // OK, make the bandwidth half its current value
//        panadapterSet(id, .bandwidth, (bandwidth / 2).hzToMhz)
//      }
//      
//    case .segment:
//      print("zoom to segment")
//    }
//  }


  // ----------------------------------------------------------------------------
  // MARK: - Profile methods
  
  public func displayProfileRequest(replyHandler: ReplyHandler? = nil) {
    sendTcp("profile display info", replyHandler: replyHandler)
  }
  
  public func globalProfileRequest(replyHandler: ReplyHandler? = nil) {
    sendTcp("profile global info", replyHandler: replyHandler)
  }
  
  public func micProfileRequest(replyHandler: ReplyHandler? = nil) {
    sendTcp("profile mic info", replyHandler: replyHandler)
  }
  
  public func txProfileRequest(replyHandler: ReplyHandler? = nil) {
    sendTcp("profile tx info", replyHandler: replyHandler)
  }

  public func profileSet(_ id: String, _ cmd: String, _ profileName: String) {
    guard id == "mic" || id == "tx" || id == "global" else { return }
    guard cmd == "load" || cmd == "reset" || cmd == "delete" || cmd == "create" else { return }
    sendTcp("profile \(id) \(cmd) \"\(profileName)\"")
  }

  // ----------------------------------------------------------------------------
  // MARK: - Radio methods
  
  public func infoRequest(replyHandler: ReplyHandler? = nil) {
    if replyHandler == nil {
      sendTcp("info", replyHandler: commandsReplyHandler )
    } else {
      sendTcp("info", replyHandler: replyHandler )
    }
  }
  
  public func licenseRequest(replyHandler: ReplyHandler? = nil) {
    sendTcp("license refresh", replyHandler: replyHandler)
  }
  
  public func lowBandwidthConnectRequest(replyHandler: ReplyHandler? = nil) {
    sendTcp("client low_bw_connect", replyHandler: replyHandler)
  }
  
  public func micListRequest(replyHandler: ReplyHandler? = nil) {
    if replyHandler == nil {
      sendTcp("mic list", replyHandler: commandsReplyHandler )
    } else {
      sendTcp("mic list", replyHandler: replyHandler )
    }
  }
  
  public func staticNetParamsReset(replyHandler: ReplyHandler? = nil) {
    sendTcp("radio static_net_params" + " reset", replyHandler: replyHandler)
  }
  
  public func staticNetParamsSet(replyHandler: ReplyHandler? = nil) {
    //    sendTcp("radio static_net_params" + " ip=\(staticIp) gateway=\(staticGateway) netmask=\(staticMask)")
  }
  public func persistenceOffRequest(replyHandler: ReplyHandler? = nil) {
    sendTcp("client program start_persistence off", replyHandler: replyHandler)
  }

  public func reebootRequest(replyHandler: ReplyHandler? = nil) {
    sendTcp("radio reboot", replyHandler: replyHandler)
  }

  public func uptimeRequest(replyHandler: ReplyHandler? = nil) {
    if replyHandler == nil {
      sendTcp("radio uptime", replyHandler: commandsReplyHandler )
    } else {
      sendTcp("radio uptime", replyHandler: replyHandler )
    }
  }
  
  public func versionRequest(replyHandler: ReplyHandler? = nil) {
    if replyHandler == nil {
      sendTcp("version", replyHandler: commandsReplyHandler )
    } else {
      sendTcp("version", replyHandler: replyHandler )
    }
  }
    
 // ----------------------------------------------------------------------------
  // MARK: - Slice methods
  
  public func sliceAdd(panadapterId: UInt32? = nil, mode: String = "", frequency: Hz = 0,  rxAntenna: String = "", usePersistence: Bool = false, replyHandler: ReplyHandler? = nil) {
    sendTcp(Slice.add(panadapterId: panadapterId, mode: mode, frequency: frequency, rxAntenna: rxAntenna, usePersistence: usePersistence), replyHandler: replyHandler)
  }
  public func sliceRemove(_ id: UInt32, replyHandler: ReplyHandler? = nil) {
    sendTcp(Slice.remove(id: id), replyHandler: replyHandler)
  }
  public func sliceSet(_ id: UInt32, _ property: Slice.Property, _ value: String) {
//    var adjustedValue = value
    
//    if property == .rxAnt { adjustedValue = apiModel.stdAntennaName(value) }
//    if property == .txAnt { adjustedValue = apiModel.stdAntennaName(value) }

//    slices[id]?.parse([(property.rawValue, value)])
//    switch property {
//    case .filterLow:
//      sendTcp("filt \(id) filterLow=\(value)")
//    case .filterHigh:
//      sendTcp("filt \(id) filterHigh=\(value)")
//    case .frequency:
//      sendTcp("slice tune \(id) \(value) " + "autopan" + "=\(slices[id]?.autoPan.as1or0 ?? "0")")
//    case .locked:
//      sendTcp("slice \(value == "0" ? "unlock" : "lock" ) \(id)")
//    case .audioGain, .audioLevel:
//      sendTcp("slice set \(id) audio_level=\(value)")
//    default:
//      sendTcp("slice set \(id) \(property.rawValue)=\(value)")
//    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Transmit methods
  
  public func transmitSet(_ property: Transmit.Property, _ value: String) {
    transmit.parse([(property.rawValue, value)])
    var rawProperty = property.rawValue
    
    // is there an alternate property REQUIRED when sending to the radio?
    if let altValue = Transmit.Property(rawValue: rawProperty) {
      // YES
      rawProperty = altValue.rawValue
    }
    
    switch property {
    case .mox:
      sendTcp("xmit \(value)")

    case .cwBreakInEnabled, .cwBreakInDelay, .cwlEnabled, .cwIambicEnabled,
        .cwPitch, .cwSidetoneEnabled, .cwSyncCwxEnabled, .cwIambicMode,
        .cwSwapPaddles, .cwSpeed:
      sendTcp("cw \(rawProperty) \(value)")

    case .micBiasEnabled, .micBoostEnabled, .micSelection, .micAccEnabled:
      sendTcp("mic \(rawProperty) \(value)")

    case .tune:
      sendTcp("transmit \(rawProperty) \(value)")

    default:
      sendTcp("transmit set \(rawProperty)=\(value)")
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Send methods

  private func send(_ property: Slice.Property, _ value: String) {
  }

  //  @MainActor public func sliceMakeActive(_ slice: Slice) {
  //    for slice in objectModel.slices {
  //      slice.active = false
  //    }
  //    slice.active = true
  //    objectModel.activeSlice = slice
  //  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Tnf methods
  
  public func tnfAdd(at frequency: Hz, replyHandler: ReplyHandler? = nil) {
    sendTcp(Tnf.add(at: frequency), replyHandler: replyHandler)
  }
  public func tnfRemove(_ id: UInt32, replyHandler: ReplyHandler? = nil) {
    sendTcp(Tnf.remove(id: id), replyHandler: replyHandler)

    // remove it immediately (Tnf does not send status on removal)
    if let index = tnfs.firstIndex(where: {$0.id == id}) {
      tnfs.remove(at: index)
      log.debug("Tnf, removed: id = \(id)")
    }
  }
  public func tnfSet(_ id: UInt32, _ property: Tnf.Property, _ value: String) {
    if let index = tnfs.firstIndex(where: {$0.id == id}) {
      tnfs[index].parse([(property.rawValue, value)])
      sendTcp(Tnf.set(id: id, property: property, value: value))
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - UsbCable methods
  
  public func usbCableSet(_ id: String, _ property: UsbCable.Property, _ value: String) {
    usbCables[id]?.parse([(property.rawValue, value)])
    sendTcp(UsbCable.set(id: id, property: property, value: value))
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Waterfall methods
  
  public func waterfallSet(_ id: UInt32,_ property: Waterfall.Property, _ value: String) {
//    waterfalls[id]?.parse([(property.rawValue, value)])
//   sendTcp("display panafall set \(id.toHex()) \(property.rawValue)=\(value)")
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Xvtr methods
  
  public func xvtrAdd() {
    sendTcp(Xvtr.add())
  }
  public func xvtrRemove(_ id: UInt32) {
    sendTcp(Xvtr.remove(id: id))
  }
  public func xvtrSet(_ id: UInt32, _ property: Xvtr.Property, _ value: String) {
    sendTcp(Xvtr.set(id: id, property: property, value: value))
  }
  
  // ----------------------------------------------------------------------------
  // MARK: Stream methods
  
  public func streamRequest(_ streamType: StreamType, daxChannel: Int = 0, isCompressed: Bool = false, replyHandler: ReplyHandler? = nil)  {
    switch streamType {
    case .remoteRxAudioStream:  sendTcp("stream create type=\(streamType.rawValue) compression=\(isCompressed ? "opus" : "none")", replyHandler: replyHandler)
    case .remoteTxAudioStream:  sendTcp("stream create type=\(streamType.rawValue)", replyHandler: replyHandler)
    case .daxMicAudioStream:    sendTcp("stream create type=\(streamType.rawValue)", replyHandler: replyHandler)
    case .daxRxAudioStream:     sendTcp("stream create type=\(streamType.rawValue) dax_channel=\(daxChannel)", replyHandler: replyHandler)
    case .daxTxAudioStream:     sendTcp("stream create type=\(streamType.rawValue)", replyHandler: replyHandler)
    case .daxIqStream:          sendTcp("stream create type=\(streamType.rawValue) dax_channel=\(daxChannel)", replyHandler: replyHandler)
    default: return
    }
  }

  public func streamRemove(_ streamId: UInt32?)  {
    if let streamId {
      sendTcp("stream remove \(streamId.hex)")
    }
  }

}
