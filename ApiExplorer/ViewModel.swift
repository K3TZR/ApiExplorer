//
//  ViewModel.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 10/6/24.
//

import Foundation
import SwiftUI

import ApiPackage

@MainActor
@Observable
public class ViewModel {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init() {
    messages = MessagesModel()
    api = ApiModel()
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  // models
  public let messages: MessagesModel
  public let api: ApiModel
  
  // transient properties
  public var activeSheet: ActiveSheet?
  public var alertInfo: AlertInfo?
  public var initialized: Bool = false
  public var isConnected: Bool = false
  public var selection: String?
  public var showAlert: Bool = false
  #if os(iOS)
  public var showSettings: Bool = false
  #endif

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _settings = SettingsModel()
  private var _smartlinkIdToken: String?
  
  private let kDomain             = "https://frtest.auth0.com/"
  private let kClientId           = "4Y9fEIIsVYyQo5u6jr7yBWc4lV5ugC2m"

  // ----------------------------------------------------------------------------
  // MARK: - Public action methods
  
  public func clearTextButtonTapped() {
    _settings.commandToSend = ""
  }
  
  public func daxSelectionChanged(_ old: DaxChoice, _ new: DaxChoice) {
    alertInfo = AlertInfo("Dax Selection", "Not Implemented (yet)")
    _settings.daxSelection = .none
    showAlert = true
  }
  
  public func directButtonChanged(_ enabled: Bool) {
    alertInfo = AlertInfo("Direct Connect", "Not Implemented (yet)")
    showAlert = true
    _settings.directEnabled = false
//    if enabled {
//      _settings.localDisabled = true
//      _settings.smartlinkEnabled = false
//    }
  }
  
//  public func fontFieldTapped() {
//    var currentSize = _settings.fontSize
//    currentSize += 1
//    _settings.fontSize = currentSize.bracket(8, 14)
//  }
  
  public func guiButtonTapped() {
    _settings.isNonGui.toggle()
  }
  
