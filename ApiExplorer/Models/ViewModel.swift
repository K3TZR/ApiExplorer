//
//  ViewModel.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 10/6/24.
//

import Foundation
import SwiftUI

import ApiPackage
import SwiftyPing

@MainActor
@Observable
public class ViewModel {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ settings: SettingsModel) {
    messages = MessagesModel(settings)
    api = ApiModel()
    self.settings = settings
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  // models
  public let messages: MessagesModel
  public let api: ApiModel
  public let settings: SettingsModel
  
  // transient properties
  public var activeSheet: ActiveSheet?
  public var alertInfo: AlertInfo?
  public var initialized: Bool = false
  public var isConnected: Bool = false
  public var pingResult: String = ""
  public var selection: String?
  #if os(iOS)
  public var showSettings: Bool = false
  #endif

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _smartlinkIdToken: String?
  
  private let kDomain             = "https://frtest.auth0.com/"
  private let kClientId           = "4Y9fEIIsVYyQo5u6jr7yBWc4lV5ugC2m"

  // ----------------------------------------------------------------------------
  // MARK: - Public action methods
  
  public func clearTextButtonTapped() {
    settings.commandToSend = ""
  }
  
  public func daxSelectionChanged(_ old: DaxChoice, _ new: DaxChoice) {
    alertInfo = AlertInfo("Dax Selection", "Not Implemented (yet)")
    activeSheet = .simpleAlert
    settings.daxSelection = .none
  }
  
  public func directButtonChanged(_ enabled: Bool) {
    alertInfo = AlertInfo("Direct Connect", "Not Implemented (yet)")
    activeSheet = .simpleAlert
    settings.directEnabled = false
//    if enabled {
//      settings.localEnabled = true
//      settings.smartlinkEnabled = false
//    }
  }
  
  public func guiButtonTapped() {
    settings.isGui.toggle()
  }
  
  public func localButtonChanged(_ enabled: Bool) {
    startStoplocalListener(enabled)
  }
  
  public func multiflexCancelButtonTapped() {
    activeSheet = nil
  }

  public func multiflexConnectButtonTapped(_ disconnectHandle: String?) {
    activeSheet = nil
    if let disconnectHandle {
      api.activeSelection!.disconnectHandle = disconnectHandle
    }
    Task { await connect(api.activeSelection!) }
  }
  
  public func onAppear() {
    if initialized == false {
      Task { await AppLog.debug("ApiExplorer: application started")}
            
      // initialize the Messages model
      messages.reFilter()
      
      // start Local and/or Smartlink if enabled
      if settings.localEnabled || settings.smartlinkEnabled {
        Task {
          sleep(2)
          if settings.localEnabled { startStoplocalListener(true) }
          if settings.smartlinkEnabled { startStopSmartlinkListener(true) }
        }
      }
      
      // make sure we have a Client Id
      if settings.guiClientId.isEmpty {
        settings.guiClientId = UUID().uuidString
      }

      // mark as initialized
      initialized = true
    }
  }
    
  public func pickerConnectButtonTapped(_ selection: PickerSelection) {
    activeSheet = nil
    // try to connect to the selected radio / station
    connectionStart(selection)
  }
  
  public func pickerDefaultButtonTapped(_ selection: PickerSelection) {
    // set / reset the default
    if settings.isGui {
      if settings.defaultGui == selection {
        settings.defaultGui = nil
      } else {
        settings.defaultGui = selection
      }
    } else {
      if settings.defaultNonGui == selection {
        settings.defaultNonGui = nil
      } else {
        settings.defaultNonGui = selection
      }
    }
  }
  
  public func pickerTestButtonTapped(_ selection: String) {
    let parts = selection.split(separator: "|")
    
    // reset the result
    api.smartlinkTestResult = SmartlinkTestResult()
    // perform a connection test on the smartlink radio
    api.sendSmartlinkTest(String(parts[0]))
  }
  
