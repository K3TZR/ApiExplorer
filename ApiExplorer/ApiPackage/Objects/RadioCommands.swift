//
//  RadioExtension.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 1/3/20.
//



//extension Radio {    
//  // ----------------------------------------------------------------------------
//  // MARK: - Amplifier methods
//  
//  public func requestAmplifier(ip: String, port: Int, model: String, serialNumber: String, antennaPairs: String, replyhandler: ReplyHandler? = nil) {
//    // TODO: add code
//  }
//  
//  // ----------------------------------------------------------------------------
//  // MARK: - BandSetting methods
//  
//  public func requestBandSetting(_ channel: String, replyhandler: ReplyHandler? = nil) {
//    // FIXME: need information
//  }
//  
//  public func removeBandSetting(_ id: UInt32, replyhandler: ReplyHandler? = nil) {
//    // TODO: test this
//    
//    // tell the Radio to remove a Stream
//    ObjectModel.shared.sendTcp("transmit band remove " + "\(id)", replyProcessor: replyProcessor)
//    
//    // notify all observers
//    //    NC.post(.bandSettingWillBeRemoved, object: self as Any?)
//  }
  
  // ----------------------------------------------------------------------------
  // MARK: - NetCwStream methods
  
  //    public func requestNetCwStream() -> Void {
  //        if netCwStream.isActive {
  //            LogProxy.sharedInstance.libMessage("NetCwStream was already requested", .error)
  //            return
  //        }
  //        // send the command to the radio to create the object...need to change this..
  //        _api.send("stream create netcw", diagnostic: false, replyTo: netCwStream.updateStreamId)
  //    }
  //
  //    public func cwKey(state: Bool, timestamp: String, guiClientHandle: Handle = 0) -> Void {
  //        if (netCwStream.isActive) {
  //            // If the GUI Client Handle was not specified, assume that this is the GUIClient, and use it as the Client Handle.
  //            // Otherwise, use the passed in guiClientHandle.  This will usually be done for non-gui clients that have been
  //            // bound to a different GUIClient context.
  //            if let cwGuiClientHandle = (guiClientHandle == 0 ? Api.sharedInstance.connectionHandle : guiClientHandle) {
  //                netCwStream.cwKey(state: state, timestamp: timestamp, guiClientHandle: cwGuiClientHandle)
  //            }
  //        }
  //    }
  //
  //    public func cwPTT(state: Bool, timestamp: String, guiClientHandle: Handle = 0) -> Void {
  //        if (netCwStream.isActive) {
  //            // If the GUI Client Handle was not specified, assume that this is the GUIClient, and use it as the Client Handle.
  //            // Otherwise, use the passed in guiClientHandle.  This will usually be done for non-gui clients that have been
  //            // bound to a different GUIClient context.
  //            if let cwGuiClientHandle = (guiClientHandle == 0 ? Api.sharedInstance.connectionHandle : guiClientHandle) {
  //                netCwStream.cwPTT(state: state, timestamp: timestamp, guiClientHandle: cwGuiClientHandle)
  //            }
  //        }
  //    }
  
  // ----------------------------------------------------------------------------
  // MARK: - DaxIqStream methods
  
  //    public func requestDaxIqStream(_ channel: String, replyhandler: ReplyHandler? = nil) {
  //        // tell the Radio to create the Stream
  //        _api.send("stream create type=dax_iq daxiq_channel=\(channel)", replyProcessor: replyProcessor)
  //    }
  //
  //    public func findDaxIqStream(using channel: Int) -> DaxIqStream? {
  //        // find the IQ Streams with the specified Channel (if any)
  //        let selectedStreams = daxIqStreams.values.filter { $0.channel == channel }
  //        guard selectedStreams.count >= 1 else { return nil }
  //
  //        // return the first one
  //        return selectedStreams[0]
  //    }
  
  // ----------------------------------------------------------------------------
  // MARK: - DaxMicAudioStream methods
  
  //    public func requestDaxMicAudioStream(callback: ReplyProcessor? = nil) {
  //        // tell the Radio to create a Stream
  //        _api.send("stream create type=dax_mic", replyProcessor: replyProcessor)
  //    }
  
  // ----------------------------------------------------------------------------
  // MARK: - DaxRxAudioStream methods
  
  //    public func requestDaxRxAudioStream(_ channel: String, replyhandler: ReplyHandler? = nil) {
  //        // tell the Radio to create a Stream
  //        _api.send("stream create type=dax_rx dax_channel=\(channel)", replyProcessor: replyProcessor)
  //    }
  //
  //    public func findDaxRxAudioStream(with channel: Int) -> DaxRxAudioStream? {
  //        // find the DaxRxAudioStream with the specified Channel (if any)
  //        let streams = daxRxAudioStreams.values.filter { $0.daxChannel == channel }
  //        guard streams.count >= 1 else { return nil }
  //
  //        // return the first one
  //        return streams[0]
  //    }
  
  // ----------------------------------------------------------------------------
  // MARK: - DaxTxAudioStream methods
  
