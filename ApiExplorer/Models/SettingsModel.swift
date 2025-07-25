//
//  SimpleSettings.swift
//  ApiExplorer
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
    
    _settings.register(defaults: [
      "alertOnError": true,
      "alertOnWarning": true,
      "discoveryPort": 4992,
      "fontSize": 12,
      "isGui": true,
      "localEnabled": true,
      "mtuValue": 1250,
    ])
    
    // read values from UserDefaults
    alertOnError = _settings.bool(forKey: "alertOnError")
    alertOnWarning = _settings.bool(forKey: "alertOnWarning")
    clearOnSend = _settings.bool(forKey: "clearOnSend")
    clearOnStart = _settings.bool(forKey: "clearOnStart")
    clearOnStop = _settings.bool(forKey: "clearOnStop")
    commandsArray = _settings.stringArray(forKey: "commandsArray") ?? []
    commandsIndex = _settings.integer(forKey: "commandsIndex")
    commandToSend = _settings.string(forKey: "commandToSend") ?? ""
    daxSelection = DaxChoice(rawValue: _settings.string(forKey: "daxSelection") ?? "none") ?? .none
    defaultGui = _settings.getStruct(forKey: "defaultGui", as: PickerSelection.self)
    defaultNonGui = _settings.getStruct(forKey: "defaultNonGui", as: PickerSelection.self)
    directEnabled = _settings.bool(forKey: "directEnabled")
    discoveryDisplayType = DiscoveryDisplayType(rawValue: _settings.string(forKey: "discoveryDisplayType") ?? "fields") ?? .vitaHeader
    discoveryPort = _settings.integer(forKey: "discoveryPort")
    fontSize = _settings.integer(forKey: "fontSize")
    gotoBottom = _settings.bool(forKey: "gotoBottom")
    guiClientId = _settings.string(forKey: "guiClientId") ?? ""
    ignoreGps = _settings.bool(forKey: "ignoreGps")
    isGui = _settings.bool(forKey: "isGui")
    localEnabled = _settings.bool(forKey: "localEnabled")
    lowBandwidthConnect = _settings.bool(forKey: "lowBandwidthConnect")
    lowBandwidthDax = _settings.bool(forKey: "lowBandwidthDax")
    messageFilter = MessagesModel.Filter(rawValue: _settings.string(forKey: "messageFilter") ?? "all") ?? .all
    messageFilterText = _settings.string(forKey: "messageFilterText") ?? ""
    mtuValue = _settings.integer(forKey: "mtuValue")
    newLineBetweenMessages = _settings.bool(forKey: "newLineBetweenMessages")
    radioObjectFilters = Set(_settings.stringArray(forKey: "radioObjectFilters") ?? ["none"])
    remoteRxAudioCompressed = _settings.bool(forKey: "remoteRxAudioCompressed")
    remoteRxAudioEnabled = _settings.bool(forKey: "remoteRxAudioEnabled")
    remoteTxAudioCompressed = _settings.bool(forKey: "remoteTxAudioCompressed")
    remoteTxAudioEnabled = _settings.bool(forKey: "remoteTxAudioEnabled")
    showPings = _settings.bool(forKey: "showPings")
    showReplies = _settings.bool(forKey: "showReplies")
    showTimes = _settings.bool(forKey: "showTimes")
    smartlinkEnabled = _settings.bool(forKey: "smartlinkEnabled")
    smartlinkLoginRequired = _settings.bool(forKey: "smartlinkLoginRequired")
    smartlinkRefreshToken = _settings.string(forKey: "smartlinkRefreshToken")
    smartlinkUser = _settings.string(forKey: "smartlinkUser") ?? ""
    stationName = _settings.string(forKey: "stationName") ?? "ApiExplorer"
    stationObjectFilters = Set(_settings.stringArray(forKey: "stationObjectFilters") ?? ["panadapters", "waterfalls", "slicesMeters"])
    useDefaultEnabled = _settings.bool(forKey: "useDefaultEnabled")
    viewMode = ViewMode(rawValue: _settings.string(forKey: "viewMode") ?? "standard") ?? .all
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public (Observable) properties
  
  public var alertOnError: Bool { didSet { _settings.set(alertOnError, forKey: "alertOnError") }}
  public var alertOnWarning: Bool { didSet { _settings.set(alertOnWarning, forKey: "alertOnWarning") }}
  public var clearOnSend: Bool { didSet { _settings.set(clearOnSend, forKey: "clearOnSend") }}
  public var clearOnStart: Bool { didSet { _settings.set(clearOnStart, forKey: "clearOnStart") }}
  public var clearOnStop: Bool { didSet { _settings.set(clearOnStop, forKey: "clearOnStop") }}
  public var commandsArray: [String] { didSet { _settings.set(commandsArray, forKey: "commandsArray") }}
  public var commandsIndex: Int { didSet { _settings.set(commandsIndex, forKey: "commandsIndex") }}
  public var commandToSend: String { didSet { _settings.set(commandToSend, forKey: "commandToSend") }}
  public var daxSelection: DaxChoice { didSet { _settings.set(daxSelection.rawValue, forKey: "daxSelection") }}
  public var defaultGui: PickerSelection? { didSet { _settings.setStruct(defaultGui, forKey: "defaultGui") }}
  public var defaultNonGui: PickerSelection? { didSet { _settings.setStruct(defaultNonGui, forKey: "defaultNonGui") }}
  public var directEnabled: Bool { didSet { _settings.set(directEnabled, forKey: "directEnabled") }}
  public var discoveryDisplayType: DiscoveryDisplayType { didSet { _settings.set(discoveryDisplayType.rawValue, forKey: "discoveryDisplayType") }}
  public var discoveryPort: Int { didSet { _settings.set(discoveryPort, forKey: "discoveryPort") }}
  public var fontSize: Int { didSet { _settings.set(fontSize, forKey: "fontSize") }}
  public var gotoBottom: Bool { didSet { _settings.set(gotoBottom, forKey: "gotoBottom") }}
  public var guiClientId: String { didSet { _settings.set(guiClientId, forKey: "guiClientId") }}
  public var ignoreGps: Bool { didSet { _settings.set(ignoreGps, forKey: "ignoreGps") }}
  public var isGui: Bool { didSet { _settings.set(isGui, forKey: "isGui") }}
  public var localEnabled: Bool { didSet {  _settings.set(localEnabled, forKey: "localEnabled") }}
  public var lowBandwidthConnect: Bool { didSet { _settings.set(lowBandwidthConnect, forKey: "lowBandwidthConnect") }}
  public var lowBandwidthDax: Bool { didSet { _settings.set(lowBandwidthDax, forKey: "lowBandwidthDax") }}
  public var messageFilter: MessagesModel.Filter { didSet { _settings.set(messageFilter.rawValue, forKey: "messageFilter") }}
  public var messageFilterText: String { didSet { _settings.set(messageFilterText, forKey: "messageFilterText") }}
  public var mtuValue: Int { didSet { _settings.set(mtuValue, forKey: "mtuValue") }}
  public var newLineBetweenMessages: Bool { didSet { _settings.set(newLineBetweenMessages, forKey: "newLineBetweenMessages") }}
  public var radioObjectFilters: Set<String> { didSet { _settings.set(Array(radioObjectFilters), forKey: "radioObjectFilters") }}
  public var remoteRxAudioCompressed: Bool { didSet { _settings.set(remoteRxAudioCompressed, forKey: "remoteRxAudioCompressed") }}
  public var remoteRxAudioEnabled: Bool { didSet { _settings.set(remoteRxAudioEnabled, forKey: "remoteRxAudioEnabled") }}
  public var remoteTxAudioCompressed: Bool { didSet { _settings.set(remoteTxAudioCompressed, forKey: "remoteTxAudioCompressed") }}
  public var remoteTxAudioEnabled: Bool { didSet { _settings.set(remoteTxAudioEnabled, forKey: "remoteTxAudioEnabled") }}
  public var showPings: Bool { didSet { _settings.set(showPings, forKey: "showPings") }}
  public var showReplies: Bool { didSet { _settings.set(showReplies, forKey: "showReplies") }}
  public var showTimes: Bool { didSet { _settings.set(showTimes, forKey: "showTimes") }}
  public var smartlinkEnabled: Bool { didSet { _settings.set(smartlinkEnabled, forKey: "smartlinkEnabled") }}
  public var smartlinkLoginRequired: Bool { didSet { _settings.set(smartlinkLoginRequired, forKey: "smartlinkLoginRequired") }}
  public var smartlinkRefreshToken: String? { didSet { _settings.set(smartlinkRefreshToken, forKey: "smartlinkRefreshToken") }}
  public var smartlinkUser: String { didSet { _settings.set(smartlinkUser, forKey: "smartlinkUser") }}
  public var stationName: String { didSet { _settings.set(stationName, forKey: "stationName") }}
  public var stationObjectFilters: Set<String> { didSet { _settings.set(Array(stationObjectFilters), forKey: "stationObjectFilters") }}
  public var useDefaultEnabled: Bool { didSet { _settings.set(useDefaultEnabled, forKey: "useDefaultEnabled") }}
  public var viewMode: ViewMode { didSet { _settings.set(viewMode.rawValue, forKey: "viewMode") }}

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private let _settings: UserDefaults
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  // write values to UserDefaults
  public func save() {
    _settings.set(alertOnError, forKey: "alertOnError")
    _settings.set(alertOnWarning, forKey: "alertOnWarning")
    _settings.set(clearOnSend, forKey: "clearOnSend")
    _settings.set(clearOnStart, forKey: "clearOnStart")
    _settings.set(clearOnStop, forKey: "clearOnStop")
    _settings.set(commandsArray, forKey: "commandsArray")
    _settings.set(commandsIndex, forKey: "commandsIndex")
    _settings.set(commandToSend, forKey: "commandToSend")
    _settings.set(daxSelection.rawValue, forKey: "daxSelection")
    _settings.setStruct(defaultGui, forKey: "defaultGui")
    _settings.setStruct(defaultNonGui, forKey: "defaultNonGui")
    _settings.set(directEnabled, forKey: "directEnabled")
    _settings.set(discoveryDisplayType.rawValue, forKey: "discoveryDisplayType")
    _settings.set(discoveryPort, forKey: "discoveryPort")
    _settings.set(fontSize, forKey: "fontSize")
    _settings.set(gotoBottom, forKey: "gotoBottom")
    _settings.set(guiClientId, forKey: "guiClientId")
    _settings.set(ignoreGps, forKey: "ignoreGps")
    _settings.set(isGui, forKey: "isGui")
    _settings.set(localEnabled, forKey: "localEnabled")
    _settings.set(lowBandwidthConnect, forKey: "lowBandwidthConnect")
    _settings.set(lowBandwidthDax, forKey: "lowBandwidthDax")
    _settings.set(messageFilter.rawValue, forKey: "messageFilter")
    _settings.set(messageFilterText, forKey: "messageFilterText")
    _settings.set(mtuValue, forKey: "mtuValue")
    _settings.set(newLineBetweenMessages, forKey: "newLineBetweenMessages")
    _settings.set(radioObjectFilters, forKey: "radioObjectFilters")
    _settings.set(remoteRxAudioCompressed, forKey: "remoteRxAudioCompressed")
    _settings.set(remoteRxAudioEnabled, forKey: "remoteRxAudioEnabled")
    _settings.set(remoteTxAudioCompressed, forKey: "remoteTxAudioCompressed")
    _settings.set(remoteTxAudioEnabled, forKey: "remoteTxAudioEnabled")
    _settings.set(showPings, forKey: "showPings")
    _settings.set(showReplies, forKey: "showReplies")
    _settings.set(showTimes, forKey: "showTimes")
    _settings.set(smartlinkEnabled, forKey: "smartlinkEnabled")
    _settings.set(smartlinkLoginRequired, forKey: "smartlinkLoginRequired")
    _settings.set(smartlinkRefreshToken, forKey: "smartlinkRefreshToken")
    _settings.set(smartlinkUser, forKey: "smartlinkUser")
    _settings.set(stationName, forKey: "stationName")
    _settings.set(stationObjectFilters, forKey: "stationObjectFilters")
    _settings.set(useDefaultEnabled, forKey: "useDefaultEnabled")
    _settings.set(viewMode.rawValue, forKey: "viewMode")
  }
  
  public func reset(_ name: String = Bundle.main.bundleIdentifier!) {
    _settings.removePersistentDomain(forName: name)
  }
}

extension UserDefaults {
  
  /// Save a Codable struct to UserDefaults
  func setStruct<T: Codable>(_ value: T, forKey key: String) {
    if let encoded = try? JSONEncoder().encode(value) {
      self.set(encoded, forKey: key)
    }
  }
  
  /// Retrieve a Codable struct from UserDefaults
  func getStruct<T: Codable>(forKey key: String, as type: T.Type) -> T? {
    guard let savedData = self.data(forKey: key),
          let decodedObject = try? JSONDecoder().decode(T.self, from: savedData) else {
      return nil
    }
    return decodedObject
  }
}
