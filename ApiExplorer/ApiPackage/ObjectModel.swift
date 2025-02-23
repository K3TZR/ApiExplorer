//
//  ObjectModel.swift
//
//
//  Created by Douglas Adams on 10/22/23.
//

//import ComposableArchitecture
import Foundation

//import ListenerFeature
//import SharedFeature
//import VitaFeature

public typealias ActiveSelection = (radio: Radio, station: String, disconnectHandle: String?)
public typealias IdToken = String
public typealias RefreshToken = String

public struct Tokens: Sendable {
  public var idToken: String
  public var refreshToken: String

  public init(_ idToken: String, _ refreshToken: String) {
    self.idToken = idToken
    self.refreshToken = refreshToken
  }
}

@MainActor
@Observable
final public class ObjectModel: TcpProcessor {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init() {
    _udp = Udp(delegate: StreamModel())
    _tcp = Tcp(delegate: self)
    _listenerLocal = ListenerLocal(self)
    _listenerSmartlink = ListenerSmartlink(self)
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
    
  public var activeSelection: ActiveSelection?
  public internal(set) var activeSlice: Slice?
  public internal(set) var boundClientId: String?
  public internal(set) var clientInitialized = false
  public internal(set) var connectionHandle: UInt32?
  public internal(set) var hardwareVersion: String?
  public internal(set) var radio: Radio?
  public var testDelegate: TcpProcessor?
  
  // single objects
  public var atu = Atu()
  public var cwx = Cwx()
  public var gps = Gps()
  public var interlock = Interlock()
  public var remoteRxAudio: RemoteRxAudio?
  public var remoteTxAudio: RemoteTxAudio?
  public var transmit = Transmit()
  public var wan = Wan()
  public var waveform = Waveform()
  
  // collection objects
  public var amplifiers = [Amplifier]()
  public var bandSettings = [BandSetting]()
  public var equalizers = [Equalizer]()
  public var memories = [Memory]()
  public var meters = [Meter]()
  public var panadapters = [Panadapter]()
  public var profiles = [Profile]()
  public var radios = [Radio]()
  public var slices = [Slice]()
  public var tnfs = [Tnf]()
  public var usbCables = [String:UsbCable]()
  public var waterfalls = [Waterfall]()
  public var xvtrs = [Xvtr]()
  
  // single stream objects
  public var daxMicAudio: DaxMicAudio?
  public var daxTxAudio: DaxTxAudio?
  //  public var meterStream: MeterStream?
  //  public var remoteTxAudioStream: RemoteTxAudioStream?
  
  // collection stream objects
  public var daxIqs = [UInt32:DaxIq]()
  public var daxRxAudios = [UInt32:DaxRxAudio]()
  //  public var panadapterStreams = [UInt32:PanadapterStream]()
  //  public var waterfallStreams = [UInt32:WaterfallStream]()
  
  // ----------------------------------------------------------------------------
  // MARK: - Public types
  
  public enum ObjectType: String {
    case amplifier
    case atu
    case bandSetting = "band"
    case client
    case cwx
    case display
    case equalizer = "eq"
    case gps
    case interlock
    case memory
    case meter
    case panadapter = "pan"
    case profile
    case radio
    case slice
    case stream
    case tnf
    case transmit
    case usbCable = "usb_cable"
    case wan
    case waterfall
    case waveform
    case xvtr
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _awaitFirstStatusMessage: CheckedContinuation<(), Never>?
  private var _awaitWanValidation: CheckedContinuation<String, Never>?
  private var _awaitClientIpValidation: CheckedContinuation<String, Never>?
  private var _firstStatusMessageReceived: Bool = false
  private var _guiClientId: String?
  private var _listenerSmartlink: ListenerSmartlink?
  private var _listenerLocal: ListenerLocal?
  private var _pinger: Pinger?
  private let _replyDictionary = ReplyDictionary()
  private let _sequencer = Sequencer()
  private var _tcp: Tcp!
  private let _udp: Udp!
  private var _wanHandle: String?
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Connection methods
  