//  public func requestDaxTxAudioStream(callback: ReplyProcessor? = nil) {
//    // tell the Radio to create a Stream
//    _apiModel.sendCommand("stream create type=dax_tx", replyProcessor: replyProcessor)
//  }
//  
//  // ----------------------------------------------------------------------------
//  // MARK: - Equalizer methods
//  
//  public func requestEqualizerInfo(_ eqType: String, replyProcessor:  ReplyProcessor? = nil) {
//    // ask the Radio for an Equalizer's settings
//    ObjectModel.shared.sendTcp("eq " + eqType + " info", replyProcessor: replyProcessor)
//  }
  
  // ----------------------------------------------------------------------------
  // MARK: -  GuiClient methods
  
//  public func findHandle(for clientId: String?) -> Handle? {
//    guard clientId != nil else { return nil }
//    
//    for client in guiClients where client.clientId == clientId {
//      return client.handle
//    }
//    return nil
//  }
//  
//  public func findClientId(for station: String) -> String? {
//    for client in guiClients where client.station == station {
//      return client.clientId
//    }
//    return nil
//  }
  
//  public func bindToGuiClient(_ clientId: String?, replyProcessor:  ReplyProcessor? = nil) {
//    if let clientId = clientId, _connectionType == .nonGui, boundClientId == nil {
//      apiModel.sendTcp("client bind client_id=" + clientId, replyProcessor: replyProcessor)
//    }
//    boundClientId = clientId
//  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Interlock methods
  
//  /// Change the MOX property when an Interlock state change occurs
//  ///
//  /// - Parameter state:            a new Interloack state
//  func interlockStateChange(_ state: String) {
//    let currentMox = mox
//    
//    // if PTT_REQUESTED or TRANSMITTING
//    if state == Interlock.States.pttRequested.rawValue || state == Interlock.States.transmitting.rawValue {
//      // and mox not on, turn it on
//      if currentMox == false { mox = true }
//      
//      // if READY or UNKEY_REQUESTED
//    } else if state == Interlock.States.ready.rawValue || state == Interlock.States.unKeyRequested.rawValue {
//      // and mox is on, turn it off
//      if currentMox == true { mox = false  }
//    }
//  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Meter methods
  
  //    public func findMeters(on sliceId: SliceId) -> [Meter] {
  //        // find the Meters on the specified Slice (if any)
  //        return meters.values.filter { $0.source == "slc" && $0.group.objectId == sliceId }
  //    }
  //
  //    public func findMeter(shortName name: MeterName) -> Meter? {
  //        // find the Meters with the specified Name (if any)
  //        let selectedMeters = meters.values.filter { $0.name == name }
  //        guard selectedMeters.count >= 1 else { return nil }
  //
  //        // return the first one
  //        return selectedMeters[0]
  //    }
  //
  //    public func subscribeMeter(id: MeterId) {
  //        // subscribe to the specified Meter
  //        _api.send("sub meter \(id)")
  //    }
  //
  //    public func unSubscribeMeter(id: MeterId) {
  //        // unsubscribe from the specified Meter
  //        _api.send("unsub meter \(id)")
  //    }
  //
  //    public func requestMeterList(callback: ReplyProcessor? = nil) {
  //        // ask the Radio for a list of Meters
  //        _api.send("meter list", replyProcessor: replyProcessor)
  //    }
  
  // ----------------------------------------------------------------------------
  // MARK: - Memory methods
  
  //    public func requestMemory(callback: ReplyProcessor? = nil) {
  //        // tell the Radio to create a Memory
  //        _api.send("memory create", replyProcessor: replyProcessor)
  //    }
  
  // ----------------------------------------------------------------------------
  // MARK: - Panadapter methods
  
