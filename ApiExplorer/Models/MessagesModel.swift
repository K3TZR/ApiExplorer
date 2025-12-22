//
//  MessagesModel.swift
//  SDRApi
//
//  Created by Douglas Adams on 10/07/24.
//

import Foundation
import SwiftUI
import Observation

import ApiPackage

/// A MainActor-isolated model that collects TCP messages, filters them, and formats them for display or export.
@MainActor
@Observable
public final class MessagesModel: TcpProcessor {
  
  public init(_ settings: SettingsModel) {
    _settings = settings
    // Automatically re-filter when relevant settings change
    withObservationTracking({
      // Track the properties that affect filtering
      _ = _settings.messageFilter
      _ = _settings.messageFilterText
      _ = _settings.showReplies
      _ = _settings.ignoreGps
      _ = _settings.showPings
    }, onChange: { [weak self] in
      Task { @MainActor [weak self] in
        guard let self else { return }
        self.reFilter()
      }
    })
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

  private var allMessages = [TcpMessage]()
  private let _settings: SettingsModel
  private var _startTime: Date?

  private var intervalFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.minimumFractionDigits = 6
    f.positiveFormat = " * ##0.000000"
    return f
  }()

  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Clears the current filtered view of messages without modifying the stored message history.
  public func clear() {
    removeAllFilteredMessages()
  }

  /// Returns a newline-separated string of the filtered messages with formatted time intervals for exporting or saving.
  public func formattedMessagesText() -> String {
    let textArray = filteredMessages.compactMap { msg -> String? in
      guard let formattedInterval = intervalFormatter.string(from: NSNumber(value: msg.interval)) else { return nil }
      return formattedInterval + " " + msg.text
    }
    return textArray.joined(separator: "\n")
  }

  /// Rebuilds the filteredMessages array from the full message history using the current filter settings. This is the single source of truth for the filtered view.
  public func reFilter() {
    filteredMessages = allMessages.filter { passesCurrentFilter($0) }
  }

  public func removePings() {
    allMessages.removeAll { $0.text.contains("|ping") }
    reFilter()
  }
  
  /// Starts message capture and interval timing. Optionally clears the filtered view.
  public func start(_ clearOnStart: Bool) {
    _startTime = Date()
    if clearOnStart {
      clear()
    }
  }
    
  /// Stops message capture. Optionally clears the filtered view.
  public func stop(_ clearOnStop: Bool) {
    _startTime = nil
    if clearOnStop {
      clear()
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Nonisolated public method
  
  /// Processes an incoming or outgoing TCP line. Safe to call from background threads; work is marshaled to the MainActor.
  nonisolated public func tcpProcessor(_ text: String, isInput: Bool) {
    Task { @MainActor in
      let timeStamp = Date()
      
      if let startTime = _startTime {
        // Snapshot settings to avoid accessing MainActor-isolated properties from nonisolated contexts
        let showReplies = _settings.showReplies
        let ignoreGps = _settings.ignoreGps
        let showPings = _settings.showPings

        // Ignore routine replies: 'R|<error>|<data>' where error == "0" and data is empty
        func ignoreReply(_ text: String) -> Bool {
          if text.first == "R" && showReplies { return false } // explicitly showing all replies
          guard text.first == "R" else { return false } // not a reply
          let parts = text.split(separator: "|", omittingEmptySubsequences: false)
          guard parts.count >= 3 else { return false } // incomplete
          let errorField = parts[1]
          let dataField = parts[2]
          return errorField == "0" && dataField.isEmpty
        }

        // ignore received replies unless they are non-zero or contain additional data
        if isInput && ignoreReply(text) { return }
        // ignore received gps messages unless ignoreGps is false
        if isInput && text.prefix(6) == "S0|gps" && ignoreGps { return }
        // ignore sent "ping" messages unless showPings is true
        if text.contains("ping") && showPings == false { return }
        
        let msg = TcpMessage(text: text, isInput: isInput, timeStamp: timeStamp, interval: timeStamp.timeIntervalSince(startTime))
        
        // add it to the backing collection
        allMessages.append(msg)
        
        // update filtered view based on current settings
        reFilter()
      }
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private methods

  private func passesCurrentFilter(_ msg: TcpMessage) -> Bool {
    let text = msg.text
    let filterText = _settings.messageFilterText

    switch _settings.messageFilter {
    case .all:
      return true

    case .prefix:
      // Empty prefix shows all
      guard !filterText.isEmpty else { return true }
      // Allow user to specify with or without leading pipe
      let normalized = filterText.hasPrefix("|") ? String(filterText.dropFirst()) : filterText
      return text.localizedCaseInsensitiveContains("|" + normalized)

    case .includes:
      guard !filterText.isEmpty else { return true }
      return text.range(of: filterText, options: [.caseInsensitive]) != nil

    case .excludes:
      guard !filterText.isEmpty else { return true }
      return text.range(of: filterText, options: [.caseInsensitive]) == nil

    case .command:
      return text.hasPrefix("C")

    case .S0:
      return text.hasPrefix("S0|")

    case .status:
      // Status messages start with 'S' but exclude S0 (which is handled above)
      return text.hasPrefix("S") && !text.hasPrefix("S0|")

    case .reply:
      return text.hasPrefix("R")
    }
  }
  
  private func removeAllFilteredMessages() {
    filteredMessages.removeAll()
  }
}

