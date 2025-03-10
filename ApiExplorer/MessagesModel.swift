//
//  MessagesModel.swift
//  SDRApi
//
//  Created by Douglas Adams on 10/07/24.
//

import Foundation
import SwiftUI

import ApiPackage

@MainActor
@Observable
public final class MessagesModel: TcpProcessor {
  
  public init() {}

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var filteredMessages = [TcpMessage]()
  
  public enum Filter: String, Codable, CaseIterable, Sendable {
    case all
    case prefix
    case includes
    case excludes
    case command
    case status
    case reply
    case S0
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties

  private var _messages = [TcpMessage]()
  private var _settings = SettingsModel.shared
  private var _startTime: Date?

  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func clearButtonTapped() {
    removeAllFilteredMessages()
  }

  // prepare text array to be used for the Save function
  public func messagesText() -> String {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 6
    formatter.positiveFormat = " * ##0.000000"
    
    let textArray = filteredMessages.map { formatter.string(from: NSNumber(value: $0.interval))! + " " + $0.text }
    return textArray.joined(separator: "\n")
  }

 /// Rebuild the entire filteredMessages array
  public func reFilter() {
    
    // re-filter the entire messages array
    switch (_settings.messageFilter, _settings.messageFilterText) {

    case (.all, _):        filteredMessages = _messages
    case (.prefix, ""):    filteredMessages = _messages
    case (.prefix, _):     filteredMessages = _messages.filter { $0.text.localizedCaseInsensitiveContains("|" + _settings.messageFilterText) }
    case (.includes, _):   filteredMessages = _messages.filter { $0.text.localizedCaseInsensitiveContains(_settings.messageFilterText) }
    case (.excludes, ""):  filteredMessages = _messages
    case (.excludes, _):   filteredMessages = _messages.filter { !$0.text.localizedCaseInsensitiveContains(_settings.messageFilterText) }
    case (.command, _):    filteredMessages = _messages.filter { $0.text.prefix(1) == "C" }
    case (.S0, _):         filteredMessages = _messages.filter { $0.text.prefix(3) == "S0|" }
    case (.status, _):     filteredMessages = _messages.filter { $0.text.prefix(1) == "S" && $0.text.prefix(3) != "S0|"}
    case (.reply, _):      filteredMessages = _messages.filter { $0.text.prefix(1) == "R" }
    }
  }

  public func start(_ clearOnStart: Bool) {
    _startTime = Date()
    if clearOnStart {
      clearButtonTapped()
    }
  }
    
  public func stop(_ clearOnStop: Bool) {
    _startTime = nil
    if clearOnStop {
      clearButtonTapped()
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Nonisolated public method
  
  /// Process a TcpMessage
  /// - Parameter msg: a TcpMessage struct
  nonisolated public func tcpProcessor(_ text: String, isInput: Bool) {
    Task { await MainActor.run {
      let timeStamp = Date()
      
      if let startTime = _startTime {
        // ignore routine replies (i.e. replies with no error or no attached data)
        @MainActor func ignoreReply(_ text: String) -> Bool {
          if text.first == "R" && _settings.showReplies { return false }      // showing all Replies (including ping replies)
          if text.first != "R" { return false }                     // not a Reply
          let parts = text.components(separatedBy: "|")
          if parts.count < 3 { return false }                       // incomplete
          if parts[1] != "0" { return false }                       // error of some type, "0" = no error
          if parts[2] != "" { return false }                        // additional data present
          return true                                               // otherwise, ignore it
        }
        
        // ignore received replies unless they are non-zero or contain additional data
        if isInput && ignoreReply(text) { return }
        // ignore sent "ping" messages unless showPings is true
        if text.contains("ping") && _settings.showPings == false { return }
        
        let msg = TcpMessage(text: String(text), isInput: isInput, timeStamp: timeStamp, interval: timeStamp.timeIntervalSince(startTime))
        
        // add it to the backing collection
        _messages.append(msg)
        
        // add it to the public collection (if appropriate)
        switch (_settings.messageFilter, _settings.messageFilterText) {

        case (.all, _):        filteredMessages.append(msg)
        case (.prefix, ""):    filteredMessages.append(msg)
        case (.prefix, _):     if msg.text.localizedCaseInsensitiveContains("|" + _settings.messageFilterText) { filteredMessages.append(msg) }
        case (.includes, _):   if msg.text.localizedCaseInsensitiveContains(_settings.messageFilterText) { filteredMessages.append(msg) }
        case (.excludes, ""):  filteredMessages.append(msg)
        case (.excludes, _):   if !msg.text.localizedCaseInsensitiveContains(_settings.messageFilterText) { filteredMessages.append(msg) }
        case (.command, _):    if msg.text.prefix(1) == "C" { filteredMessages.append(msg) }
        case (.S0, _):         if msg.text.prefix(3) == "S0|" { filteredMessages.append(msg) }
        case (.status, _):     if msg.text.prefix(1) == "S" && msg.text.prefix(3) != "S0|" { filteredMessages.append(msg) }
        case (.reply, _):      if msg.text.prefix(1) == "R" { filteredMessages.append(msg) }
        }
      }
    }}
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  private func removeAllFilteredMessages() {
    filteredMessages.removeAll()
  }
}