//  public func requestRfGainList(_ streamId: UInt32, replyhandler: ReplyHandler? = nil) {
//    ObjectModel.shared.sendTcp("display pan rfgain_info \(streamId.hex)", replyProcessor: replyProcessor)
//  }

  //    public func requestPanadapter(_ dimensions: CGSize = CGSize(width: 100, height: 100), replyhandler: ReplyHandler? = nil) {
  //        // tell the Radio to create a Panafall (if any available)
  //        if availablePanadapters > 0 {
  //            _api.send("display panafall create x=\(dimensions.width) y=\(dimensions.height)", replyProcessor: replyProcessor)
  //        }
  //    }
  //
  //    public func findActivePanadapter() -> Panadapter? {
  //        // find the Panadapters with an active Slice (if any)
  //        let selectedPanadapters = panadapters.values.filter { findActiveSlice(on: $0.id) != nil }
  //        guard selectedPanadapters.count >= 1 else { return nil }
  //
  //        // return the first one
  //        return selectedPanadapters[0]
  //    }
  //
  //    public func findPanadapterId(using channel: Int) -> PanadapterStreamId? {
  //        // find the Panadapters with the specified Channel (if any)
  //        for (id, panadapter) in panadapters where panadapter.daxIqChannel == channel {
  //            // return the first one
  //            return id
  //        }
  //        // none found
  //        return nil
  //    }
  
  // ----------------------------------------------------------------------------
  // MARK: - Radio methods
  