  /// Connect to a Radio
  /// - Parameters:
  ///   - selection: a PickerSelection instance
  ///   - isGui: true = GUI
  ///   - programName: program name
  ///   - mtuValue: max transport unit
  ///   - guiClientID: a UUID identifying the station
  ///   - lowBandwidthDax: true = use low bw DAX
  ///   - lowBandwidthConnect: true = minimize connection bandwidth
  public func connect(selection: ActiveSelection,
                      isGui: Bool,
                      programName: String,
                      mtuValue: Int,
                      guiClientId: UUID,
                      lowBandwidthDax: Bool = false,
                      lowBandwidthConnect: Bool = false,
                      testDelegate: TcpProcessor? = nil) async throws {
    
    self.testDelegate = testDelegate
    
    
    guard connect(to: selection.radio) else { throw ApiError.connection }
    log.debug("ApiModel: Tcp connection established")
    
    if selection.disconnectHandle != nil {
      // pending disconnect
      sendTcp("client disconnect \(selection.disconnectHandle!)")
    }
    
    // wait for the first Status message with my handle
    await awaitFirstStatusMessage()
    log.debug("ApiModel: First status message received")
    
    // is this a Wan connection?
    if selection.radio.packet.source == .smartlink {
      // YES, send Wan Connect message & wait for the reply
      _wanHandle = try await self._listenerSmartlink?.smartlinkConnect(for: selection.radio.packet.serial, holePunchPort: selection.radio.packet.negotiatedHolePunchPort)
      if _wanHandle == nil { throw ApiError.connection }
      log.debug("ObjectModel: wanHandle received")
      
      // send Wan Validate & wait for the reply
      log.debug("ObjectModel: Wan validate sent for handle=\(self._wanHandle!)")
      let replyComponents = await sendTcpAwaitReply("wan validate handle=\(_wanHandle!)")
//      let reply = await wanValidation()
      log.debug("ObjectModel: Wan validation = \(replyComponents)")
    }
    
    // bind UDP
    let ports = _udp.bind(selection.radio.packet.source == .smartlink,
                          selection.radio.packet.publicIp,
                          selection.radio.packet.requiresHolePunch,
                          selection.radio.packet.negotiatedHolePunchPort,
                          selection.radio.packet.publicUdpPort)
    guard ports != nil else { _tcp.disconnect() ; throw ApiError.udpBind }
    log.debug("ObjectModel: UDP bound, receive port = \(ports!.0), send port = \(ports!.1)")
    
    // is this a Wan connection?
    if selection.radio.packet.source == .smartlink {
      // send Wan Register (no reply)
      sendUdp("client udp_register handle=" + connectionHandle!.hex )
      log.debug("ObjectModel: UDP registration sent")
      
      // send Client Ip & wait for the reply
      let replyComponents = await sendTcpAwaitReply("client ip")
//      sendTcp("client ip", replyHandler: ipReplyHandler)
//      let reply = await clientIpValidation()
      log.debug("ObjectModel: Client ip = \(replyComponents)")
    }
    
    // send the initial commands
    sendInitialCommands(isGui, programName, selection.station, mtuValue, lowBandwidthDax, lowBandwidthConnect, guiClientId)
    log.info("ObjectModel: initial commands sent (isGui = \(isGui))")
    
    startPinging()
    log.debug("ObjectModel: pinging \(selection.radio.packet.publicIp)")
    
    // set the UDP port for a Local connection
    if selection.radio.packet.source == .local {
      sendTcp("client udpport " + "\(_udp.sendPort)")
      log.info("ObjectModel: Client Udp port set to \(self._udp.sendPort)")
    }
  }
  