  public func ping(_ ipAddress: String) {
    let simplePingQ = DispatchQueue(label: "simplePingQ")
//    var results: [String] = []
//    print("Pinging", ipAddress )

    // Ping indefinitely
    let pinger = try? SwiftyPing(host: ipAddress, configuration: PingConfiguration(interval: 0.5, with: 5), queue: simplePingQ)
//    pinger?.observer = { (response) in
//      print("time = " + String(format: "%.3f ms", response.duration * 1000))
//      results.append("time = " + String(format: "%.3f ms", response.duration * 1000))
//    }
    pinger?.targetCount = 5
    pinger?.finished = { result in
//      print(results.joined(separator: "\n"))
      let min =  String(format: "%.3f", (result.roundtrip?.minimum ?? 0) * 1_000)
      let max =  String(format: "%.3f", (result.roundtrip?.maximum ?? 0) * 1_000)
      let avg =  String(format: "%.3f", (result.roundtrip?.average ?? 0) * 1_000)

      self.pingResult = "Ping \(ipAddress):  Min = \(min), Max = \(max), Avg = \(avg) (ms)"
//      self.alertInfo = AlertInfo.init("Ping Results", "Min = \(min)\nMax = \(max)\nAvg = \(avg)")
//      self.showAlert = true
    }
    try? pinger?.startPinging()
  }

  public func remoteRxAudioCompressedButtonChanged() {
    alertInfo = AlertInfo("Remote Rx Audio Compressed", "Not Implemented (yet)")
    activeSheet = .simpleAlert
    settings.remoteRxAudioCompressed = false
  }
  
  public func remoteRxAudioEnabledButtonChanged() {
    alertInfo = AlertInfo("Remote Rx Audio Enabled", "Not Implemented (yet)")
    activeSheet = .simpleAlert
    settings.remoteRxAudioEnabled = false
  }
  
  public func remoteTxAudioEnabledButtonChanged() {
    alertInfo = AlertInfo("Remote Tx Audio Enabled", "Not Implemented (yet)")
    activeSheet = .simpleAlert
    settings.remoteTxAudioEnabled = false
  }
  
  public func remoteTxAudioCompressedButtonChanged() {
    alertInfo = AlertInfo("Remote Tx Audio Compressed", "Not Implemented (yet)")
    activeSheet = .simpleAlert
    settings.remoteTxAudioCompressed = false
  }
  
  public func sendButtonTapped() {
    settings.commandsArray.append(settings.commandToSend.lowercased())
    // send command to the radio
    api.sendTcp(settings.commandToSend.lowercased())
    if settings.clearOnSend { clearTextButtonTapped() }
  }
  
  public func settingsDidDismiss() {
    // no action required
  }
  
  public func smartlinkButtonChanged(_ enabled: Bool)  {
    startStopSmartlinkListener(enabled)
  }
  
  public func smartlinkCancelButtonTapped() {
    activeSheet = nil
    settings.smartlinkEnabled = false
  }
  
  public func smartlinkLoginButtonTapped(_ user: String, _ password: String) {
    activeSheet = nil
    Task {
      var tokens: Tokens?
      
      tokens = await api.listenerSmartlink?.requestTokens(user, password)
      if api.listenerSmartlink!.connect(tokens!) {
        settings.smartlinkRefreshToken = tokens!.refreshToken
        _smartlinkIdToken = tokens!.idToken
      } else {
        alertInfo = AlertInfo("Smartlink tokens", "FAILED for user: \(user)")
        settings.smartlinkEnabled = false
        activeSheet = .alert
      }
    }
  }
  
  public func smartlinkLoginDidDismiss() {
    // no action required
  }
  
  public func startButtonTapped() {
    if isConnected {
      Task { await connectionStop() }
      
    } else if settings.useDefaultEnabled {
      if let selection = settings.isGui ? settings.defaultGui : settings.defaultNonGui {
        connectionStart(selection)
      } else {
        activeSheet = .picker
      }
      
    } else {
      activeSheet = .picker
    }
  }

