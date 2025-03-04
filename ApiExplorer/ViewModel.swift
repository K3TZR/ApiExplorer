//
//  ViewModel.swift
//  ApiViewer
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
    settings = SettingsModel()
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  // models
  public var messages: MessagesModel!
  public let api: ApiModel!
  public var settings: SettingsModel!
  
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
  // MARK: - Public methods
  
  public func onAppear() {
    if initialized == false {
      log.debug("ApiViewer: application started")
      
      messages.filter = settings.messageFilter
      messages.text = settings.messageFilterText
      messages.showPings = settings.showPings
      messages.showReplies = settings.showReplies
      
      // mark as initialized
      initialized = true
      if settings.localEnabled {
        api.localListenerStart()
      }
      if settings.smartlinkEnabled {
        // start smartlink listener
        if settings.smartlinkLoginRequired {
          showSmartlinkLogin = true
        } else {
          Task { await api.smartlinkListenerStart(settings.smartlinkRefreshToken) }
        }
      }
      if settings.guiClientId.isEmpty {
        settings.guiClientId = UUID().uuidString
      }
    }
  }
  
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
  // MARK: - Public actions
  
  public func clearTextButtonTapped() {
    settings.commandToSend = ""
  }
  
  public func daxSelectionChanged(_ old: DaxChoice, _ new: DaxChoice) {
    print("daxSelectionChanged")
    alertInfo = AlertInfo("Dax Selection", "Not Implemented (yet)")
    showAlert = true
  }
  
  public func defaultButtonTapped(_ radioId: String) {
    // set / reset the default
    if settings.isGui {
      if settings.defaultGui == radioId {
        settings.defaultGui = ""
      } else {
        settings.defaultGui = radioId
      }
    } else {
      if settings.defaultNonGui == radioId {
        settings.defaultNonGui = ""
      } else {
        settings.defaultNonGui = radioId
      }
    }
  }
  
  public func directButtonChanged(_ enabled: Bool) {
    print("directChanged \(enabled)")
    if enabled {
      settings.localEnabled = false
      settings.smartlinkEnabled = false
    }
  }
  
  public func guiButtonTapped() {
    settings.isGui.toggle()
  }
  
  public func localButtonChanged(_ enabled: Bool) {
    print("localChanged \(enabled)")
    if enabled {
      settings.directEnabled = false
      api.localListenerStart()
    } else {
      api.localListenerStop()
    }
  }
  
  public func multiflexConnectButtonTapped() {
    Task { await connect(api.activeSelection!) }
  }
  
  public func nextStepperTapped() {
    print("nextTapped")
    if settings.commandsIndex == settings.commandsArray.count - 1 {
      settings.commandsIndex = 0
    } else {
      settings.commandsIndex += 1
    }
    settings.commandToSend = settings.commandsArray[settings.commandsIndex]
  }
  
  public func pickerConnectButtonTapped(_ radioId: String, _ station: String) {
    print("pickerConnectButtonTapped: radio \(radioId), station \(station)")
    
    api.activeStation = station
    // try to connect to the selected radio / station
    connectionStart(radioId)
  }
  
  public func previousStepperTapped() {
    print("previousTapped")
    if settings.commandsIndex == 0 {
      settings.commandsIndex = settings.commandsArray.count - 1
    } else {
      settings.commandsIndex -= 1
    }
    settings.commandToSend = settings.commandsArray[settings.commandsIndex]
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
    settings.commandsArray.append(settings.commandToSend)
    // send command to the radio
    api.sendTcp(settings.commandToSend)
    if settings.clearOnSend { clearTextButtonTapped() }
  }
  
  public func smartlinkButtonChanged(_ enabled: Bool)  {
    if enabled {
      settings.directEnabled = false
      if settings.smartlinkLoginRequired {
        showSmartlinkLogin = true
      } else {
        let refreshToken = settings.smartlinkRefreshToken
        Task { await api.smartlinkListenerStart(refreshToken) }
      }
      
      // FIXME: remove hard coded user/pwd
//      Task { await apiModel.smartlinkListenerStart("douglas.adams@me.com", "fleX!20Comm") }
      
    } else {
      api.smartlinkListenerStop()
      api.removeRadios(.smartlink)
    }
  }
  
  public func smartlinkCancelButtonTapped() {
    settings.smartlinkEnabled = false
  }
  
  public func smartlinkLoginButtonTapped(_ user: String, _ password: String) {
    Task { await api.smartlinkListenerStart( user, password) }
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
  // MARK: - Private supporting methods
  
  private func connect(_ activeSelection: ActiveSelection) async {
    messages.start(settings.clearOnStart)
    
    // attempt to connect to the selected Radio / Station
    // try to connect
    let connectTask = Task {
      do {
        try await api.connect(selection: activeSelection,
                                      isGui: settings.isGui,
                                      programName: "ApiViewer",
                                      mtuValue: settings.mtuValue,
                                      guiClientId: UUID(uuidString: settings.guiClientId)!,
                                      lowBandwidthDax: settings.lowBandwidthDax,
                                      lowBandwidthConnect: settings.lowBandwidthConnect,
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
      log.info("ApiViewer: connection attempt SUCCEEDED for \(self.api.activeSelection!.radio.id)")
    } else {
      log.error("ApiViewer: connection attempt FAILED for \(self.api.activeSelection!.radio.id)")
    }
  }
  
  private func connectionStart(_ radioId: RadioId)  {
    // validate the radio id
    if let radio = api.radios.first(where: {$0.id == radioId}) {
      api.activeSelection = ActiveSelection((radio, nil))
    } else {
      log.error("ApiViewer: Radio not found for ID \(radioId)")
      return
    }
    // handle Multiflex
    if settings.isGui && api.activeSelection!.radio.guiClients.count > 0 {
      showMultiflex = true
    } else {
      Task { await connect(api.activeSelection!) }
    }
  }
  
  private func connectionStop() async {
    messages.stop(settings.clearOnStop)
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
}
