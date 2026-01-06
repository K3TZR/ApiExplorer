//
//  SimpleSettings.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 12/30/24.
//

import Foundation

import ApiPackage

@MainActor
@Observable
public class SettingsModel {
  // ----------------------------------------------------------------------------
  // MARK: - Settings Keys
  
  private enum SettingsKey: String {
    case alertOnError
    case alertOnWarning
    case clearOnSend
    case clearOnStart
    case clearOnStop
    case commandsArray
    case commandsIndex
    case commandToSend
    case daxSelection
    case defaultGui
    case defaultNonGui
    case directEnabled
    case discoveryDisplayType
    case discoveryPort
    case fontSize
    case gotoBottom
    case guiClientId
    case ignoreGps
    case isGui
    case localEnabled
    case lowBandwidthConnect
    case lowBandwidthDax
    case messageFilter
    case messageFilterText
    case mtuValue
    case newLineBetweenMessages
    case radioObjectFilters
    case remoteRxAudioCompressed
    case remoteRxAudioEnabled
    case remoteTxAudioCompressed
    case remoteTxAudioEnabled
    case showPings
    case showReplies
    case showTimes
    case smartlinkEnabled
    case smartlinkLoginRequired
    case smartlinkRefreshToken
    case smartlinkUser
    case stationName
    case stationObjectFilters
    case useDefaultEnabled
    case viewMode
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ settings: UserDefaults = UserDefaults.standard) {
    _settings = settings
    
    _settings.register(defaults: [
      SettingsKey.alertOnError.rawValue: true,
      SettingsKey.alertOnWarning.rawValue: true,
      SettingsKey.discoveryPort.rawValue: 4992,
      SettingsKey.fontSize.rawValue: 12,
      SettingsKey.isGui.rawValue: true,
      SettingsKey.localEnabled.rawValue: true,
      SettingsKey.mtuValue.rawValue: 1250,
    ])
    
    // read values from UserDefaults
    alertOnError = _settings.bool(forKey: SettingsKey.alertOnError.rawValue)
    alertOnWarning = _settings.bool(forKey: SettingsKey.alertOnWarning.rawValue)
    clearOnSend = _settings.bool(forKey: SettingsKey.clearOnSend.rawValue)
    clearOnStart = _settings.bool(forKey: SettingsKey.clearOnStart.rawValue)
    clearOnStop = _settings.bool(forKey: SettingsKey.clearOnStop.rawValue)
    commandsArray = _settings.stringArray(forKey: SettingsKey.commandsArray.rawValue) ?? []
    commandsIndex = _settings.integer(forKey: SettingsKey.commandsIndex.rawValue)
    commandToSend = _settings.string(forKey: SettingsKey.commandToSend.rawValue) ?? ""
    daxSelection = DaxChoice(rawValue: _settings.string(forKey: SettingsKey.daxSelection.rawValue) ?? "none") ?? .none
    defaultGui = _settings.getStruct(forKey: SettingsKey.defaultGui.rawValue, as: PickerSelection.self)
    defaultNonGui = _settings.getStruct(forKey: SettingsKey.defaultNonGui.rawValue, as: PickerSelection.self)
    directEnabled = _settings.bool(forKey: SettingsKey.directEnabled.rawValue)
    discoveryDisplayType = DiscoveryDisplayType(rawValue: _settings.string(forKey: SettingsKey.discoveryDisplayType.rawValue) ?? "fields") ?? .vitaHeaderView
    discoveryPort = _settings.integer(forKey: SettingsKey.discoveryPort.rawValue)
    fontSize = _settings.integer(forKey: SettingsKey.fontSize.rawValue)
    gotoBottom = _settings.bool(forKey: SettingsKey.gotoBottom.rawValue)
    guiClientId = _settings.string(forKey: SettingsKey.guiClientId.rawValue) ?? ""
    ignoreGps = _settings.bool(forKey: SettingsKey.ignoreGps.rawValue)
    isGui = _settings.bool(forKey: SettingsKey.isGui.rawValue)
    localEnabled = _settings.bool(forKey: SettingsKey.localEnabled.rawValue)
    lowBandwidthConnect = _settings.bool(forKey: SettingsKey.lowBandwidthConnect.rawValue)
    lowBandwidthDax = _settings.bool(forKey: SettingsKey.lowBandwidthDax.rawValue)
    messageFilter = MessagesModel.Filter(rawValue: _settings.string(forKey: SettingsKey.messageFilter.rawValue) ?? "all") ?? .all
    messageFilterText = _settings.string(forKey: SettingsKey.messageFilterText.rawValue) ?? ""
    mtuValue = _settings.integer(forKey: SettingsKey.mtuValue.rawValue)
    newLineBetweenMessages = _settings.bool(forKey: SettingsKey.newLineBetweenMessages.rawValue)
    radioObjectFilters = Set(_settings.stringArray(forKey: SettingsKey.radioObjectFilters.rawValue) ?? ["none"])
    remoteRxAudioCompressed = _settings.bool(forKey: SettingsKey.remoteRxAudioCompressed.rawValue)
    remoteRxAudioEnabled = _settings.bool(forKey: SettingsKey.remoteRxAudioEnabled.rawValue)
    remoteTxAudioCompressed = _settings.bool(forKey: SettingsKey.remoteTxAudioCompressed.rawValue)
    remoteTxAudioEnabled = _settings.bool(forKey: SettingsKey.remoteTxAudioEnabled.rawValue)
    showPings = _settings.bool(forKey: SettingsKey.showPings.rawValue)
    showReplies = _settings.bool(forKey: SettingsKey.showReplies.rawValue)
    showTimes = _settings.bool(forKey: SettingsKey.showTimes.rawValue)
    smartlinkEnabled = _settings.bool(forKey: SettingsKey.smartlinkEnabled.rawValue)
    smartlinkLoginRequired = _settings.bool(forKey: SettingsKey.smartlinkLoginRequired.rawValue)
    smartlinkRefreshToken = _settings.string(forKey: SettingsKey.smartlinkRefreshToken.rawValue)
    smartlinkUser = _settings.string(forKey: SettingsKey.smartlinkUser.rawValue) ?? ""
    stationName = _settings.string(forKey: SettingsKey.stationName.rawValue) ?? "ApiExplorer"
    stationObjectFilters = Set(_settings.stringArray(forKey: SettingsKey.stationObjectFilters.rawValue) ?? ["panadapters", "waterfalls", "slicesMeters"])
    useDefaultEnabled = _settings.bool(forKey: SettingsKey.useDefaultEnabled.rawValue)
    viewMode = ViewMode(rawValue: _settings.string(forKey: SettingsKey.viewMode.rawValue) ?? "standard") ?? .all
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public (Observable) properties
  
  public var alertOnError: Bool { didSet { _settings.set(alertOnError, forKey: SettingsKey.alertOnError.rawValue) }}
  public var alertOnWarning: Bool { didSet { _settings.set(alertOnWarning, forKey: SettingsKey.alertOnWarning.rawValue) }}
  public var clearOnSend: Bool { didSet { _settings.set(clearOnSend, forKey: SettingsKey.clearOnSend.rawValue) }}
  public var clearOnStart: Bool { didSet { _settings.set(clearOnStart, forKey: SettingsKey.clearOnStart.rawValue) }}
  public var clearOnStop: Bool { didSet { _settings.set(clearOnStop, forKey: SettingsKey.clearOnStop.rawValue) }}
  public var commandsArray: [String] { didSet { _settings.set(commandsArray, forKey: SettingsKey.commandsArray.rawValue) }}
  public var commandsIndex: Int { didSet { _settings.set(commandsIndex, forKey: SettingsKey.commandsIndex.rawValue) }}
  public var commandToSend: String { didSet { _settings.set(commandToSend, forKey: SettingsKey.commandToSend.rawValue) }}
  public var daxSelection: DaxChoice { didSet { _settings.set(daxSelection.rawValue, forKey: SettingsKey.daxSelection.rawValue) }}
  public var defaultGui: PickerSelection? { didSet { _settings.setStruct(defaultGui, forKey: SettingsKey.defaultGui.rawValue) }}
  public var defaultNonGui: PickerSelection? { didSet { _settings.setStruct(defaultNonGui, forKey: SettingsKey.defaultNonGui.rawValue) }}
  public var directEnabled: Bool { didSet { _settings.set(directEnabled, forKey: SettingsKey.directEnabled.rawValue) }}
  public var discoveryDisplayType: DiscoveryDisplayType { didSet { _settings.set(discoveryDisplayType.rawValue, forKey: SettingsKey.discoveryDisplayType.rawValue) }}
  public var discoveryPort: Int { didSet { _settings.set(discoveryPort, forKey: SettingsKey.discoveryPort.rawValue) }}
  public var fontSize: Int { didSet { _settings.set(fontSize, forKey: SettingsKey.fontSize.rawValue) }}
  public var gotoBottom: Bool { didSet { _settings.set(gotoBottom, forKey: SettingsKey.gotoBottom.rawValue) }}
  public var guiClientId: String { didSet { _settings.set(guiClientId, forKey: SettingsKey.guiClientId.rawValue) }}
  public var ignoreGps: Bool { didSet { _settings.set(ignoreGps, forKey: SettingsKey.ignoreGps.rawValue) }}
  public var isGui: Bool { didSet { _settings.set(isGui, forKey: SettingsKey.isGui.rawValue) }}
  public var localEnabled: Bool { didSet {  _settings.set(localEnabled, forKey: SettingsKey.localEnabled.rawValue) }}
  public var lowBandwidthConnect: Bool { didSet { _settings.set(lowBandwidthConnect, forKey: SettingsKey.lowBandwidthConnect.rawValue) }}
  public var lowBandwidthDax: Bool { didSet { _settings.set(lowBandwidthDax, forKey: SettingsKey.lowBandwidthDax.rawValue) }}
  public var messageFilter: MessagesModel.Filter { didSet { _settings.set(messageFilter.rawValue, forKey: SettingsKey.messageFilter.rawValue) }}
  public var messageFilterText: String { didSet { _settings.set(messageFilterText, forKey: SettingsKey.messageFilterText.rawValue) }}
  public var mtuValue: Int { didSet { _settings.set(mtuValue, forKey: SettingsKey.mtuValue.rawValue) }}
  public var newLineBetweenMessages: Bool { didSet { _settings.set(newLineBetweenMessages, forKey: SettingsKey.newLineBetweenMessages.rawValue) }}
  public var radioObjectFilters: Set<String> { didSet { _settings.set(Array(radioObjectFilters), forKey: SettingsKey.radioObjectFilters.rawValue) }}
  public var remoteRxAudioCompressed: Bool { didSet { _settings.set(remoteRxAudioCompressed, forKey: SettingsKey.remoteRxAudioCompressed.rawValue) }}
  public var remoteRxAudioEnabled: Bool { didSet { _settings.set(remoteRxAudioEnabled, forKey: SettingsKey.remoteRxAudioEnabled.rawValue) }}
  public var remoteTxAudioCompressed: Bool { didSet { _settings.set(remoteTxAudioCompressed, forKey: SettingsKey.remoteTxAudioCompressed.rawValue) }}
  public var remoteTxAudioEnabled: Bool { didSet { _settings.set(remoteTxAudioEnabled, forKey: SettingsKey.remoteTxAudioEnabled.rawValue) }}
  public var showPings: Bool { didSet { _settings.set(showPings, forKey: SettingsKey.showPings.rawValue) }}
  public var showReplies: Bool { didSet { _settings.set(showReplies, forKey: SettingsKey.showReplies.rawValue) }}
  public var showTimes: Bool { didSet { _settings.set(showTimes, forKey: SettingsKey.showTimes.rawValue) }}
  public var smartlinkEnabled: Bool { didSet { _settings.set(smartlinkEnabled, forKey: SettingsKey.smartlinkEnabled.rawValue) }}
  public var smartlinkLoginRequired: Bool { didSet { _settings.set(smartlinkLoginRequired, forKey: SettingsKey.smartlinkLoginRequired.rawValue) }}
  public var smartlinkRefreshToken: String? { didSet { _settings.set(smartlinkRefreshToken, forKey: SettingsKey.smartlinkRefreshToken.rawValue) }}
  public var smartlinkUser: String { didSet { _settings.set(smartlinkUser, forKey: SettingsKey.smartlinkUser.rawValue) }}
  public var stationName: String { didSet { _settings.set(stationName, forKey: SettingsKey.stationName.rawValue) }}
  public var stationObjectFilters: Set<String> { didSet { _settings.set(Array(stationObjectFilters), forKey: SettingsKey.stationObjectFilters.rawValue) }}
  public var useDefaultEnabled: Bool { didSet { _settings.set(useDefaultEnabled, forKey: SettingsKey.useDefaultEnabled.rawValue) }}
  public var viewMode: ViewMode { didSet { _settings.set(viewMode.rawValue, forKey: SettingsKey.viewMode.rawValue) }}

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private let _settings: UserDefaults
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  // write values to UserDefaults
  // Note: This explicit save() method is likely redundant if all properties persist in didSet,
  // but it is retained here for compatibility.
  public func save() {
    _settings.set(alertOnError, forKey: SettingsKey.alertOnError.rawValue)
    _settings.set(alertOnWarning, forKey: SettingsKey.alertOnWarning.rawValue)
    _settings.set(clearOnSend, forKey: SettingsKey.clearOnSend.rawValue)
    _settings.set(clearOnStart, forKey: SettingsKey.clearOnStart.rawValue)
    _settings.set(clearOnStop, forKey: SettingsKey.clearOnStop.rawValue)
    _settings.set(commandsArray, forKey: SettingsKey.commandsArray.rawValue)
    _settings.set(commandsIndex, forKey: SettingsKey.commandsIndex.rawValue)
    _settings.set(commandToSend, forKey: SettingsKey.commandToSend.rawValue)
    _settings.set(daxSelection.rawValue, forKey: SettingsKey.daxSelection.rawValue)
    _settings.setStruct(defaultGui, forKey: SettingsKey.defaultGui.rawValue)
    _settings.setStruct(defaultNonGui, forKey: SettingsKey.defaultNonGui.rawValue)
    _settings.set(directEnabled, forKey: SettingsKey.directEnabled.rawValue)
    _settings.set(discoveryDisplayType.rawValue, forKey: SettingsKey.discoveryDisplayType.rawValue)
    _settings.set(discoveryPort, forKey: SettingsKey.discoveryPort.rawValue)
    _settings.set(fontSize, forKey: SettingsKey.fontSize.rawValue)
    _settings.set(gotoBottom, forKey: SettingsKey.gotoBottom.rawValue)
    _settings.set(guiClientId, forKey: SettingsKey.guiClientId.rawValue)
    _settings.set(ignoreGps, forKey: SettingsKey.ignoreGps.rawValue)
    _settings.set(isGui, forKey: SettingsKey.isGui.rawValue)
    _settings.set(localEnabled, forKey: SettingsKey.localEnabled.rawValue)
    _settings.set(lowBandwidthConnect, forKey: SettingsKey.lowBandwidthConnect.rawValue)
    _settings.set(lowBandwidthDax, forKey: SettingsKey.lowBandwidthDax.rawValue)
    _settings.set(messageFilter.rawValue, forKey: SettingsKey.messageFilter.rawValue)
    _settings.set(messageFilterText, forKey: SettingsKey.messageFilterText.rawValue)
    _settings.set(mtuValue, forKey: SettingsKey.mtuValue.rawValue)
    _settings.set(newLineBetweenMessages, forKey: SettingsKey.newLineBetweenMessages.rawValue)
    _settings.set(Array(radioObjectFilters), forKey: SettingsKey.radioObjectFilters.rawValue)
    _settings.set(remoteRxAudioCompressed, forKey: SettingsKey.remoteRxAudioCompressed.rawValue)
    _settings.set(remoteRxAudioEnabled, forKey: SettingsKey.remoteRxAudioEnabled.rawValue)
    _settings.set(remoteTxAudioCompressed, forKey: SettingsKey.remoteTxAudioCompressed.rawValue)
    _settings.set(remoteTxAudioEnabled, forKey: SettingsKey.remoteTxAudioEnabled.rawValue)
    _settings.set(showPings, forKey: SettingsKey.showPings.rawValue)
    _settings.set(showReplies, forKey: SettingsKey.showReplies.rawValue)
    _settings.set(showTimes, forKey: SettingsKey.showTimes.rawValue)
    _settings.set(smartlinkEnabled, forKey: SettingsKey.smartlinkEnabled.rawValue)
    _settings.set(smartlinkLoginRequired, forKey: SettingsKey.smartlinkLoginRequired.rawValue)
    _settings.set(smartlinkRefreshToken, forKey: SettingsKey.smartlinkRefreshToken.rawValue)
    _settings.set(smartlinkUser, forKey: SettingsKey.smartlinkUser.rawValue)
    _settings.set(stationName, forKey: SettingsKey.stationName.rawValue)
    _settings.set(Array(stationObjectFilters), forKey: SettingsKey.stationObjectFilters.rawValue)
    _settings.set(useDefaultEnabled, forKey: SettingsKey.useDefaultEnabled.rawValue)
    _settings.set(viewMode.rawValue, forKey: SettingsKey.viewMode.rawValue)
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
