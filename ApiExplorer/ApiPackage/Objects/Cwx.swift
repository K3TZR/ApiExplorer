//
//  Cwx.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 6/30/15.
//  Copyright © 2015 Douglas Adams. All rights reserved.
//

import Foundation

//import SharedFeature


// Cwx
//      creates a Cwx instance to be used by a Client to support the
//      rendering of a Cwx. Cwx objects are added, removed and updated
//      by the incoming TCP messages.
//
//@MainActor
@Observable
public final class Cwx {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization

  public init() {
    macros = [String](repeating: "", count: kMaxNumberOfMacros)
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public internal(set) var breakInDelay = 0
  public internal(set) var qskEnabled = false
  public internal(set) var wpm = 0
  
  public var charSentEventHandler: ((_ index: Int) -> Void)?
  public var eraseSentEventHandler: ((_ start: Int, _ stop: Int) -> Void)?
  public var messageQueuedEventHandler: ((_ sequence: Int, _ bufferIndex: Int) -> Void)?

  public enum Property: String {
    case breakInDelay   = "break_in_delay"
    case qskEnabled     = "qsk_enabled"
    case erase
    case sent
    case wpm            = "wpm"
  }

  // ------------------------------------------------------------------------------
  // MARK: - Internal properties
  
  var macros: [String]
  let kMaxNumberOfMacros = 12

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _initialized = false

  // ----------------------------------------------------------------------------
  // MARK: - Public Static command methods
  
  /*
   "cwx macro save " + (index + 1) + " \"" + msg + “\""
   "cwx send \"" + msg + “\""
   "cwx erase " + num_chars
   "cwx erase " + num_chars + " " + radio_index
   "cwx clear”
   "cwx delay " + _delay
   "cwx wpm " + _speed
   "cwx qsk_enabled " + (_qskEnabled ? "1" : “0")
   */
  
  // TODO:

  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Parse Cwx key/value pairs, called by Radio
  ///   PropertiesParser protocol method, executes on the parseQ
  ///
  /// - Parameter properties:       a KeyValuesArray
  ///
  public func parse(_ properties: KeyValuesArray) {
    // process each key/value pair, <key=value>
    for property in properties {
      // is it a Macro?
      if property.key.hasPrefix("macro") && property.key.lengthOfBytes(using: String.Encoding.ascii) > 5 {
        
        // YES, get the index
        let oIndex = property.key.firstIndex(of: "o")!
        let numberIndex = property.key.index(after: oIndex)
        let index = Int( property.key[numberIndex...] ) ?? 0
        
        // ignore invalid indexes
        if index < 1 || index > kMaxNumberOfMacros { continue }
        
        // update the macro after "unFixing" the string
        macros[index - 1] = property.value.unfix()
        
      } else {
        // Check for Unknown Keys
        guard let token = Property(rawValue: property.key) else {
          // log it and ignore the Key
          log.warning("Cwx: unknown property, \(property.key) = \(property.value)")
          return
        }
        // Known tokens, in alphabetical order
        switch token {
          
        case .erase:
          let values = property.value.components(separatedBy: ",")
          if values.count != 2 { break }
          let start = Int(values[0])
          let stop = Int(values[1])
          if let start = start, let stop = stop {
            // inform the Event Handler (if any)
            eraseSentEventHandler?(start, stop)
          }
        case .breakInDelay: breakInDelay = property.value.iValue
        case .qskEnabled:   qskEnabled = property.value.bValue
        case .wpm:          wpm = property.value.iValue
          
        case .sent:         charSentEventHandler?(property.value.iValue)
        }
      }
      // is it initialized?
      if _initialized == false{
        // NO, it is now
        _initialized = true
        log.debug("Cwx: initialized")
      }
    }
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Internal methods
  
  /// Process a Cwx command reply
  /// - Parameters:
  ///   - command:        the original command
  ///   - seqNum:         the Sequence Number of the original command
  ///   - responseValue:  the response value
  ///   - reply:          the reply
  ///
  func replyHandler(_ command: String, seqNum: UInt, responseValue: String, reply: String) {
    
    // if a block was specified for the "cwx send" command the response is "charPos,block"
    // if no block was given the response is "charPos"
    let values = reply.components(separatedBy: ",")
    
    let components = values.count
    
    // if zero or anything greater than 2 it's an error, log it and ignore the Reply
    guard components == 1 || components == 2 else {
      log.warning("Cwx, Invalid reply: to \(command)")
      return
    }
    // get the character position
    let charPos = Int(values[0])
    
    // if not an integer, log it and ignore the Reply
    guard charPos != nil else {
      log.warning("Cwx, Invalid character position: for \(command)")
      return
    }
    
    if components == 1 {
      // 1 component - no block number
      
      // inform the Event Handler (if any), use 0 as a block identifier
      messageQueuedEventHandler?(charPos!, 0)
      
    } else {
      // 2 components - get the block number
      let block = Int(values[1])
      
      // not an integer, log it and ignore the Reply
      guard block != nil else {
        
        log.warning("Cwx, Invalid block: for \(command)")
        return
      }
      // inform the Event Handler (if any)
      messageQueuedEventHandler?(charPos!, block!)
    }
  }
  
  // ------------------------------------------------------------------------------
  // MARK: - Public Command methods
  
  /// Get the specified Cwx Macro
  ///     NOTE:
  ///         Macros are numbered 0..<kMaxNumberOfMacros internally
  ///         Macros are numbered 1...kMaxNumberOfMacros in commands
  ///
  /// - Parameters:
  ///   - index:              the index of the macro
  ///   - macro:              on return, contains the text of the macro
  /// - Returns:              true if found, false otherwise
  ///
  public func getMacro(index: Int, macro: inout String) -> Bool {
    if index < 0 || index > kMaxNumberOfMacros - 1 { return false }
    
    macro = macros[index]
    return true
  }
  
  /// Clear the character buffer
  //    public func clearBuffer() {
  //        _api.send("cwx " + "clear")
  //    }
  
  /// Erase "n" characters
  /// - Parameter numberOfChars:  number of characters to erase
  ///
  //    public func erase(numberOfChars: Int) {
  //        _api.send("cwx " + "erase \(numberOfChars)")
  //    }
  
  /// Erase "n" characters
  /// - Parameters:
  ///   - numberOfChars:          number of characters to erase
  ///   - radioIndex:             ???
  ///
  //    public func erase(numberOfChars: Int, radioIndex: Int) {
  //        _api.send("cwx " + "erase \(numberOfChars)" + " \(radioIndex)")
  //    }
  
  /// Insert a string of Cw, optionally with a block
  /// - Parameters:
  ///   - string:                 the text to insert
  ///   - index:                  the index at which to insert the messagek
  ///   - block:                  an optional block
  ///
  //    public func insert(_ string: String, index: Int, block: Int? = nil) {
  //        // replace spaces with 0x7f
  //        let msg = String(string.map { $0 == " " ? "\u{7f}" : $0 })
  //
  //        if let block = block {
  //            _api.send("cwx insert " + "\(index) \"" + msg + "\" \(block)", replyTo: replyHandler)
  //
  //        } else {
  //            _api.send("cwx insert " + "\(index) \"" + msg + "\"", replyTo: replyHandler)
  //        }
  //    }
  
  /// Save the specified Cwx Macro and tell the Radio (hardware)
  ///     NOTE:
  ///         Macros are numbered 0..<kMaxNumberOfMacros internally
  ///         Macros are numbered 1...kMaxNumberOfMacros in commands
  ///
  /// - Parameters:
  ///   - index:              the index of the macro
  ///   - msg:                the text of the macro
  /// - Returns:              true if found, false otherwise
  ///
  //    public func saveMacro(index: Int, msg: String) -> Bool {
  //        if index < 0 || index > kMaxNumberOfMacros - 1 { return false }
  //
  //        macros[index] = msg
  //        _api.send("cwx macro " + "save \(index+1)" + " \"" + msg + "\"")
  //
  //        return true
  //    }
  
  /// Send a string of Cw, optionally with a block
  /// - Parameters:
  ///   - string:         the text to send
  ///   - block:          an optional block
  ///
  //    public func send(_ string: String, block: Int? = nil) {
  //        // replace spaces with 0x7f
  //        let msg = String(string.map { $0 == " " ? "\u{7f}" : $0 })
  //
  //        if let block = block {
  //            _api.send("cwx send " + "\"" + msg + "\" \(block)", replyTo: replyHandler)
  //
  //        } else {
  //            _api.send("cwx send " + "\"" + msg + "\"", replyTo: replyHandler)
  //        }
  //    }
  
  /// Send the specified Cwx Macro
  /// - Parameters:
  ///   - index: the index of the macro
  ///   - block: an optional block ( > 0)
  ///
  //    public func sendMacro(index: Int, block: Int? = nil) {
  //        if index < 0 || index > kMaxNumberOfMacros { return }
  //
  //        if let block = block {
  //            _api.send("cwx macro " + "send \(index) \(block)", replyTo: replyHandler)
  //
  //        } else {
  //            _api.send("cwx macro " + "send \(index)", replyTo: replyHandler)
  //        }
  //    }
}