//  public func requestSubAll(callback: ReplyProcessor? = nil) {
//    apiModel.sendTcp("sub tx all")
//    apiModel.sendTcp("sub atu all")
//    apiModel.sendTcp("sub amplifier all")
//    apiModel.sendTcp("sub meter all")
//    apiModel.sendTcp("sub pan all")
//    apiModel.sendTcp("sub slice all")
//    apiModel.sendTcp("sub gps all")
//    apiModel.sendTcp("sub audio_stream all")
//    apiModel.sendTcp("sub cwx all")
//    apiModel.sendTcp("sub xvtr all")
//    apiModel.sendTcp("sub memories all")
//    apiModel.sendTcp("sub daxiq all")
//    apiModel.sendTcp("sub dax all")
//    apiModel.sendTcp("sub usb_cable all")
//    apiModel.sendTcp("sub tnf all")
//    apiModel.sendTcp("sub client all")
//    //      send("sub spot all")    // TODO:
//  }
//
//  public func requestMtuLimit(_ size: Int, replyhandler: ReplyHandler? = nil) {
//    apiModel.sendTcp("client set enforce_network_mtu=1 network_mtu=\(size)")
//  }
//
//  public func requestLowBandwidthDax(_ enable: Bool, replyhandler: ReplyHandler? = nil) {
//    apiModel.sendTcp("client set send_reduced_bw_dax=\(enable.as1or0)")
//  }
//
//  public func requestAntennaList(callback: ReplyProcessor? = nil) {
//    apiModel.sendTcp("ant list", replyProcessor: replyProcessor)
//  }
//
//  public func requestCwKeyImmediate(state: Bool, replyhandler: ReplyHandler? = nil) {
//    apiModel.sendTcp("cw key immediate" + " \(state.as1or0)", replyProcessor: replyProcessor)
//  }
//
////  public func requestInfo(callback: ReplyProcessor? = nil) {
////    apiModel.sendTcp("info", replyProcessor: replyProcessor )
////  }
////
//  public func requestLicense(callback: ReplyProcessor? = nil) {
//    apiModel.sendTcp("license refresh", replyProcessor: replyProcessor)
//  }
//
//  public func requestLowBandwidthConnect(callback: ReplyProcessor? = nil) {
//    apiModel.sendTcp("client low_bw_connect", replyProcessor: replyProcessor)
//  }
//
//  public func requestMicList(callback: ReplyProcessor? = nil) {
//    apiModel.sendTcp("mic list", replyProcessor: replyProcessor)
//  }
//
//  public func requestPersistenceOff(callback: ReplyProcessor? = nil) {
//    apiModel.sendTcp("client program start_persistence off", replyProcessor: replyProcessor)
//  }
//
//  public func requestDisplayProfile(callback: ReplyProcessor? = nil) {
//    apiModel.sendTcp("profile display info", replyProcessor: replyProcessor)
//  }
//
//  public func requestGlobalProfile(callback: ReplyProcessor? = nil) {
//    apiModel.sendTcp("profile global info", replyProcessor: replyProcessor)
//  }
//
//  public func requestMicProfile(callback: ReplyProcessor? = nil) {
//    apiModel.sendTcp("profile mic info", replyProcessor: replyProcessor)
//  }
//
//  public func requestTxProfile(callback: ReplyProcessor? = nil) {
//    apiModel.sendTcp("profile tx info", replyProcessor: replyProcessor)
//  }
//
//  public func requestReboot(callback: ReplyProcessor? = nil) {
//    apiModel.sendTcp("radio reboot", replyProcessor: replyProcessor)
//  }
//
//  public func requestUptime(callback: ReplyProcessor? = nil) {
//    apiModel.sendTcp("radio uptime", replyProcessor: replyProcessor)
//  }
//
//  public func requestVersion(callback: ReplyProcessor? = nil) {
//    apiModel.sendTcp("version", replyProcessor: replyProcessor )
//  }
//
////  public func requestVersion(callback: ReplyProcessor? = nil) async throws {
////    let version = try await sendAwaitReply("version", replyProcessor: replyProcessor )
////    parseVersionReply(version.keyValuesArray(delimiter: "#") )
////  }
//
//  public func staticNetParamsReset(callback: ReplyProcessor? = nil) {
//    apiModel.sendTcp("radio static_net_params" + " reset", replyProcessor: replyProcessor)
//  }
//
//  public func staticNetParamsSet(callback: ReplyProcessor? = nil) {
//    apiModel.sendTcp("radio static_net_params" + " ip=\(staticIp) gateway=\(staticGateway) netmask=\(staticMask)")
//  }
  
  // ----------------------------------------------------------------------------
  // MARK: -  RemoteRxAudioStream methods
  
//  public func requestRemoteRxAudioStream(compression: String = RemoteRxAudioStream.Compression.opus.rawValue, replyhandler: ReplyHandler? = nil) async throws -> String {
//    try await sendAwaitReply("stream create type=remote_audio_rx compression=\(compression)", replyProcessor: replyProcessor)
//  }
  
//  public func removeRemoteRxAudioStream() {
//    streamModel.removeRemoteRxAudioStream(connectionHandle)
//  }
  
  // ----------------------------------------------------------------------------
  // MARK: -  RemoteTxAudioStream methods
  
