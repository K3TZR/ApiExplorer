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
  
  public init(_ settings: SettingsModel) {
    _settings = settings
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public private(set) var filteredMessages = [TcpMessage]()
  
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
  private let _settings: SettingsModel
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
    
    let textArray = filteredMessages.compactMap { msg -> String? in
      guard let formattedInterval = formatter.string(from: NSNumber(value: msg.interval)) else { return nil }
      return formattedInterval + " " + msg.text
    }
    return textArray.joined(separator: "\n")
  }

  /// Rebuild the entire filteredMessages array
  public func reFilter() {
    filteredMessages = _messages.filter { passesCurrentFilter($0) }
  }

  public func removePings() {
    _messages.removeAll { $0.text.contains("|ping") }
    reFilter()
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
        // ignore received gps messages unless ignoreGps is false
        if isInput && text.prefix(6) == "S0|gps" && _settings.ignoreGps { return }
        // ignore sent "ping" messages unless showPings is true
        if text.contains("ping") && _settings.showPings == false { return }
        
        let msg = TcpMessage(text: String(text), isInput: isInput, timeStamp: timeStamp, interval: timeStamp.timeIntervalSince(startTime))
        
        // add it to the backing collection
        _messages.append(msg)
        
        // add it to the public collection (if appropriate)
        if passesCurrentFilter(msg) {
          filteredMessages.append(msg)
        }
      }
    }}
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods

  private func passesCurrentFilter(_ msg: TcpMessage) -> Bool {
    switch (_settings.messageFilter, _settings.messageFilterText) {
    case (.all, _):
      return true
    case (.prefix, ""):
      return true
    case (.prefix, let filterText):
      return msg.text.localizedCaseInsensitiveContains("|" + filterText)
    case (.includes, let filterText):
      return msg.text.localizedCaseInsensitiveContains(filterText)
    case (.excludes, ""):
      return true
    case (.excludes, let filterText):
      return !msg.text.localizedCaseInsensitiveContains(filterText)
    case (.command, _):
      return msg.text.hasPrefix("C")
    case (.S0, _):
      return msg.text.hasPrefix("S0|")
    case (.status, _):
      return msg.text.hasPrefix("S") && !msg.text.hasPrefix("S0|")
    case (.reply, _):
      return msg.text.hasPrefix("R")
    }
  }
  
  private func removeAllFilteredMessages() {
    filteredMessages.removeAll()
  }
}
