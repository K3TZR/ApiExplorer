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
    messageModel = MessageModel()
    objectModel = ObjectModel()
    settingModel = SettingModel()
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  // models
  public var messageModel: MessageModel!
  public let objectModel: ObjectModel!
  public var settingModel: SettingModel!
  
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
      
      messageModel.filter = settingModel.messageFilter
      messageModel.text = settingModel.messageFilterText
      messageModel.showPings = settingModel.showPings
      messageModel.showReplies = settingModel.showReplies
      
      // mark as initialized
      initialized = true
      if settingModel.localEnabled {
        objectModel.startLocalListener()
      }
      if settingModel.smartlinkEnabled {
        // start smartlink listener
        if settingModel.smartlinkLoginRequired {
          showSmartlinkLogin = true
        } else {
          Task { await objectModel.startSmartlinkListener() }
        }
      }
      if settingModel.guiClientId.isEmpty {
        settingModel.guiClientId = UUID().uuidString
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
    settingModel.commandToSend = ""
  }
  
  public func daxSelectionChanged(_ old: DaxChoice, _ new: DaxChoice) {
    print("daxSelectionChanged")
    alertInfo = AlertInfo("Dax Selection", "Not Implemented (yet)")
    showAlert = true
  }
  
  public func defaultButtonTapped(_ radioId: String) {
    // set / reset the default
    if settingModel.isGui {
      if settingModel.defaultGui == radioId {
        settingModel.defaultGui = ""
      } else {
        settingModel.defaultGui = radioId
      }
    } else {
      if settingModel.defaultNonGui == radioId {
        settingModel.defaultNonGui = ""
      } else {
        settingModel.defaultNonGui = radioId
      }
    }
  }
  
  public func directButtonChanged(_ enabled: Bool) {
    print("directChanged \(enabled)")
    if enabled {
      settingModel.localEnabled = false
      settingModel.smartlinkEnabled = false
    }
  }
  
  public func guiButtonTapped() {
    settingModel.isGui.toggle()
  }
  
  public func localButtonChanged(_ enabled: Bool) {
    print("localChanged \(enabled)")
    if enabled {
      settingModel.directEnabled = false
      objectModel.startLocalListener()
    } else {
      objectModel.stopLocalListener()
    }
  }
  
  public func multiflexConnectButtonTapped() {
    Task { await connect(objectModel.activeSelection!) }
  }
  
  public func nextStepperTapped() {
    print("nextTapped")
    if settingModel.commandsIndex == settingModel.commandsArray.count - 1 {
      settingModel.commandsIndex = 0
    } else {
      settingModel.commandsIndex += 1
    }
    settingModel.commandToSend = settingModel.commandsArray[settingModel.commandsIndex]
  }
  
  public func pickerConnectButtonTapped(_ radioId: String, _ station: String) {
    print("pickerConnectButtonTapped: radio \(radioId), station \(station)")
    
    objectModel.activeStation = station
    // try to connect to the selected radio / station
    connectionStart(radioId)
  }
  
  public func previousStepperTapped() {
    print("previousTapped")
    if settingModel.commandsIndex == 0 {
      settingModel.commandsIndex = settingModel.commandsArray.count - 1
    } else {
      settingModel.commandsIndex -= 1
    }
    settingModel.commandToSend = settingModel.commandsArray[settingModel.commandsIndex]
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
    settingModel.commandsArray.append(settingModel.commandToSend)
    // send command to the radio
    objectModel.sendTcp(settingModel.commandToSend)
    if settingModel.clearOnSend { clearTextButtonTapped() }
  }
  
  public func smartlinkButtonChanged(_ enabled: Bool)  {
    if enabled {
      settingModel.directEnabled = false
      if settingModel.smartlinkLoginRequired {
        showSmartlinkLogin = true
      }
      
      // FIXME: remove hard coded user/pwd
      Task { await objectModel.startSmartlinkListener("douglas.adams@me.com", "fleX!20Comm") }
      
    } else {
      objectModel.stopSmartlinkListener()
      objectModel.removeRadios(.smartlink)
    }
  }
  
  public func smartlinkCancelButtonTapped() {
    settingModel.smartlinkEnabled = false
  }
  
  public func smartlinkLoginButtonTapped(_ user: String, _ password: String) {
    Task { await objectModel.startSmartlinkListener( user, password) }
  }
  
  public func smartlinkLoginDidDismiss() {
    
  }
  
  public func startButtonTapped() {
    if isConnected {
      Task { await connectionStop() }
      
    } else if settingModel.useDefaultEnabled {
      if let selection = settingModel.isGui ? settingModel.defaultGui : settingModel.defaultNonGui {
        connectionStart(selection)
      } else {
        showPicker = true
      }
      
    } else {
      showPicker = true
    }
  }
  
  public func testButtonTapped(_ id: RadioId) {
    // perform a connection test on the smartlink radio
    alertInfo = AlertInfo("Test Button", "Not Implemented (yet)")
    showAlert = true
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private supporting methods
  
  private func connect(_ activeSelection: ActiveSelection) async {
    messageModel.start(settingModel.clearOnStart)
    
    // attempt to connect to the selected Radio / Station
    // try to connect
    let connectTask = Task {
      do {
        try await objectModel.connect(selection: activeSelection,
                                      isGui: settingModel.isGui,
                                      programName: "ApiViewer",
                                      mtuValue: settingModel.mtuValue,
                                      guiClientId: UUID(uuidString: settingModel.guiClientId)!,
                                      lowBandwidthDax: settingModel.lowBandwidthDax,
                                      lowBandwidthConnect: settingModel.lowBandwidthConnect,
                                      testDelegate: messageModel)
        // connection succesful
        return true
        
      } catch {
        // connection attempt failed
        return false
      }
    }
    isConnected = await connectTask.result.get()
    if isConnected {
      log.info("ApiViewer: connection attempt SUCCEEDED for \(self.objectModel.activeSelection!.radio.id)")
    } else {
      log.error("ApiViewer: connection attempt FAILED for \(self.objectModel.activeSelection!.radio.id)")
    }
  }
  
  private func connectionStart(_ radioId: RadioId)  {
    // validate the radio id
    if let radio = objectModel.radios.first(where: {$0.id == radioId}) {
      objectModel.activeSelection = ActiveSelection((radio, nil))
    } else {
      log.error("ApiViewer: Radio not found for ID \(radioId)")
      return
    }
    // handle Multiflex
    if settingModel.isGui && objectModel.activeSelection!.radio.guiClients.count > 0 {
      showMultiflex = true
    } else {
      Task { await connect(objectModel.activeSelection!) }
    }
  }
  
  private func connectionStop() async {
    messageModel.stop(settingModel.clearOnStop)
    await objectModel.disconnect()
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