  private func startStoplocalListener(_ enabled: Bool) {
    if enabled {
      settings.directEnabled = false
      api.listenerLocal = ListenerLocal(api)
      let port = UInt16(settings.discoveryPort)
      Task { await api.listenerLocal!.start(port: port) }
    } else {
      api.listenerLocal?.stop()
      api.listenerLocal = nil
      api.removeRadios(.local)
    }
  }

  public func startStopSmartlinkListener(_ enabled: Bool)  {
    if enabled {
      // disable direct, it is incompatable with other connection types
      settings.directEnabled = false

      guard settings.smartlinkLoginRequired  == false else {
        activeSheet = .smartlinkLogin
        return
      }
      
      // start the listener
      api.listenerSmartlink = ListenerSmartlink(api)
      // is the previous IdToken still valid?
      if api.listenerSmartlink!.isValid(_smartlinkIdToken) {
        // YES, connect using the IdToken
        if !api.listenerSmartlink!.connect(Tokens(_smartlinkIdToken!, settings.smartlinkRefreshToken)) {
          // did not connect, force a Login
          activeSheet = .smartlinkLogin
        }
        
      // NO, try using the RefreshToken
      } else if settings.smartlinkRefreshToken != nil {
        Task {
          // Can we get an IdToken using the RefreshToken?
          if let _smartlinkIdToken = await api.listenerSmartlink!.requestIdToken(refreshToken: settings.smartlinkRefreshToken!) {
            // YES, connect using the IdToken
            if !api.listenerSmartlink!.connect(Tokens(_smartlinkIdToken, settings.smartlinkRefreshToken)) {
              // did not connect, force a Login
              activeSheet = .smartlinkLogin
            }
          } else {
            // did not connect, force a Login
            activeSheet = .smartlinkLogin
          }
        }
      } else {
        // did not connect, force a Login
        activeSheet = .smartlinkLogin
      }
      
    } else {
      // stop smartlink listener
      api.listenerSmartlink?.stop()
      api.listenerSmartlink = nil
      api.removeRadios(.smartlink)
    }
  }
  public func toggleDiscoveryPort() {
    if settings.discoveryPort == 4992 {
      settings.discoveryPort = 14992
    } else {
      settings.discoveryPort = 4992
    }
  }
  
  public func toggleViewMode() {
    switch settings.viewMode {
    case .messages:
      settings.viewMode = .all
    case .objects:
      settings.viewMode = .messages
    case .all:
      settings.viewMode = .objects
    }  }
  

  // ----------------------------------------------------------------------------
  // MARK: - Public supporting methods
  
  public func vitaHeader(_ data: Data) -> [String ]{
    var stringArray: [String] = []
    let byteStrings = data.map { String(format: "%02X", $0) }
    for i in stride(from: 0, to: 28, by: 16) {
      let row = byteStrings[i..<min(i+16, 28)].joined(separator: " ")
      stringArray.append(row)
    }
    return stringArray
  }

  /// Converts Data to an array of formatted hex string lines (16 bytes per row).
 public func vitaPayload(_ data: Data, _ utf8: Bool) -> [String] {
    var stringArray: [String] = []
    
    if utf8 {
      if data.count > 28 { // Ensure data has at least 28 bytes to avoid errors
        let trimmedData = data.dropFirst(28) // Skip first 28 bytes
        
        if let string = String(data: trimmedData, encoding: .utf8) {
          for i in stride(from: 0, to: 4, by: 16) {
            let startIndex = string.index(string.startIndex, offsetBy: i)
            let endIndex = string.index(startIndex, offsetBy: 4, limitedBy: string.endIndex) ?? string.endIndex
            let row = String(string[startIndex..<endIndex])
            stringArray.append(row)
          }
          for i in stride(from: 4, to: string.count, by: 16) {
            let startIndex = string.index(string.startIndex, offsetBy: i)
            let endIndex = string.index(startIndex, offsetBy: 16, limitedBy: string.endIndex) ?? string.endIndex
            let row = String(string[startIndex..<endIndex])
            stringArray.append(row)
          }
        }
      }
      
    } else {
      let byteStrings = data.map { String(format: "%02X", $0) }
      for i in stride(from: 16, to: byteStrings.count, by: 16) {
        if i == 16 {
          stringArray.append( String(repeating: " ", count: 36) + byteStrings[28...31].joined(separator: " ") )
        } else {
          let row = byteStrings[i..<min(i+16, byteStrings.count)].joined(separator: " ")
          stringArray.append(row)
        }
      }
    }
    return stringArray
  }
  
