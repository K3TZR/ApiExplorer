//
//  ReplyProcessor.swift
//
//
//  Created by Douglas Adams on 5/19/24.
//

import Foundation

public typealias ReplyHandler = @MainActor @Sendable (String, String) -> Void

public struct ReplyEntry: Sendable {
  public let command: String
  public let replyHandler: ReplyHandler?
  
  public init(_ command: String, _ replyHandler: ReplyHandler? = nil) {
    self.command = command
    self.replyHandler = replyHandler
  }
}



final public actor ReplyDictionary {
  private var replyEntries = [Int: ReplyEntry]()
  
  public func add(_ sequenceNumber: Int, _ replyEntry: ReplyEntry) {
    replyEntries[sequenceNumber] = replyEntry
  }
  
  public func remove(_ sequenceNumber: Int) {
      replyEntries.removeValue(forKey: sequenceNumber)
  }

  public func removeAll() {
      replyEntries.removeAll()
  }

  subscript(sequenceNumber: Int) -> ReplyEntry? {
    get { replyEntries[sequenceNumber] }
    set { replyEntries[sequenceNumber] = newValue }
  }
}



final public actor Sequencer {
  private var sequenceNumber: Int = 0
  
  public func next() -> Int {
    sequenceNumber += 1
    return sequenceNumber
  }
  
  public func reset() {
    sequenceNumber = 0
  }
}