//  public func requestRemoteTxAudioStream(callback: ReplyProcessor? = nil)  async throws -> String {
//    try await sendAwaitReply("stream create type=remote_audio_tx", replyProcessor: replyProcessor)
//  }
  
//  public func removeRemoteTxAudioStream() {
//    streamModel.removeRemoteTxAudioStream(connectionHandle)
//  }

  // ----------------------------------------------------------------------------
  // MARK: - Slice methods
  
//      public func requestSlice(callback: ReplyProcessor? = nil) {
//        apiModel.sendTcp("slice create", replyProcessor: replyProcessor)
//      }
  
//      public func requestSlice(id: UInt32 = 0, mode: String = "", frequency: Hz = 0,  rxAntenna: String = "", usePersistence: Bool = false, replyhandler: ReplyHandler? = nil) {
//          if availableSlices > 0 {
//  
//              var cmd = "slice create"
//              if id != 0          { cmd += " pan=\(id.hex)" }
//              if frequency != 0   { cmd += " freq=\(frequency.hzToMhz)" }
//              if rxAntenna != ""  { cmd += " rxant=\(rxAntenna)" }
//              if mode != ""       { cmd += " mode=\(mode)" }
//              if usePersistence   { cmd += " load_from=PERSISTENCE" }
//  
//              // tell the Radio to create a Slice
//            apiModel.sendTcp(cmd, replyProcessor: replyProcessor)
//          }
//      }
//  
//      public func requestSlice(panadapter: Panadapter, frequency: Hz = 0, replyhandler: ReplyHandler? = nil) {
//          if availableSlices > 0 {
//            apiModel.sendTcp("slice create " + "pan" + "=\(panadapter.id.hex) \(frequency == 0 ? "" : "freq" + "=\(frequency.hzToMhz)")", replyProcessor: replyProcessor)
//          }
//      }
  
  //    public func disableSliceTx() {
  //        // for all Slices, turn off txEnabled
  //        for (_, slice) in slices where slice.txEnabled {
  //            slice.txEnabled = false
  //        }
  //    }
  //
//  public func findAllSlices(on id: PanadapterId) -> IdentifiedArrayOf<Slice>? {
//    // find the Slices on the Panadapter (if any)
//    let filteredSlices = objects.slices.filter { $0.panadapterId == id }
//    guard filteredSlices.count >= 1 else { return nil }
//
//    return filteredSlices
//  }
  
//  public func findSlice(on id: PanadapterId, at freq: Hz, width: Int) -> Slice? {
//    // find the Slices on the Panadapter (if any)
//    if let filteredSlices = findAllSlices(on: id) {
//
//      // find the ones in the frequency range
//      let selectedSlices = filteredSlices.filter { freq >= $0.frequency + Hz(min(-width/2, $0.filterLow)) && freq <= $0.frequency + Hz(max(width/2, $0.filterHigh))}
//      guard selectedSlices.count >= 1 else { return nil }
//      // return the first one
//      return selectedSlices[0]
//
//    } else {
//      return nil
//    }
//  }
  //
  //    public func findActiveSlice() -> xLib6001.Slice? {
  //        // find the active Slices (if any)
  //        let filteredSlices = slices.values.filter { $0.active }
  //        guard filteredSlices.count >= 1 else { return nil }
  //
  //        // return the first one
  //        return filteredSlices[0]
  //    }
  //
  //    public func findActiveSlice(on id: PanadapterStreamId) -> xLib6001.Slice? {
  //        // find the active Slices on the specified Panadapter (if any)
  //        let filteredSlices = slices.values.filter { $0.active && $0.panadapterId == id }
  //        guard filteredSlices.count >= 1 else { return nil }
  //
  //        // return the first one
  //        return filteredSlices[0]
  //    }
  //
  //    public func findFirstSlice(on id: PanadapterStreamId) -> xLib6001.Slice? {
  //        // find the Slices on the specified Panadapter (if any)
  //        let filteredSlices = slices.values.filter { $0.panadapterId == id }
  //        guard filteredSlices.count >= 1 else { return nil }
  //
  //        // return the first one
  //        return filteredSlices[0]
  //    }
  //
