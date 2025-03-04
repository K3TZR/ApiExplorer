//
//  SimpleSettings.swift
//  ApiViewer
//
//  Created by Douglas Adams on 12/30/24.
//

import Foundation

import ApiPackage

@Observable
public class SettingsModel {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization

  public init(_ settings: UserDefaults = UserDefaults.standard) {
    _settings = settings

    // read values from UserDefaults
    alertOnError = _settings.bool(forKey: "alertOnError")
    clearOnSend = _settings.bool(forKey: "clearOnSend")
    clearOnStart = _settings.bool(forKey: "clearOnStart")
    clearOnStop = _settings.bool(forKey: "clearOnStop")
    commandsArray = _settings.stringArray(forKey: "commandsArray") ?? []
    commandsIndex = _settings.integer(forKey: "commandsIndex")
    commandToSend = _settings.string(forKey: "commandToSend") ?? ""
    daxSelection = DaxChoice(rawValue: _settings.string(forKey: "daxSelection") ?? "none") ?? .none
    defaultGui = _settings.string(forKey: "defaultGui")
    defaultNonGui = _settings.string(forKey: "defaultNonGui")
    directEnabled = _settings.bool(forKey: "directEnabled")
    discoveryDisplayType = DiscoveryDisplayType(rawValue: _settings.string(forKey: "discoveryDisplayType") ?? "fields") ?? .fields
    fontSize = _settings.integer(forKey: "fontSize")
    gotoBottom = _settings.bool(forKey: "gotoBottom")
    guiClientId = _settings.string(forKey: "guiClientId") ?? ""
    isGui = _settings.bool(forKey: "isGui")
    localEnabled = _settings.bool(forKey: "localEnabled")
    lowBandwidthConnect = _settings.bool(forKey: "lowBandwidthConnect")
    lowBandwidthDax = _settings.bool(forKey: "lowBandwidthDax")
    messageFilter = MessagesModel.Filter(rawValue: _settings.string(forKey: "messageFilter") ?? "all") ?? .all
    messageFilterText = _settings.string(forKey: "messageFilterText") ?? ""
    mtuValue = _settings.integer(forKey: "mtuValue")
    newLineBetweenMessages = _settings.bool(forKey: "newLineBetweenMessages")
    radioObjectFilter = RadioObjectFilter(rawValue: _settings.string(forKey: "radioObjectFilter") ?? "all") ?? .all
    remoteRxAudioCompressed = _settings.bool(forKey: "remoteRxAudioCompressed")
    remoteRxAudioEnabled = _settings.bool(forKey: "remoteRxAudioEnabled")
    remoteTxAudioCompressed = _settings.bool(forKey: "remoteTxAudioCompressed")
    remoteTxAudioEnabled = _settings.bool(forKey: "remoteTxAudioEnabled")
    showPings = _settings.bool(forKey: "showPings")
    showReplies = _settings.bool(forKey: "showReplies")
    showTimes = _settings.bool(forKey: "showTimes")
    smartlinkEnabled = _settings.bool(forKey: "smartlinkEnabled")
    smartlinkLoginRequired = _settings.bool(forKey: "smartlinkLoginRequired")
    smartlinkPreviousIdToken = _settings.string(forKey: "smartlinkPreviousIdToken") ?? ""
    smartlinkRefreshToken = _settings.string(forKey: "smartlinkRefreshToken") ?? ""
    smartlinkUser = _settings.string(forKey: "smartlinkUser") ?? ""
    stationObjectFilter = StationObjectFilter(rawValue: _settings.string(forKey: "stationObjectFilter") ?? "all") ?? .all
    useDefaultEnabled = _settings.bool(forKey: "useDefaultEnabled")

    if fontSize < 12 || fontSize > 18 { fontSize = 12 }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public (Observable) properties
  
  public var alertOnError: Bool { didSet { _settings.set(alertOnError, forKey: "alertOnError") }}
  public var clearOnSend: Bool { didSet { _settings.set(clearOnSend, forKey: "clearOnSend") }}
  public var clearOnStart: Bool { didSet { _settings.set(clearOnStart, forKey: "clearOnStart") }}
  public var clearOnStop: Bool { didSet { _settings.set(clearOnStop, forKey: "clearOnStop") }}
  public var commandsArray: [String] { didSet { _settings.set(commandsArray, forKey: "commandsArray") }}
  public var commandsIndex: Int { didSet { _settings.set(commandsIndex, forKey: "commandsIndex") }}
  public var commandToSend: String { didSet { _settings.set(commandToSend, forKey: "commandToSend") }}
  public var daxSelection: DaxChoice { didSet { _settings.set(daxSelection.rawValue, forKey: "daxSelection") }}
  public var defaultGui: String? { didSet { _settings.set(defaultGui, forKey: "defaultGui") }}
  public var defaultNonGui: String? { didSet { _settings.set(defaultNonGui, forKey: "defaultNonGui") }}
  public var directEnabled: Bool { didSet { _settings.set(directEnabled, forKey: "directEnabled") }}
  public var discoveryDisplayType: DiscoveryDisplayType { didSet { _settings.set(discoveryDisplayType.rawValue, forKey: "discoveryDisplayType") }}
  public var fontSize: Int { didSet { _settings.set(fontSize, forKey: "fontSize") }}
  public var gotoBottom: Bool { didSet { _settings.set(gotoBottom, forKey: "gotoBottom") }}
  public var guiClientId: String { didSet { _settings.set(guiClientId, forKey: "guiClientId") }}
  public var isGui: Bool { didSet { _settings.set(isGui, forKey: "isGui") }}
  public var localEnabled: Bool { didSet { _settings.set(localEnabled, forKey: "localEnabled") }}
  public var lowBandwidthConnect: Bool { didSet { _settings.set(lowBandwidthConnect, forKey: "lowBandwidthConnect") }}
  public var lowBandwidthDax: Bool { didSet { _settings.set(lowBandwidthDax, forKey: "lowBandwidthDax") }}
  public var messageFilter: MessagesModel.Filter { didSet { _settings.set(messageFilter.rawValue, forKey: "messageFilter") }}
  public var messageFilterText: String { didSet { _settings.set(messageFilterText, forKey: "messageFilterText") }}
  public var mtuValue: Int { didSet { _settings.set(mtuValue, forKey: "mtuValue") }}
  public var newLineBetweenMessages: Bool { didSet { _settings.set(newLineBetweenMessages, forKey: "newLineBetweenMessages") }}
  public var radioObjectFilter: RadioObjectFilter { didSet { _settings.set(radioObjectFilter.rawValue, forKey: "radioObjectFilter") }}
  public var remoteRxAudioCompressed: Bool { didSet { _settings.set(remoteRxAudioCompressed, forKey: "remoteRxAudioCompressed") }}
  public var remoteRxAudioEnabled: Bool { didSet { _settings.set(remoteRxAudioEnabled, forKey: "remoteRxAudioEnabled") }}
  public var remoteTxAudioCompressed: Bool { didSet { _settings.set(remoteTxAudioCompressed, forKey: "remoteTxAudioCompressed") }}
  public var remoteTxAudioEnabled: Bool { didSet { _settings.set(remoteTxAudioEnabled, forKey: "remoteTxAudioEnabled") }}
  public var showPings: Bool { didSet { _settings.set(showPings, forKey: "showPings") }}
  public var showReplies: Bool { didSet { _settings.set(showReplies, forKey: "showReplies") }}
  public var showTimes: Bool { didSet { _settings.set(showTimes, forKey: "showTimes") }}
  public var smartlinkEnabled: Bool { didSet { _settings.set(smartlinkEnabled, forKey: "smartlinkEnabled") }}
  public var smartlinkLoginRequired: Bool { didSet { _settings.set(smartlinkLoginRequired, forKey: "smartlinkLoginRequired") }}
  public var smartlinkPreviousIdToken: String { didSet { _settings.set(smartlinkPreviousIdToken, forKey: "smartlinkPreviousIdToken") }}
  public var smartlinkRefreshToken: String { didSet { _settings.set(smartlinkRefreshToken, forKey: "smartlinkRefreshToken") }}
  public var smartlinkUser: String { didSet { _settings.set(smartlinkUser, forKey: "smartlinkUser") }}
  public var stationObjectFilter: StationObjectFilter { didSet { _settings.set(stationObjectFilter.rawValue, forKey: "stationObjectFilter") }}
  public var useDefaultEnabled: Bool { didSet { _settings.set(useDefaultEnabled, forKey: "useDefaultEnabled") }}
    
  // ----------------------------------------------------------------------------
  // MARK: - Private properties

  private let _settings: UserDefaults
  
// ----------------------------------------------------------------------------
// MARK: - Public methods

  // write values to UserDefaults
  public func save() {
    _settings.set(alertOnError, forKey: "alertOnError")
    _settings.set(clearOnSend, forKey: "clearOnSend")
    _settings.set(clearOnStart, forKey: "clearOnStart")
    _settings.set(clearOnStop, forKey: "clearOnStop")
    _settings.set(commandsArray, forKey: "commandsArray")
    _settings.set(commandsIndex, forKey: "commandsIndex")
    _settings.set(commandToSend, forKey: "commandToSend")
    _settings.set(daxSelection.rawValue, forKey: "daxSelection")
    _settings.set(defaultGui, forKey: "defaultGui")
    _settings.set(defaultNonGui, forKey: "defaultNonGui")
    _settings.set(directEnabled, forKey: "directEnabled")
    _settings.set(discoveryDisplayType.rawValue, forKey: "discoveryDisplayType")
    _settings.set(fontSize, forKey: "fontSize")
    _settings.set(gotoBottom, forKey: "gotoBottom")
    _settings.set(guiClientId, forKey: "guiClientId")
    _settings.set(isGui, forKey: "isGui")
    _settings.set(localEnabled, forKey: "localEnabled")
    _settings.set(lowBandwidthConnect, forKey: "lowBandwidthConnect")
    _settings.set(lowBandwidthDax, forKey: "lowBandwidthDax")
    _settings.set(messageFilter.rawValue, forKey: "messageFilter")
    _settings.set(messageFilterText, forKey: "messageFilterText")
    _settings.set(mtuValue, forKey: "mtuValue")
    _settings.set(newLineBetweenMessages, forKey: "newLineBetweenMessages")
    _settings.set(radioObjectFilter.rawValue, forKey: "radioObjectFilter")
    _settings.set(remoteRxAudioCompressed, forKey: "remoteRxAudioCompressed")
    _settings.set(remoteRxAudioEnabled, forKey: "remoteRxAudioEnabled")
    _settings.set(remoteTxAudioCompressed, forKey: "remoteTxAudioCompressed")
    _settings.set(remoteTxAudioEnabled, forKey: "remoteTxAudioEnabled")
    _settings.set(showPings, forKey: "showPings")
    _settings.set(showReplies, forKey: "showReplies")
    _settings.set(showTimes, forKey: "showTimes")
    _settings.set(smartlinkEnabled, forKey: "smartlinkEnabled")
    _settings.set(smartlinkLoginRequired, forKey: "smartlinkLoginRequired")
    _settings.set(smartlinkPreviousIdToken, forKey: "smartlinkPreviousIdToken")
    _settings.set(smartlinkRefreshToken, forKey: "smartlinkRefreshToken")
    _settings.set(smartlinkUser, forKey: "smartlinkUser")
    _settings.set(stationObjectFilter.rawValue, forKey: "stationObjectFilter")
    _settings.set(useDefaultEnabled, forKey: "useDefaultEnabled")
  }
  
  public func reset(_ name: String = Bundle.main.bundleIdentifier!) {
    _settings.removePersistentDomain(forName: name)
  }
}