  public func localButtonChanged(_ enabled: Bool) {
    if enabled {
      api.listenerLocal?.stop()
      api.listenerLocal = nil
      api.removeRadios(.local)
    } else {
      _settings.directEnabled = false
      api.listenerLocal = ListenerLocal(api)
      Task { await api.listenerLocal!.start() }
    }
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
      
      // start Local if enabled
      if !_settings.localDisabled {
        localButtonChanged(false)
      }
      
     // start Smartlink if enabled
      if _settings.smartlinkEnabled {
        smartlinkButtonChanged(true)
      }
      
      // make sure we have a Client Id
      if _settings.guiClientId.isEmpty {
        _settings.guiClientId = UUID().uuidString
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
    if _settings.isNonGui {
      if _settings.defaultNonGui == selection {
        _settings.defaultNonGui = nil
      } else {
        _settings.defaultNonGui = selection
      }
    } else {
      if _settings.defaultGui == selection {
        _settings.defaultGui = nil
      } else {
        _settings.defaultGui = selection
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

  public func remoteRxAudioCompressedButtonChanged() {
    alertInfo = AlertInfo("Remote Rx Audio Compressed", "Not Implemented (yet)")
    showAlert = true
  }
  
  public func remoteRxAudioEnabledButtonChanged() {
    alertInfo = AlertInfo("Remote Rx Audio Enabled", "Not Implemented (yet)")
    showAlert = true
  }
  
  public func remoteTxAudioEnabledButtonChanged() {
    alertInfo = AlertInfo("Remote Tx Audio Enabled", "Not Implemented (yet)")
    showAlert = true
  }
  
  public func remoteTxAudioCompressedButtonChanged() {
    alertInfo = AlertInfo("Remote Tx Audio Compressed", "Not Implemented (yet)")
    showAlert = true
  }
  
  public func sendButtonTapped() {
    _settings.commandsArray.append(_settings.commandToSend.lowercased())
    // send command to the radio
    api.sendTcp(_settings.commandToSend.lowercased())
    if _settings.clearOnSend { clearTextButtonTapped() }
  }
  
  public func settingsDidDismiss() {
    // no action required
  }
  
  public func smartlinkButtonChanged(_ enabled: Bool)  {
    if enabled {
      // disable direct, it is incompatable with other connection types
      _settings.directEnabled = false

      guard _settings.smartlinkLoginRequired  == false else {
        activeSheet = .smartlinkLogin
        return
      }
      
      // start the listener
      api.listenerSmartlink = ListenerSmartlink(api)
      // is the previous IdToken still valid?
      if api.listenerSmartlink!.isValid(_smartlinkIdToken) {
        // YES, connect using the IdToken
        if !api.listenerSmartlink!.connect(Tokens(_smartlinkIdToken!, _settings.smartlinkRefreshToken)) {
          // did not connect, force a Login
          activeSheet = .smartlinkLogin
        }
        
      // NO, try using the RefreshToken
      } else if _settings.smartlinkRefreshToken != nil {
        Task {
          // Can we get an IdToken using the RefreshToken?
          if let _smartlinkIdToken = await api.listenerSmartlink!.requestIdToken(refreshToken: _settings.smartlinkRefreshToken!) {
            // YES, connect using the IdToken
            if !api.listenerSmartlink!.connect(Tokens(_smartlinkIdToken, _settings.smartlinkRefreshToken)) {
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
  
  public func smartlinkCancelButtonTapped() {
    activeSheet = nil
    _settings.smartlinkEnabled = false
  }
  
  public func smartlinkLoginButtonTapped(_ user: String, _ password: String) {
    activeSheet = nil
    Task {
      var tokens: Tokens?
      
//      tokens = await api.listenerSmartlink?.requestTokens(user, password)
//      if api.listenerSmartlink!.connect(tokens!) {
//        _settings.smartlinkRefreshToken = tokens!.refreshToken
//        _smartlinkIdToken = tokens!.idToken
//      } else {
        alertInfo = AlertInfo("Smartlink tokens", "FAILED for user: \(user)")
        _settings.smartlinkEnabled = false
        showAlert = true
//      }
    }
  }
  
  public func smartlinkLoginDidDismiss() {
    // no action required
  }
  
  public func startButtonTapped() {
    if isConnected {
      Task { await connectionStop() }
      
    } else if _settings.useDefaultEnabled {
      if let selection = _settings.isNonGui ? _settings.defaultNonGui : _settings.defaultGui {
        connectionStart(selection)
      } else {
        activeSheet = .picker
      }
      
    } else {
      activeSheet = .picker
    }
  }
    
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

  
//  public func hexDump(_ data: Data) -> String {
//    let len = data.count
//    var bytes = [UInt8](repeating: 0x00, count: len)
//
//    (data as NSData).getBytes(&bytes, range: NSMakeRange(0, len - 1))
//    
//    var string = "  \(String(format: "%4d", len ))  00 01 02 03 04 05 06 07   08 09 0A 0B 0C 0D 0E 0F\n"
//    string += " bytes    -------------------------------------------------\n\n"
//    
//    string += "----- HEADER (Hex) -----\n"
//    
//    var address = 0
//    string += address.toHex() + "   "
//    for i in 1...28 {
//      string += String(format: "%02X", bytes[i-1]) + " "
//      if (i % 8) == 0 { string += "  " }
//      if (i % 16) == 0 {
//        string += "\n"
//        address += 16
//        string += address.toHex() + "   "
//      }
//    }
//
//    string += "\n\n----- PAYLOAD (Hex) -----\n"
//      
//    
//    string += address.toHex() + "                                         "
//    for i in 29...len {
//      string += String(format: "%02X", bytes[i-1]) + " "
//      if (i % 8) == 0 { string += "  " }
//      if (i % 16) == 0 {
//        string += "\n"
//        address += 16
//        string += address.toHex() + "   "
//      }
//    }
//
//    string += "\n\n----- PAYLOAD (UTF8) -----\n"
//      
//    address = 16
//    string += address.toHex() + "                                         "
//    for i in 29...len {
//      string += String(decoding: bytes[i-1...i-1], as: UTF8.self) + "  "
//      if (i % 8) == 0 { string += "  " }
//      if (i % 16) == 0 {
//        string += "\n"
//        address += 16
//        string += address.toHex() + "   "
//      }
//    }
//    return string
//  }
  
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
    messages.start(_settings.clearOnStart)
    
    // attempt to connect to the selected Radio / Station
    // try to connect
    let connectTask = Task {
      do {
        try await api.connect(selection: selection,
                              isGui: !_settings.isNonGui,
                              programName: "ApiExplorer",
                              mtuValue: _settings.mtuValue,
                              guiClientId: UUID(uuidString: _settings.guiClientId)!,
                              lowBandwidthDax: _settings.lowBandwidthDax,
                              lowBandwidthConnect: _settings.lowBandwidthConnect,
                              testDelegate: messages)
        // connection succesful
        return true
        
      } catch {
        // connection attempt failed
        await api.disconnect()
        Task { await AppLog.error("\(error.localizedDescription)") }
        return false
      }
    }
    isConnected = await connectTask.result.get()
    if isConnected {
      Task { await AppLog.info("ApiExplorer: connection SUCCEEDED, ID <\(selection.radioId)>") }
    } else {
      Task { await AppLog.error("ApiExplorer: connection FAILED, ID <\(selection.radioId)>") }
    }
  }
  
  private func connectionStart(_ selection: PickerSelection)  {
    // validate the radio id
    if let radio = api.radios.first(where: {$0.id == selection.radioId}) {
      api.activeSelection = selection
      
      // handle Multiflex
      if !_settings.isNonGui && radio.guiClients.count > 0 {
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
    messages.stop(_settings.clearOnStop)
    await api.disconnect()
    isConnected = false
  }
  
  //  private func findRadio(radioId id: String) -> Radio? {
  //    return objects.radios.first(where: {$0.id == id})
  //  }
  
  //  private func findRadio(stationId id: String) -> (Radio, String)? {
  //    // find the packet containing the Station
  //    for radio in objects.radios {
  //      for guiClient in radio.packet.guiClients where guiClient.id == id {
  //        return (radio, guiClient.station)
  //      }
  //    }
  //    return nil
  //  }
  
  //  private func getDefault(_ isGui: Bool) -> String? {
  //
  //    guard settings.useDefaultEnabled else { return nil }
  //    if isGui {
  //      return settings.defaultGui
  //
  //    } else {
  //      return settings.defaultNonGui
  //    }
  //  }
  //  private func connectionStart(_ state: State)  -> Effect<SDRApi.Action> {
  //    if state.appSettings.clearOnStart { MessagesModel.shared.clear(state.appSettings.messageFilter, state.appSettings.messageFilterText)}
  //    if state.appSettings.directEnabled {
  //      return .run { [state] in
  //        // DIRECT Mode
  //        if state.appSettings.isGui && !state.appSettings.directGuiIp.isEmpty {
  //          let selection = "9999-9999-9999-9999" + state.appSettings.directGuiIp
  //          await $0(.connect(selection, nil))
  //
  //        } else if !state.appSettings.directNonGuiIp.isEmpty {
  //          let selection = "9999-9999-9999-9999" + state.appSettings.directNonGuiIp
  //          await $0(.connect(selection, nil))
  //
  //        } else {
  //          // no Ip Address for the current connection type
  //          await $0(.showDirectSheet)
  //        }
  //      }
  //
  //    } else {
  //      return .run { [state] in
  //        if state.appSettings.useDefaultEnabled {
  //          // LOCAL/SMARTLINK mode connection using the Default, is there a valid? Default
  //          if await ListenerModel.shared.isValidDefault(for: state.appSettings.guiDefault, state.appSettings.nonGuiDefault, state.appSettings.isGui) {
  //            // YES, valid default
  //            if state.appSettings.isGui {
  //              await $0(.multiflexStatus(state.appSettings.guiDefault))
  //            } else {
  //              await $0(.multiflexStatus(state.appSettings.nonGuiDefault))
  //            }
  //          } else {
  //            // invalid default, open the Picker
  //            await $0(.showPickerSheet)
  //          }
  //        }
  //        else {
  //          // default not in use, open the Picker
  //          await $0(.showPickerSheet)
  //        }
  //      }
  //    }
  //  }
  //
  //  private func disconnect(_ state: State)  -> Effect<SDRApi.Action> {
  //    if settings.clearOnStop { MessagesModel.shared.clear(state.appSettings.messageFilter, state.appSettings.messageFilterText) }
  //    return .run {
  //      await ObjectModel.shared.clientInitialized(false)
  //      await ObjectModel.shared.disconnect()
  //      await $0(.connectionStatus(.disconnected))
  //    }
  //  }

  /// Validate an Id Token
  /// - Parameter idToken:        the Id Token
  /// - Returns:                  true / false
//  private func isValid(_ idToken: IdToken?) -> Bool {
//    if let token = idToken {
//      if let jwt = try? decode(jwt: token) {
//        let result = IDTokenValidation(issuer: kDomain, audience: kClientId).validate(jwt)
//        if result == nil { return true }
//      }
//    }
//    return false
//  }

//  private func smartlinkLoginOptions() {
//    // start smartlink listener
//    if _settings.smartlinkLoginRequired {
//      // LOGIN required
//      activeSheet = .smartlinkLogin
//      
//    } else if isValid(_smartlinkIdToken) && _settings.smartlinkRefreshToken.isEmpty == false {
//      // use ID Token
//      Task {
//        if let tokens = await api.smartlinkListenerStart(idToken: _smartlinkIdToken!, refreshToken: _settings.smartlinkRefreshToken) {
//          _settings.smartlinkRefreshToken = tokens.refreshToken
//          _smartlinkIdToken = tokens.idToken
//        } else {
//          // show LOGIN sheet
//          activeSheet = .smartlinkLogin
//        }
//      }
//      
//    } else if _settings.smartlinkRefreshToken.isEmpty == false {
//      // use Refresh Token
//      Task {
//        if let tokens = await api.smartlinkListenerStart(refreshToken: _settings.smartlinkRefreshToken) {
//          _settings.smartlinkRefreshToken = tokens.refreshToken
//          _smartlinkIdToken = tokens.idToken
//        } else {
//          // show LOGIN sheet
//          activeSheet = .smartlinkLogin
//        }
//      }
//      
//    } else {
//      // IdToken and/or refreshToken failure
//      // show LOGIN sheet
//      activeSheet = .smartlinkLogin
//    }
//  }
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
