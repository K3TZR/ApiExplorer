//
//  Protocols.swift
//  SharedFeatures/Shared
//
//  Created by Douglas Adams on 11/29/22.
//

import Foundation

public protocol TcpProcessor: AnyObject {
  func tcpProcessor(_ text: String , isInput: Bool)
}

/// UDP Stream handler protocol
public protocol StreamHandler: AnyObject {
  /// Process a frame of Stream data
  /// - Parameter frame:        a frame of data
  func streamHandler<T>(_ frame: T)
}

/// UDP AudioStream handler protocol
public protocol AudioStreamHandler: AnyObject {
  /// Process a frame of Audio data
  /// - Parameters:
  ///   - buffer: the data
  ///   - samples: sample count
  func sendAudio(buffer: [UInt8], samples: Int)
}


/// UDP Stream handler protocol
public protocol DaxAudioOutputHandler: AnyObject {
  /// Process Stream data
  /// - Parameters:
  ///   - payload: array of bytes
  ///   - reducedBW: Float32(false) vs Int16(true) element size
  func daxAudioOutputHandler(payload: [UInt8], reducedBW: Bool)
}
  
/// UDP Stream handler protocol
public protocol DaxAudioInputHandler: AnyObject {
  /// Process Stream data
  /// - Parameters:
  ///   - payload: array of bytes
  ///   - reducedBW: Float32(false) vs Int16(true) element size
  func daxAudioInputHandler(payload: [UInt8], reducedBW: Bool)
}