  /// Disconnect the current Radio and remove all its objects / references
  /// - Parameter reason: an optional reason
  public func disconnect(_ reason: String? = nil) async {
    if reason == nil {
      log.debug("ApiModel: Disconnect, \((reason == nil ? "User initiated" : reason!))")
    }
    
    _firstStatusMessageReceived = false
    
    // stop pinging (if active)
    stopPinging()
    log.debug("ApiModel: Pinging STOPPED")
    
    connectionHandle = nil
    
    // stop udp
    _udp.unbind()
    log.debug("ApiModel: Disconnect, UDP unbound")
    
    _tcp.disconnect()
    
    activeSelection = nil
    removeAllObjects()
    
    await _replyDictionary.removeAll()
    await _sequencer.reset()
    log.debug("ApiModel: Disconnect, Objects removed")
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public TCP message processor
  
  nonisolated public func tcpProcessor(_ msg: String, isInput: Bool) {
    Task { await MainActor.run {
      
      // received messages sent to the Tester
      testDelegate?.tcpProcessor(msg, isInput: true)
      
      // the first character indicates the type of message
      switch msg.prefix(1).uppercased() {
        
      case "H":  connectionHandle = String(msg.dropFirst()).handle ; log.debug("Api: connectionHandle = \(self.connectionHandle?.hex ?? "missing")")
      case "M":  parseMessage( msg )
      case "R":  replyProcessor( msg )
      case "S":  parseStatus( msg )
      case "V":  hardwareVersion = String(msg.dropFirst())
      default:   log.warning("ApiModel: unexpected message = \(msg)")
      }
    }}
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public Send methods
  
  /// Send a command to the Radio (hardware) via TCP
  /// - Parameters:
  ///   - command:        a Command to be sent
  ///   - diagnostic:     use "D"iagnostic form
  ///   - replyHandler:   an optional function to handle a reply
  public func sendTcp(_ command: String, diagnostic: Bool = false, replyHandler: ReplyHandler? = nil) {
    Task {
      // assign sequenceNumber
      let sequenceNumber = await _sequencer.next()
        
      // register to be notified when reply received
      await _replyDictionary.add(sequenceNumber, ReplyEntry(command, replyHandler))

      // assemble the command
      let command = "C" + "\(diagnostic ? "D" : "")" + "\(sequenceNumber)|" + command
      
      // tell TCP to send it
      _tcp.send(command + "\n", sequenceNumber)
      
      // sent messages provided to the Tester (if Tester exists)
      testDelegate?.tcpProcessor(command, isInput: true)
    }
  }
 
  
  private var _tcpReply: CheckedContinuation<(Int, String, String), Never>?
  
  public func sendTcpAwaitReply(_ cmd: String, diagnostic: Bool = false) async -> (Int, String, String)  {
    // assign sequenceNumber
    let sequenceNumber = await _sequencer.next()
    //      // register to be notified when reply received
    //      await _replyDictionary.add(sequenceNumber, ReplyEntry(cmd, replyHandler))
    
    // assemble the command
    let command =  "C" + "\(diagnostic ? "D" : "")" + "\(sequenceNumber)|" + cmd
    
    // tell TCP to send it
    _tcp.send(command + "\n", sequenceNumber)
    
    // sent messages provided to the Tester (if Tester exists)
    testDelegate?.tcpProcessor(command, isInput: true)
    
    // wait for the reply
    let replyComponents = await tcpReply()
    _tcpReply = nil
    log.debug("Api: TCP reply = \(replyComponents)")
    
    return replyComponents
  }

  
  
  
  
  
  
  /// Send data to the Radio (hardware) via UDP
  /// - Parameters:
  ///   - data: a Data
  public func sendUdp(_ data: Data) {
    // tell Udp to send the Data message
    _udp.send(data)
  }
  
  /// Send data to the Radio (hardware) via UDP
  /// - Parameters:
  ///   - string: a String
  public func sendUdp(_ string: String) {
    // tell Udp to send the String message
    _udp.send(string)
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Packet methods
  
  
  
  private func parseGuiClients(_ properties: KeyValuesArray) -> [GuiClient] {
    var guiClients = [GuiClient]()
    var handles = [String]()
    var hosts = [String]()
    var ips = [String]()
    var programs = [String]()
    var stations = [String]()
    
    enum Property: String {
      case guiClientHandles           = "gui_client_handles"
      case guiClientHosts             = "gui_client_hosts"
      case guiClientIps               = "gui_client_ips"
      case guiClientPrograms          = "gui_client_programs"
      case guiClientStations          = "gui_client_stations"
    }
    
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      switch Property(rawValue: property.key) {
        
      case .guiClientHandles:           handles = property.value.replacingOccurrences(of: "\u{7F}", with: "").valuesArray(delimiter: ",")
      case .guiClientHosts:             hosts = property.value.replacingOccurrences(of: "\u{7F}", with: "").valuesArray(delimiter: ",")
      case .guiClientIps:               ips = property.value.replacingOccurrences(of: "\u{7F}", with: "").valuesArray(delimiter: ",")
      case .guiClientPrograms:          programs = property.value.replacingOccurrences(of: "\u{7F}", with: "").valuesArray(delimiter: ",")
      case .guiClientStations:          stations = property.value.replacingOccurrences(of: "\u{7F}", with: "").valuesArray(delimiter: ",")
      default:                          break
      }
    }
    // all three must be populated
    if (programs.isEmpty || stations.isEmpty || handles.isEmpty || ips.isEmpty || hosts.isEmpty) == false {
      // must be an equal number of entries in each
      if programs.count == stations.count && programs.count == handles.count && programs.count == ips.count && programs.count == hosts.count {
        for (i, handle) in handles.enumerated() {
          guiClients.append( GuiClient( handle: handle, station: stations[i], program: programs[i], ip: ips[i], host: hosts[i] ) )
        }
      }
    }
    return guiClients
  }

  
  
  
  
  
  /// Process an incoming DiscoveryPacket
  /// - Parameter packet: a received packet
  public func process(_ source: PacketSource, _ properties: KeyValuesArray, _ discoveryData: Data?) {
    
//    print("----->>>>>", guiClients)
    let packet = Packet(source, properties)
    let guiClients = parseGuiClients(properties)
    
    let name = packet.nickname.isEmpty ? packet.model : packet.nickname
    
    // is it a Radio that has been seen previously?
    if let index = radios.firstIndex(where: {$0.packet.id == packet.id}) {

      // KNOWN RADIO, has it's packet changed?
      if radios[index].packet != packet {
        // YES, overwrite the Packet
        radios[index].packet = packet
      }
      // update the TimeStamp
      radios[index].lastSeen = Date()
      radios[index].discoveryData = discoveryData


      // KNOWN RADIO, has it's guiClients changed?
      if radios[index].guiClients != guiClients {
//        // YES, identify removed Stations
//        let removedClients = Set(radios[index].guiClients).subtracting(Set(guiClients))
//        for guiClient in removedClients {
//          log.info("ObjectModel: Station <\(guiClient.station)>, Program <\(guiClient.program)>, Handle <\(guiClient.handle)>, Ip <\(guiClient.ip)>, Host <\(guiClient.host)> on Radio <\(name)> - REMOVED")
//        }
//        // identify added Stations
//        let addedClients = Set(guiClients).subtracting(Set(radios[index].guiClients))
//        for guiClient in addedClients {
//          log.info("ObjectModel: Station <\(guiClient.station)>, Program <\(guiClient.program)>, Handle <\(guiClient.handle)>, Ip <\(guiClient.ip)>, Host <\(guiClient.host)> on Radio <\(name)> - ADDED")
//        }
        
        radios[index].guiClients = guiClients
        log.info("Process: GuiClients changed on Radio <\(name)>")
        for guiClient in guiClients {
          log.info("Process: Handle <\(guiClient.handle)>, Station <\(guiClient.station)>, Program <\(guiClient.program)>, Ip <\(guiClient.ip)>, Host <\(guiClient.host)> on Radio <\(name)>")
        }
//        radios[index].packet.stations = packet.stations
     }

    } else {
            
      // UNKNOWN radio, add it
      radios.append(Radio(packet, guiClients, discoveryData))
      log.info("ObjectModel: Radio <\(name)>, Serial <\(packet.serial)>, Source <\(packet.source == .local ? "Local" : "Smartlink")> - ADDED")

      // log the GuiClients
      for guiClient in guiClients {
        log.info("ObjectModel: Station <\(guiClient.station)>, Program <\(guiClient.program)>, Handle <\(guiClient.handle)>, on Radio <\(name)> - ADDED")
      }
    }
  }

  /// Remove one or more Radios of a given source
  public func removeRadios(_ source: PacketSource) {
    for (i, radio) in radios.enumerated().reversed() where radio.packet.source == source {
      let name = radio.packet.nickname.isEmpty ? radio.packet.model : radio.packet.nickname
      for guiClient in radio.guiClients {
        log.info("ObjectModel: Station <\(guiClient.station)>, Program <\(guiClient.program)>, Handle <\(guiClient.handle)>, on Radio <\(name)> - WILL BE REMOVED")
      }
      // remove Discovery
      radios.remove(at: i)
      log.info("ObjectModel: Radio <\(name)>, Serial <\(radio.packet.serial)>, Source <\(radio.packet.source == .local ? "Local" : "Smartlink")> - REMOVED")
    }
  }

  /// Remove one or more Radios that are no longer visible
  public func removeLostRadios(_ now: Date, _ timeout: TimeInterval) {
    for (i, radio) in radios.enumerated().reversed() where radio.packet.source == .local {
      let interval = abs(radio.lastSeen.timeIntervalSince(now))
      if interval > timeout {
        let name = radio.packet.nickname.isEmpty ? radio.packet.model : radio.packet.nickname
        for guiClient in radio.guiClients {
          log.info("ObjectModel: Station <\(guiClient.station)>, Program <\(guiClient.program)>, Handle <\(guiClient.handle)>, on Radio <\(name)> - WILL BE REMOVED")
        }

        // remove Discovery
        radios.remove(at: i)
        log.info("ObjectModel: Radio <\(name)>, Serial <\(radio.packet.serial)>, Source <\(radio.packet.source == .local ? "Local" : "Smartlink")> - REMOVED due to timeout (\(interval) seconds)")
      }
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func startLocalListener() {
    // start local listener
    _listenerLocal = ListenerLocal(self)
    _listenerLocal!.start()
  }
  
  public func stopLocalListener() {
    // stop local listener
    _listenerLocal?.stop()
    _listenerLocal = nil
    removeRadios(.local)
  }

  public func startSmartlinkListener() async {
    // start smartlink listener
    await _listenerSmartlink?.start("douglas.adams@me.com", "fleX!20Comm")
  }

  public func startSmartlinkListener(_ user: String, _ password: String) async {
    // start smartlink listener
    await _listenerSmartlink?.start(user, password)
  }
  
  public func stopSmartlinkListener() {
    // stop smartlink listener
    _listenerSmartlink?.stop()
    removeRadios(.smartlink)
  }


  public func clientInitialized(_ state: Bool) {
    clientInitialized = state
  }
  
  public func parse(_ statusType: String, _ statusMessage: String, _ connectionHandle: UInt32?) {
    
    // Check for unknown Object Types
    guard let objectType = ObjectType(rawValue: statusType)  else {
      // log it and ignore the message
      log.warning("ObjectModel: unknown status token = \(statusType)")
      return
    }
    
    switch objectType {
    case .amplifier:            Amplifier.status(self, statusMessage.keyValuesArray(), !statusMessage.contains(kRemoved))
    case .atu:                  atu.parse(Array(statusMessage.keyValuesArray() ))
    case .bandSetting:          BandSetting.status(self, Array(statusMessage.keyValuesArray().dropFirst(1) ), !statusMessage.contains(kRemoved))
    case .client:               preProcessClient(statusMessage.keyValuesArray(), !statusMessage.contains(kDisconnected), connectionHandle)
    case .cwx:                  cwx.parse(Array(statusMessage.keyValuesArray().dropFirst(1) ))
    case .display:              preProcessDisplay(statusMessage)
    case .equalizer:            Equalizer.status(self, statusMessage.keyValuesArray(), !statusMessage.contains(kRemoved))
    case .gps:                  gps.parse(Array(statusMessage.keyValuesArray(delimiter: "#").dropFirst(1)) )
    case .interlock:            preProcessInterlock(statusMessage)
    case .memory:               Memory.status(self, statusMessage.keyValuesArray(), !statusMessage.contains(kRemoved))
    case .meter:                Meter.status(self, statusMessage.keyValuesArray(delimiter: "#"), !statusMessage.contains(kRemoved))
    case .profile:              Profile.status(self, statusMessage.keyValuesArray(delimiter: "="), !statusMessage.contains(kNotInUse))
    case .radio:                Radio.status(self, statusMessage.keyValuesArray(), !statusMessage.contains(kNotInUse))
    case .slice:                Slice.status(self, statusMessage.keyValuesArray(), !statusMessage.contains(kNotInUse))
    case .stream:               preProcessStream(statusMessage, connectionHandle)
    case .tnf:                  Tnf.status(self, statusMessage.keyValuesArray(), !statusMessage.contains(kRemoved))
    case .transmit:             preProcessTransmit(statusMessage)
    case .usbCable:             UsbCable.status(self, statusMessage.keyValuesArray(), !statusMessage.contains(kRemoved))
    case .wan:                  wan.parse(Array(statusMessage.keyValuesArray().dropFirst(1)) )
    case .waveform:             waveform.parse(Array(statusMessage.keyValuesArray(delimiter: "=").dropFirst(1)) )
    case .xvtr:                 Xvtr.status(self, statusMessage.keyValuesArray(), !statusMessage.contains(kNotInUse))
      
    case .panadapter, .waterfall: break                                                   // handled by "display"
    }
  }
  
  // ----- Meter methods -----
  
  public func meterBy(shortName: Meter.ShortName, sliceId: UInt32? = nil) -> Meter? {
    
    if sliceId == nil {
      for meter in meters where meter.name == shortName.rawValue {
        return meter
      }
    } else {
      for meter in meters where sliceId! == UInt32(meter.group) && meter.name == shortName.rawValue {
        return meter
      }
    }
    return nil
  }
  
  // ----- Slice methods -----
  
  /// Find a Slice by DAX Channel
  ///
  /// - Parameter channel:    Dax channel number
  /// - Returns:              a Slice (if any)
  ///
  public func findSlice(using channel: Int) -> Slice? {
    // find the Slices with the specified Channel (if any)
    let filteredSlices = slices.filter { $0.daxChannel == channel }
    guard filteredSlices.count >= 1 else { return nil }
    
    // return the first one
    return filteredSlices[0]
  }
  
  public func sliceMove(_ panadapterId: UInt32, _ clickFrequency: Int) {
    
    //    let slices = slices.filter{ $0.panadapterId == panadapterId }
    //    if slices.count == 1 {
    //      let roundedFrequency = clickFrequency - (clickFrequency % slices[0]!.step)
    //      sliceSet(slices.first!.key, .frequency, roundedFrequency.hzToMhz)
    //
    //    } else {
    //      let nearestSlice = slices.min{ a, b in
    //        abs(clickFrequency - a.value.frequency) < abs(clickFrequency - b.value.frequency)
    //      }
    //      if let nearestSlice {
    //        let roundedFrequency = clickFrequency - (clickFrequency % nearestSlice.value.step)
    //       sliceSet(nearestSlice.key, .frequency, roundedFrequency.hzToMhz)
    //      }
    //    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Internal methods
  
  /// Remove all Radio objects
  func removeAllObjects() {
    radio = nil
    removeAll(of: .amplifier)
    removeAll(of: .bandSetting)
    removeAll(of: .equalizer)
    removeAll(of: .memory)
    removeAll(of: .meter)
    removeAll(of: .panadapter)
    removeAll(of: .profile)
    removeAll(of: .slice)
    removeAll(of: .tnf)
    removeAll(of: .usbCable)
    removeAll(of: .waterfall)
    removeAll(of: .xvtr)
  }
  
  func removeAll(of type: ObjectType) {
    switch type {
    case .amplifier:            amplifiers.removeAll()
    case .bandSetting:          bandSettings.removeAll()
    case .equalizer:            equalizers.removeAll()
    case .memory:               memories.removeAll()
    case .meter:                meters.removeAll()
    case .panadapter:           panadapters.removeAll()
    case .profile:              profiles.removeAll()
    case .slice:                slices.removeAll()
    case .tnf:                  tnfs.removeAll()
    case .usbCable:             usbCables.removeAll()
    case .waterfall:            waterfalls.removeAll()
    case .xvtr:                 xvtrs.removeAll()
    default:            break
    }
    log.debug("ObjectModel: removed all \(type.rawValue) objects")
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private connection methods
  
  /// Connect to a Radio
  /// - Parameter params:     a struct of parameters
  /// - Returns:              success / failure
  private func connect(to radio: Radio) -> Bool {
    return _tcp.connect(radio.packet.source == .smartlink,
                        radio.packet.requiresHolePunch,
                        radio.packet.negotiatedHolePunchPort,
                        radio.packet.publicTlsPort,
                        radio.packet.port,
                        radio.packet.publicIp,
                        radio.packet.localInterfaceIP)
  }
  
  private func sendInitialCommands(_ isGui: Bool,
                                   _ programName: String,
                                   _ stationName: String,
                                   _ mtuValue: Int,
                                   _ lowBandwidthDax: Bool,
                                   _ lowBandwidthConnect: Bool,
                                   _ guiClientId: UUID) {
    
    if isGui { sendTcp("client gui \(guiClientId.uuidString)") }
    sendTcp("client program " + programName)
    if isGui { sendTcp("client station " + stationName) }
    if lowBandwidthConnect { lowBandwidthConnectRequest() }
    infoRequest()
    versionRequest()
    requestAntennaList()
    micListRequest()
    globalProfileRequest()
    txProfileRequest()
    micProfileRequest()
    displayProfileRequest()
    sendSubciptions()
    setMtuLimit(mtuValue)
    setLowBandwidthDax(lowBandwidthDax)
    uptimeRequest()
  }
  
  private func sendSubciptions(replyHandler: ReplyHandler? = nil) {
    sendTcp("sub tx all")
    sendTcp("sub atu all")
    sendTcp("sub amplifier all")
    sendTcp("sub meter all")
    sendTcp("sub pan all")
    sendTcp("sub slice all")
    sendTcp("sub gps all")
    sendTcp("sub audio_stream all")
    sendTcp("sub cwx all")
    sendTcp("sub xvtr all")
    sendTcp("sub memories all")
    sendTcp("sub daxiq all")
    sendTcp("sub dax all")
    sendTcp("sub usb_cable all")
    sendTcp("sub tnf all")
    sendTcp("sub client all")
    //      send("sub spot all")    // TODO:
  }
  
  private func startPinging() {
    // tell the Radio to expect pings
    sendTcp("keepalive enable")
    // start pinging the Radio
    _pinger = Pinger(self)
  }
  
  private func stopPinging() {
//    _pinger?.stopPinging()
    _pinger = nil
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Pre-Process methods
  
  private func preProcessClient(_ properties: KeyValuesArray, _ inUse: Bool = true, _ connectionHandle: UInt32?) {
    // is there a valid handle"
    if let handle = properties[0].key.handle {
      switch properties[1].key {
        
      case kConnected:       parseConnection(properties: properties, handle: handle, connectionHandle: connectionHandle)
      case kDisconnected:    parseDisconnection(properties: properties, handle: handle, connectionHandle: connectionHandle)
      default:                      break
      }
    }
  }
  
  private func preProcessDisplay(_ statusMessage: String) {
    let properties = statusMessage.keyValuesArray()
    // Waterfall or Panadapter?
    switch properties[0].key {
    case ObjectType.panadapter.rawValue:  Panadapter.status(self, Array(statusMessage.keyValuesArray().dropFirst()), !statusMessage.contains(kRemoved) )
    case ObjectType.waterfall.rawValue:   Waterfall.status(self, Array(statusMessage.keyValuesArray().dropFirst()), !statusMessage.contains(kRemoved) )
    default: break
    }
  }
  
  private func preProcessInterlock(_ statusMessage: String) {
    let properties = statusMessage.keyValuesArray()
    // Band Setting or Interlock?
    switch properties[0].key {
    case ObjectType.bandSetting.rawValue:   BandSetting.status(self, Array(statusMessage.keyValuesArray().dropFirst()), !statusMessage.contains(kRemoved) )
    default:                                interlock.parse(properties) ; interlockStateChange(interlock.state)
    }
  }
  
  public func preProcessStream(_ statusMessage: String, _ connectionHandle: UInt32?) {
    let properties = statusMessage.keyValuesArray()
    
    // is the 1st KeyValue a StreamId?
    if let id = properties[0].key.streamId {
      
      // is it a removal?
      if statusMessage.contains(kRemoved) {
        // YES
        removeStream(having: id)
        
      } else {
        // NO is it for me?
        if isForThisClient(properties, connectionHandle) {
          // YES
          guard properties.count > 1 else {
            log.warning("StreamModel: invalid Stream message: \(statusMessage)")
            return
          }
          guard let token = StreamType(rawValue: properties[1].value) else {
            // log it and ignore the Key
            log.warning("StreamModel: unknown Stream type: \(properties[1].value)")
            return
          }
          switch token {
            
          case .daxIqStream:          DaxIq.status(self, properties)
          case .daxMicAudioStream:    DaxMicAudio.status(self, properties)
          case .daxRxAudioStream:     DaxRxAudio.status(self, properties)
          case .daxTxAudioStream:     DaxTxAudio.status(self, properties)
          case .remoteRxAudioStream:  RemoteRxAudio.status(self, properties)
          case .remoteTxAudioStream:  RemoteTxAudio.status(self, properties)
            
          case .panadapter, .waterfall: break     // should never be seen here
          }
        }
      }
    } else {
      log.warning("StreamModel: invalid Stream message: \(statusMessage)")
    }
  }
  
  private func preProcessTransmit(_ statusMessage: String) {
    let properties = statusMessage.keyValuesArray()
    // Band Setting or Transmit?
    switch properties[0].key {
    case ObjectType.bandSetting.rawValue:   BandSetting.status(self, Array(statusMessage.keyValuesArray().dropFirst(1) ), !statusMessage.contains(kRemoved))
    default:                                transmit.parse( Array(properties.dropFirst() ))
    }
  }
  
  /// Change the MOX property when an Interlock state change occurs
  /// - Parameter state:            a new Interloack state
  private func interlockStateChange(_ state: String) {
    let currentMox = radio?.mox
    
    // if PTT_REQUESTED or TRANSMITTING
    if state == Interlock.States.pttRequested.rawValue || state == Interlock.States.transmitting.rawValue {
      // and mox not on, turn it on
      if currentMox == false { radio?.mox = true }
      
      // if READY or UNKEY_REQUESTED
    } else if state == Interlock.States.ready.rawValue || state == Interlock.States.unKeyRequested.rawValue {
      // and mox is on, turn it off
      if currentMox == true { radio?.mox = false  }
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private parse methods
  
  /// Parse a client connect status message
  /// - Parameters:
  ///   - properties: message properties as a KeyValuesArray
  ///   - handle: the radio's connection handle
  private func parseConnection(properties: KeyValuesArray, handle: UInt32, connectionHandle: UInt32?) {
    var clientId = ""
    var program = ""
    var station = ""
    var isLocalPtt = false
    
    enum Property: String {
      case clientId = "client_id"
      case localPttEnabled = "local_ptt"
      case program
      case station
    }
    
    // if handle is mine, this client is fully initialized
    clientInitialized = ( handle == connectionHandle )
    
    // parse remaining properties
    for property in properties.dropFirst(2) {
      
      // check for unknown properties
      guard let token = Property(rawValue: property.key) else {
        // log it and ignore this Key
        log.warning("ObjectModel: unknown client property, \(property.key)=\(property.value)")
        continue
      }
      // Known properties, in alphabetical order
      switch token {
        
      case .clientId:         clientId = property.value
      case .localPttEnabled:  isLocalPtt = property.value.bValue
      case .program:          program = property.value.trimmingCharacters(in: .whitespaces)
      case .station:          station = property.value.replacingOccurrences(of: "\u{007f}", with: "").trimmingCharacters(in: .whitespaces)
      }
    }
    
    for radio in radios where radio.id == activeSelection!.radio.id {
      
      if let index = radio.guiClients.firstIndex(where: {handle.hex == $0.handle} ) {
        
        var newGuiClient = radio.guiClients[index]
        newGuiClient.clientId = UUID(uuidString: clientId)!
        newGuiClient.program = program
        newGuiClient.station = station

//        radio.guiClients[index].clientId = UUID(uuidString: clientId)
//        radio.guiClients[index].isLocalPtt = isLocalPtt
//        radio.guiClients[index].program = program
//        radio.guiClients[index].station = station
        radio.guiClients[index] = newGuiClient
        log.info("ApiModel: Handle <\(handle.hex)>, Station <\(station)>, Program <\(program)>, Ip <\(newGuiClient.ip)>, Host <\(newGuiClient.ip)>, Client Id <\(clientId)> - UPDATED in ApiModel")
        // if needed, bind to the Station
        //        bind(radio!.isGui, activeSelection?.station, station, clientId)
        return
        
      } else {
        radio.guiClients.append(GuiClient(handle: handle.hex, station: station, program: program, clientId: UUID(uuidString: clientId)))
        log.info("ApiModel: Handle <\(handle.hex)>, Station <\(station)>, Program <\(program)>, Client Id <\(clientId)> - ADDED in ApiModel")
        // if needed, bind to the Station
        //        bind(radio!.isGui, activeSelection?.station, station, clientId)
      }
    }
  }
  
  private func bind(_ isGui: Bool, _ activeStation: String?, _ station: String, _ clientId: String) {
    if isGui == false && station == activeStation {
      boundClientId = clientId
      sendTcp("client bind client_id=\(clientId)")
      log.info("Listener: NonGui bound to <\(station)>, Client ID <\(clientId)>")
    }
  }
  
  /// Parse a client disconnect status message
  /// - Parameters:
  ///   - properties: message properties as a KeyValuesArray
  ///   - handle: the radio's connection handle
  private func parseDisconnection(properties: KeyValuesArray, handle: UInt32, connectionHandle: UInt32?) {
    var reason = ""
    
    enum Property: String {
      case duplicateClientId        = "duplicate_client_id"
      case forced
      case wanValidationFailed      = "wan_validation_failed"
    }
    
    // is it me?
    if handle == connectionHandle {
      // YES, parse remaining properties
      for property in properties.dropFirst(2) {
        // check for unknown property
        guard let token = Property(rawValue: property.key) else {
          // log it and ignore this Key
          log.warning("ObjectModel: unknown client disconnection property, \(property.key)=\(property.value)")
          continue
        }
        // Known properties, in alphabetical order
        switch token {
          
        case .duplicateClientId:    if property.value.bValue { reason = "Duplicate ClientId" }
        case .forced:               if property.value.bValue { reason = "Forced" }
        case .wanValidationFailed:  if property.value.bValue { reason = "Wan validation failed" }
        }
      }
      log.warning("ObjectModel: client disconnection, reason = \(reason)")
      
      clientInitialized = false
      
    } else {
      // NO, not me
      //      activeSelection?.packet.guiClients[handle] = nil
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private continuation methods
  
  private func awaitFirstStatusMessage() async {
    return await withCheckedContinuation{ continuation in
      _awaitFirstStatusMessage = continuation
      log.debug("ApiModel: waiting for first status message")
    }
  }
  
  private func clientIpValidation() async -> (String) {
    return await withCheckedContinuation{ continuation in
      _awaitClientIpValidation = continuation
      log.debug("Api: Client ip request sent")
    }
  }
  
  private func wanValidation() async -> (String) {
    return await withCheckedContinuation{ continuation in
      _awaitWanValidation = continuation
      log.debug("Api: Wan validate sent for handle=\(self._wanHandle!)")
    }
  }
  
  private func tcpReply() async -> (Int, String, String) {
    return await withCheckedContinuation{ continuation in
      _tcpReply = continuation
      log.debug("Api: awaiting a TCP reply")
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private Reply methods
  
  /// Parse Replies
  /// - Parameters:
  ///   - commandSuffix:      a Reply Suffix
  private func replyProcessor(_ replyMessage: String) {
    
    // separate it into its components
    if let components = replyParser(replyMessage) {
      // are we waiting for this reply?
      if _tcpReply != nil {
        // YES, resume
        log.debug( "ApiModel: resuming tcpReply" )
        _tcpReply!.resume(returning: components)
        
      } else {
        
        Task {
          var keyValues: KeyValuesArray
          
          let sequenceNumber = components.0
          let replyValue = components.1
          let suffix = components.2
          
          // is there a ReplyEntry for the sequence number (in the ReplyDictionary)?
          if let replyEntry = await _replyDictionary[ sequenceNumber ] {
            
            // YES, remove that entry in the ReplyDictionary
            await _replyDictionary.remove(sequenceNumber)
            
            // Anything other than kNoError is an error, log it
            // ignore non-zero reply from "client program" command
            if replyValue != kNoError && !replyEntry.command.hasPrefix("client program ") {
              log.error("ApiModel: replyValue >\(replyValue)<, to c\(sequenceNumber), \(replyEntry.command), \(flexErrorString(errorCode: replyValue)), \(suffix)")
            }
            
            if replyEntry.replyHandler == nil {
              
              // process replies to the internal "sendCommands"?
              switch replyEntry.command {
              case "radio uptime":  keyValues = "uptime=\(suffix)".keyValuesArray()
              case "version":       keyValues = suffix.keyValuesArray(delimiter: "#")
              case "ant list":      keyValues = "ant_list=\(suffix)".keyValuesArray()
              case "mic list":      keyValues = "mic_list=\(suffix)".keyValuesArray()
              case "info":          keyValues = suffix.keyValuesArray(delimiter: ",")
              default: return
              }
              activeSelection?.radio.parse(keyValues)
              
            } else {
              // call the sender's Handler
              replyEntry.replyHandler?(replyEntry.command, replyMessage)
            }
          } else {
            // no reply entry for this sequence number
            log.error("ApiModel: sequenceNumber \(sequenceNumber) not found in the ReplyDictionary")
          }
        }
      }
    }
  }

  
  
  
  
  
  private func replyParser(_ replyMessage: String) -> (Int, String, String)? {
    // separate it into its components
    let components = replyMessage.dropFirst().components(separatedBy: "|")
    // ignore incorrectly formatted replies
    if components.count < 2 {
      log.warning("ApiModel: incomplete reply, R\(replyMessage)")
      return nil
    }
    // get the sequence number, reply and any additional data
    let sequenceNumber = components[0].sequenceNumber
    let replyValue = components[1]
    let suffix = components.count < 3 ? "" : components[2]
    return (sequenceNumber, replyValue, suffix)
  }
  
  
  private func replyInfo(_ replyMessage: String) -> String? {
    if let components = replyParser(replyMessage) {
      return components.2
    } else {
      return nil
    }
  }
  
  
  
  
  
  
  
  public func commandsReplyHandler(_ command: String, _ reply: String) {
    var keyValues: KeyValuesArray
    
    // separate it into its components
    let components = reply.components(separatedBy: "|")
    // ignore incorrectly formatted replies
    if components.count < 2 {
      log.warning("ApiModel: incomplete reply, r\(reply)")
      return
    }
    if components[1] != kNoError {
      log.warning("ApiModel: non-zero reply for command \(command), \(reply)")
      return
    }
    
    // get any additional data
    if components.count > 2 {
      let additionalData = components[2]
      
      // process replies to the internal "sendCommands"?
      switch command {
      case "radio uptime":  keyValues = "uptime=\(additionalData)".keyValuesArray()
      case "version":       keyValues = additionalData.keyValuesArray(delimiter: "#")
      case "ant list":      keyValues = "ant_list=\(additionalData)".keyValuesArray()
      case "mic list":      keyValues = "mic_list=\(additionalData)".keyValuesArray()
      case "info":          keyValues = additionalData.keyValuesArray(delimiter: ",")
      default: return
      }
      activeSelection?.radio.parse(keyValues)
    }
  }

  
  
  
  
 private func ipReplyHandler(_ command: String, _ reply: String) {
    // YES, resume it
    _awaitClientIpValidation?.resume(returning: reply)
  }
  
  private func wanValidationReplyHandler(_ command: String, _ reply: String) {
    // YES, resume it
    _awaitWanValidation?.resume(returning: reply)
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Tcp parse methods
  
  /// Parse a Message.
  /// - Parameters:
  ///   - commandSuffix:      a Command Suffix
  private func parseMessage(_ msg: String) {
    // separate it into its components
    let components = msg.dropFirst().components(separatedBy: "|")
    
    // ignore incorrectly formatted messages
    if components.count < 2 {
      log.warning("ApiModel: incomplete message = c\(msg)")
      return
    }
    
    // log it
    logFlexError(errorCode: components[0], msgText:  components[1])
    
    // FIXME: Take action on some/all errors?
  }
  
  /// Parse a Status
  /// - Parameters:
  ///   - commandSuffix:      a Command Suffix
  private func parseStatus(_ commandSuffix: String) {
    
    // separate it into its components ( [0] = <apiHandle>, [1] = <remainder> )
    let components = commandSuffix.dropFirst().components(separatedBy: "|")
    
    // ignore incorrectly formatted status
    guard components.count > 1 else {
      log.warning("ApiModel: incomplete status = c\(commandSuffix)")
      return
    }
    
    // find the space & get the msgType
    let spaceIndex = components[1].firstIndex(of: " ")!
    let statusType = String(components[1][..<spaceIndex])
    
    // everything past the msgType is in the remainder
    let messageIndex = components[1].index(after: spaceIndex)
    let statusMessage = String(components[1][messageIndex...])
    
    // is this status message the first for our handle?
    if _firstStatusMessageReceived == false && components[0].handle == connectionHandle {
      // YES, set the API state to finish the UDP initialization
      _firstStatusMessageReceived = true
      _awaitFirstStatusMessage!.resume()
    }
    
    parse(statusType, statusMessage, self.connectionHandle)
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private Stream methods
  
  private func removeStream(having id: UInt32) {
    if daxIqs[id] != nil {
      daxIqs[id] = nil
      log.debug("ObjectModel: DaxIq \(id.hex): REMOVED")
    }
    else if daxMicAudio?.id == id {
      daxMicAudio = nil
      log.debug("ObjectModel: DaxMicAudio \(id.hex): REMOVED")
    }
    else if daxRxAudios[id] != nil {
      daxRxAudios[id] = nil
      log.debug("ObjectModel: DaxRxAudio \(id.hex): REMOVED")
      
    } else if daxTxAudio?.id == id {
      daxTxAudio = nil
      log.debug("ObjectModel: DaxTxAudio \(id.hex): REMOVED")
    }
    else if remoteRxAudio?.id == id {
      remoteRxAudio = nil
      log.debug("ObjectModel: RemoteRxAudio \(id.hex): REMOVED")
    }
    else if remoteTxAudio?.id == id {
      remoteTxAudio = nil
      log.debug("ObjectModel: RemoteTxAudio \(id.hex): REMOVED")
    }
  }
  
  /// Determine if status is for this client
  /// - Parameters:
  ///   - properties:     a KeyValuesArray
  ///   - clientHandle:   the handle of ???
  /// - Returns:          true if a mtch
  private func isForThisClient(_ properties: KeyValuesArray, _ connectionHandle: UInt32?) -> Bool {
    var clientHandle : UInt32 = 0
    
    guard testDelegate != nil else { return true }
    
    if let connectionHandle {
      // find the handle property
      for property in properties.dropFirst(2) where property.key == "client_handle" {
        clientHandle = property.value.handle ?? 0
      }
      return clientHandle == connectionHandle
    }
    return false
  }
}

//  public func altAntennaName(for stdName: String) -> String {
//    // return alternate name (if any)
//    for antenna in settingModel.altAntennaNames where antenna.stdName == stdName {
//      return antenna.customName
//    }
//    return stdName
//  }
//
//  public func altAntennaName(for stdName: String, _ customName: String) {
//    for (i, antenna) in settingModel.altAntennaNames.enumerated() where antenna.stdName == stdName {
//      settingModel.altAntennaNames[i].customName = customName
//      let oldAntList = antList
//      antList = oldAntList
//      return
//    }
//    settingModel.altAntennaNames.append(Settings.AntennaName(stdName: stdName, customName: customName))
//    let oldAntList = antList
//    antList = oldAntList
//  }

//  public func altAntennaNameRemove(for stdName: String) {
//    for (i, antenna) in altAntennaList.enumerated() where antenna.stdName == stdName {
//      altAntennaList.remove(at: i)
//    }
//  }
