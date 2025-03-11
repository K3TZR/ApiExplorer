//
//  ViewModel.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 10/6/24.
//

import Foundation
import SwiftUI

import ApiPackage
import JWTDecode

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
  public var alertInfo: AlertInfo?
  public var initialized: Bool = false
  public var isConnected: Bool = false
  public var selection: String?
  public var showAlert: Bool = false
  public var showDiscovery: Bool = false
  public var showGuiClients: Bool = false
  public var showMultiflex: Bool = false
  public var showPicker: Bool = false
  public var showSmartlinkLogin: Bool = false
    
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _settings = SettingsModel.shared
  private var _smartlinkIdToken: String?
  
  private let kDomain             = "https://frtest.auth0.com/"
  private let kClientId           = "4Y9fEIIsVYyQo5u6jr7yBWc4lV5ugC2m"

  // ----------------------------------------------------------------------------
  // MARK: - Public action methods
  
  public func clearTextButtonTapped() {
    _settings.commandToSend = ""
  }
  
  public func daxSelectionChanged(_ old: DaxChoice, _ new: DaxChoice) {
    print("daxSelectionChanged")
    alertInfo = AlertInfo("Dax Selection", "Not Implemented (yet)")
    showAlert = true
  }
  
  public func defaultButtonTapped(_ radioId: String) {
    // set / reset the default
    if _settings.isGui {
      if _settings.defaultGui == radioId {
        _settings.defaultGui = ""
      } else {
        _settings.defaultGui = radioId
      }
    } else {
      if _settings.defaultNonGui == radioId {
        _settings.defaultNonGui = ""
      } else {
        _settings.defaultNonGui = radioId
      }
    }
  }
  
  public func directButtonChanged(_ enabled: Bool) {
    print("directChanged \(enabled)")
    if enabled {
      _settings.localEnabled = false
      _settings.smartlinkEnabled = false
    }
  }
  
  public func guiButtonTapped() {
    _settings.isGui.toggle()
  }
  
  public func localButtonChanged(_ enabled: Bool) {
    if enabled {
      _settings.directEnabled = false
      api.localListenerStart()
    } else {
      api.localListenerStop()
    }
  }
  
  public func multiflexConnectButtonTapped() {
    Task { await connect(api.activeSelection!) }
  }
  
  public func nextStepperTapped() {
    if _settings.commandsIndex == _settings.commandsArray.count - 1 {
      _settings.commandsIndex = 0
    } else {
      _settings.commandsIndex += 1
    }
    _settings.commandToSend = _settings.commandsArray[_settings.commandsIndex]
  }
  
  public func onAppear() {
    if initialized == false {
      log.debug("ApiExplorer: application started")
      
      // initialize the Messages model
      messages.reFilter()
      
      // start Local if enabled
      if _settings.localEnabled {
        api.localListenerStart()
      }
      
     // start Smartlink if enabled
      if _settings.smartlinkEnabled {
        smartlinkLoginOptions()
      }
      
      // make sure we have a Client Id
      if _settings.guiClientId.isEmpty {
        _settings.guiClientId = UUID().uuidString
      }

      // mark as initialized
      initialized = true
    }
  }
  
  public func pickerConnectButtonTapped(_ radioId: String, _ station: String) {
    api.activeStation = station
    // try to connect to the selected radio / station
    connectionStart(radioId)
  }
  
  public func previousStepperTapped() {
    if _settings.commandsIndex == 0 {
      _settings.commandsIndex = _settings.commandsArray.count - 1
    } else {
      _settings.commandsIndex -= 1
    }
    _settings.commandToSend = _settings.commandsArray[_settings.commandsIndex]
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
    print("remoteTxAudioEnabledChanged")
    alertInfo = AlertInfo("Remote Tx Audio Enabled", "Not Implemented (yet)")
    showAlert = true
  }
  
  public func remoteTxAudioCompressedButtonChanged() {
    alertInfo = AlertInfo("Remote Tx Audio Compressed", "Not Implemented (yet)")
    showAlert = true
  }
  
  public func sendButtonTapped() {
    _settings.commandsArray.append(_settings.commandToSend)
    // send command to the radio
    api.sendTcp(_settings.commandToSend)
    if _settings.clearOnSend { clearTextButtonTapped() }
  }
  
  public func smartlinkButtonChanged(_ enabled: Bool)  {
    if enabled {
      _settings.directEnabled = false
      smartlinkLoginOptions()
      
    } else {
      api.smartlinkListenerStop()
      api.removeRadios(.smartlink)
    }
  }
  
  public func smartlinkCancelButtonTapped() {
    _settings.smartlinkEnabled = false
  }
  
  public func smartlinkLoginButtonTapped(_ user: String, _ password: String) {
    Task {
      if let tokens = await api.smartlinkListenerStart( user, password) {
        _settings.smartlinkRefreshToken = tokens.refreshToken
        _smartlinkIdToken = tokens.idToken
      } else {
        alertInfo = AlertInfo("Smartlink login", "FAILED for user: \(user)")
        _settings.smartlinkEnabled = false
        showAlert = true
      }
    }
  }
  
  public func smartlinkLoginDidDismiss() {
    // no action required
  }
  
  public func startButtonTapped() {
    if isConnected {
      Task { await connectionStop() }
      
    } else if _settings.useDefaultEnabled {
      if let selection = _settings.isGui ? _settings.defaultGui : _settings.defaultNonGui {
        connectionStart(selection)
      } else {
        showPicker = true
      }
      
    } else {
      showPicker = true
    }
  }
  
  public func smartlinkTestButtonTapped(_ id: RadioId) {
    // find the radio
    if let radio = api.radios.first(where: { $0.id == id }) {
      // result the result
      api.smartlinkTestResult = SmartlinkTestResult()
      // perform a connection test on the smartlink radio
      api.sendSmartlinkTest(radio.packet.serial)
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public supporting methods
  
  public func hexDump(_ data: Data) -> String {
    let len = data.count
    var bytes = [UInt8](repeating: 0x00, count: len)

    (data as NSData).getBytes(&bytes, range: NSMakeRange(0, len - 1))
    
    var string = "  \(String(format: "%3d", len ))    00 01 02 03 04 05 06 07   08 09 0A 0B 0C 0D 0E 0F\n"
    string += " bytes    -------------------------------------------------\n\n"
    
    string += "----- HEADER (Hex) -----\n"
    
    var address = 0
    string += address.toHex() + "   "
    for i in 1...28 {
      string += String(format: "%02X", bytes[i-1]) + " "
      if (i % 8) == 0 { string += "  " }
      if (i % 16) == 0 {
        string += "\n"
        address += 16
        string += address.toHex() + "   "
      }
    }

    string += "\n\n----- PAYLOAD (Hex) -----\n"
      
    
    string += address.toHex() + "                                         "
    for i in 29...len {
      string += String(format: "%02X", bytes[i-1]) + " "
      if (i % 8) == 0 { string += "  " }
      if (i % 16) == 0 {
        string += "\n"
        address += 16
        string += address.toHex() + "   "
      }
    }

    string += "\n\n----- PAYLOAD (UTF8) -----\n"
      
    address = 16
    string += address.toHex() + "                                         "
    for i in 29...len {
      string += String(decoding: bytes[i-1...i-1], as: UTF8.self) + "  "
      if (i % 8) == 0 { string += "  " }
      if (i % 16) == 0 {
        string += "\n"
        address += 16
        string += address.toHex() + "   "
      }
    }
    return string
  }
  
  public func payloadProperties(_ data: Data) -> KeyValuesArray {
    //    let len = 552
    let len = data.count
    var bytes = [UInt8](repeating: 0x00, count: len)

    (data as NSData).getBytes(&bytes, range: NSMakeRange(0, len - 1))

    let payloadBytes = bytes[27...len-1]
    let text = String(decoding: payloadBytes, as: UTF8.self)
    return text.keyValuesArray()
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private supporting methods
  
  private func connect(_ activeSelection: ActiveSelection) async {
    messages.start(_settings.clearOnStart)
    
    // attempt to connect to the selected Radio / Station
    // try to connect
    let connectTask = Task {
      do {
        try await api.connect(selection: activeSelection,
                              isGui: _settings.isGui,
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
        return false
      }
    }
    isConnected = await connectTask.result.get()
    if isConnected {
      log.info("ApiExplorer: connection attempt SUCCEEDED for \(self.api.activeSelection!.radio.id)")
    } else {
      log.error("ApiExplorer: connection attempt FAILED for \(self.api.activeSelection!.radio.id)")
    }
  }
  
  private func connectionStart(_ radioId: RadioId)  {
    // validate the radio id
    if let radio = api.radios.first(where: {$0.id == radioId}) {
      api.activeSelection = ActiveSelection((radio, nil))
    } else {
      log.error("ApiExplorer: Radio not found for ID \(radioId)")
      return
    }
    // handle Multiflex
    if _settings.isGui && api.activeSelection!.radio.guiClients.count > 0 {
      showMultiflex = true
    } else {
      Task { await connect(api.activeSelection!) }
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
  private func isValid(_ idToken: IdToken?) -> Bool {
    if let token = idToken {
      if let jwt = try? decode(jwt: token) {
        let result = IDTokenValidation(issuer: kDomain, audience: kClientId).validate(jwt)
        if result == nil { return true }
      }
    }
    return false
  }

  private func smartlinkLoginOptions() {
    // start smartlink listener
    if _settings.smartlinkLoginRequired {
      // LOGIN required
      showSmartlinkLogin = true
      
    } else if isValid(_smartlinkIdToken) && _settings.smartlinkRefreshToken.isEmpty == false {
      // use ID Token
      Task {
        if let tokens = await api.smartlinkListenerStart(idToken: _smartlinkIdToken!, refreshToken: _settings.smartlinkRefreshToken) {
          _settings.smartlinkRefreshToken = tokens.refreshToken
          _smartlinkIdToken = tokens.idToken
        } else {
          // show LOGIN sheet
          showSmartlinkLogin = true
        }
      }
      
    } else if _settings.smartlinkRefreshToken.isEmpty == false {
      // use Refresh Token
      Task {
        if let tokens = await api.smartlinkListenerStart(refreshToken: _settings.smartlinkRefreshToken) {
          _settings.smartlinkRefreshToken = tokens.refreshToken
          _smartlinkIdToken = tokens.idToken
        } else {
          // show LOGIN sheet
          showSmartlinkLogin = true
        }
      }
      
    } else {
      // IdToken and/or refreshToken failure
      // show LOGIN sheet
      showSmartlinkLogin = true
    }
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