//  public func findSlice(using channel: Int) -> Slice? {
//    // find the Slices with the specified Channel (if any)
//    let filteredSlices = objects.slices.filter { $0.daxChannel == channel }
//    guard filteredSlices.count >= 1 else { return nil }
//
//    // return the first one
//    return filteredSlices[0]
//  }
  
//  public func findSlice(letter: String, guiClientHandle: Handle) -> Slice? {
//    // find the Slices with the specified Channel (if any)
//    let filteredSlices = objects.slices.filter { $0.sliceLetter == letter && $0.clientHandle == guiClientHandle }
//    guard filteredSlices.count >= 1 else { return nil }
//    
//    // return the first one
//    return filteredSlices[0]
//  }
  
  //    public func getTransmitSliceForHandle(_ guiClientHandle: Handle) -> xLib6001.Slice? {
  //        // find the Slices with the specified Channel (if any)
  //        let filteredSlices = slices.values.filter { $0.txEnabled && $0.clientHandle == guiClientHandle }
  //        guard filteredSlices.count >= 1 else { return nil }
  //
  //        // return the first one
  //        return filteredSlices[0]
  //    }
  //
  //    public func getTransmitSliceForClientId(_ guiClientId: String) -> xLib6001.Slice? {
  //        // find the GUI client for the ID
  //        if let handle = findHandle(for: guiClientId) {
  //            // find the Slices with the specified Channel (if any)
  //            let filteredSlices = slices.values.filter { $0.txEnabled && $0.clientHandle == handle }
  //            guard filteredSlices.count >= 1 else { return nil }
  //
  //            // return the first one
  //            return filteredSlices[0]
  //        }
  //        return nil
  //    }
  
  // ----------------------------------------------------------------------------
  // MARK: - Tnf methods
  
  /// Remove a Tnf
  /// - Parameters:
  ///   _ id:                            a TnfId
  ///   - callback:     ReplyHandler (optional)
//  public func removeTnf(_ id: TnfId, replyhandler: ReplyHandler? = nil) {
//    send("tnf remove " + " \(id)", replyProcessor: replyProcessor)
//    
//    // remove it immediately (Tnf does not send status on removal)
//    Tnf.remove(id)
//    
//    log("Tnf, removed: id = \(id)", .debug, #function, #file, #line)
//  }
//  public func requestTnf(at frequency: Hz, replyhandler: ReplyHandler? = nil) {
//    send("tnf create " + "freq" + "=\(frequency.hzToMhz)", replyProcessor: replyProcessor)
//  }
  
//  public func findTnf(at freq: Hz, minWidth: Hz) -> Tnf? {
//    // return the Tnfs within the specified Frequency / minimum width (if any)
//    let filteredTnfs = Model.shared.tnfs.filter { freq >= ($0.frequency - Hz(max(minWidth, $0.width/2))) && freq <= ($0.frequency + Hz(max(minWidth, $0.width/2))) }
//    guard filteredTnfs.count >= 1 else { return nil }
//    
//    // return the first one
//    return filteredTnfs[0]
//  }
  
  // ----------------------------------------------------------------------------
  // MARK: - WanServer methods
  
  //    public func smartlinkConfigure(tcpPort: Int, udpPort: Int, replyhandler: ReplyHandler? = nil) {
  //        send("wan set " + "public_tls_port" + "=\(tcpPort)" + " public_udp_port" + "=\(udpPort)", replyProcessor: replyProcessor)
  //    }
  
  // ----------------------------------------------------------------------------
  // MARK: - Xvtr methods
  
  //    public func requestXvtr(callback: ReplyProcessor? = nil) {
  //        send("xvtr create" , replyProcessor: replyProcessor)
  //    }
//}