  public func vitaString(_ data: Data, _ utf8: Bool) -> String {
    var string = "--- Header ---\n"
    string += vitaHeader(data).joined(separator: "\n")
    string += "\n\n --- Payload ---\n"
    return string + vitaPayload(data, utf8).joined(separator: "\n")
  }
  
  public func payloadProperties(_ data: Data) -> KeyValuesArrayIndexed {
    //    let len = 552
    let len = data.count
    var bytes = [UInt8](repeating: 0x00, count: len)

    (data as NSData).getBytes(&bytes, range: NSMakeRange(0, len - 1))

    let payloadBytes = bytes[27...len-1]
    let text = String(decoding: payloadBytes, as: UTF8.self)
    return text.keyValuesArrayIndexed()
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private supporting methods
  
  private func connect(_ selection: PickerSelection) async {
    messages.start(settings.clearOnStart)
    
    // attempt to connect to the selected Radio / Station
    // try to connect
    let connectTask = Task {
      do {
        try await api.connect(selection: selection,
                              isGui: settings.isGui,
                              programName: "ApiExplorer",
                              mtuValue: settings.mtuValue,
                              guiClientId: UUID(uuidString: settings.guiClientId)!,
                              lowBandwidthDax: settings.lowBandwidthDax,
                              lowBandwidthConnect: settings.lowBandwidthConnect,
                              testDelegate: messages)
        // connection succesful
        return true
        
      } catch {
        // connection attempt failed
        await api.disconnect()
        await AppLog.error("ApiExplorer/connect: \(error.localizedDescription)")
        return false
      }
    }
    isConnected = await connectTask.result.get()
    if isConnected {
      Task { await AppLog.info("ApiExplorer/connect: SUCCEEDED, ID <\(selection.radioId)>") }
    } else {
      Task { await AppLog.error("ApiExplorer/connect: FAILED, ID <\(selection.radioId)>") }
    }
  }
  
  private func connectionStart(_ selection: PickerSelection)  {
    // validate the radio id
    if let radio = api.radios.first(where: {$0.id == selection.radioId}) {
      api.activeSelection = selection
      
      // handle Multiflex
      if settings.isGui && radio.guiClients.count > 0 {
        activeSheet = .multiflex
        
      } else {
        Task { await connect(selection) }
      }
      
    } else {
      Task { await AppLog.error("ApiExplorer: Radio not found, ID <\(selection.radioId)>") }
    }
  }
  
  private func connectionStop() async {
    api.activeSelection = nil
    messages.stop(settings.clearOnStop)
    await api.disconnect()
    isConnected = false
  }
}

// ----------------------------------------------------------------------------
// MARK: - Save support

import UniformTypeIdentifiers

public struct SaveDocument: FileDocument {
  public static var readableContentTypes: [UTType] { [.plainText] }
  
  var text: String
  
  public init(text: String = "") {
      self.text = text
  }

    // this initializer loads data that has been saved previously
  public init(configuration: ReadConfiguration) throws {
      if let data = configuration.file.regularFileContents,
         let string = String(data: data, encoding: .utf8) {
          text = string
      } else {
          throw CocoaError(.fileReadCorruptFile)
      }
  }
  
  public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
      let data = text.data(using: .utf8) ?? Data()
      return FileWrapper(regularFileWithContents: data)
  }
}
