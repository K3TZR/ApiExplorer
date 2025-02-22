//
//  LocalListener.swift
//  ApiPackage
//
//  Created by Douglas Adams on 10/28/21
//  Copyright © 2021 Douglas Adams. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

/// Listener implementation
///
///      listens for the udp broadcasts of a Flex6000 Radio
///
@MainActor
public final class ListenerLocal: NSObject, ObservableObject {
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  nonisolated private let _objectModel: ObjectModel
  
  private var _checkTimer: DispatchSourceTimer?
  private let _formatter = DateFormatter()
  private let _timerQ = DispatchQueue(label: "ListenerLocal" + ".timerQ", attributes: .concurrent)
  private let _udpQ = DispatchQueue(label: "ListenerLocal" + ".udpQ")
  private var _udpSocket: GCDAsyncUdpSocket!
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  init(_ objectModel: ObjectModel, port: UInt16 = 4992) {
    _objectModel = objectModel
    super.init()
    
    _formatter.timeZone = .current
    _formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    // create a Udp socket and set options
    _udpSocket = GCDAsyncUdpSocket( delegate: self, delegateQueue: _udpQ )
    _udpSocket.setPreferIPv4()
    _udpSocket.setIPv6Enabled(false)
    
    try! _udpSocket.enableReusePort(true)
    try! _udpSocket.bind(toPort: port)
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Internal methods
  
  func start(checkInterval: Int = 1, timeout: TimeInterval = 20.0) {
    do {
      try _udpSocket.beginReceiving()
      log.info("Local Listener: STARTED")
    } catch {
      log.error("Error starting UDP socket: \(error)")
      return
    }
    
    // Create the timer’s dispatch source
    _checkTimer = DispatchSource.makeTimerSource(queue: _timerQ)
    
    // Setup the timer
    _checkTimer?.schedule(deadline: .now(), repeating: .seconds(checkInterval))
    
    // Set the event handler
    _checkTimer?.setEventHandler  { [weak self] in
      guard let self = self else { return }
      
      Task { await MainActor.run {
        self._objectModel.removeLostRadios(Date(), timeout)
      }}
    }
    
    // Start the timer
    _checkTimer?.resume()
  }
  
  func stop() {
    _checkTimer?.cancel()
    _checkTimer = nil
    _udpSocket?.close()
    log.info("Local Listener: STOPPED")
  }
}

// ----------------------------------------------------------------------------
// MARK: - GCDAsyncUdpSocketDelegate extension

extension ListenerLocal: GCDAsyncUdpSocketDelegate {
  /// The Socket received data
  ///
  /// - Parameters:
  ///   - sock:           the GCDAsyncUdpSocket
  ///   - data:           the Data received
  ///   - address:        the Address of the sender
  ///   - filterContext:  the FilterContext
  nonisolated public func udpSocket(_ sock: GCDAsyncUdpSocket,
                                    didReceive data: Data,
                                    fromAddress address: Data,
                                    withFilterContext filterContext: Any?) {
    
    // is it a VITA packet?
    guard let vita = Vita.decode(from: data) else { return }
    
    // YES, is it a Discovery Packet?
    if vita.classIdPresent && vita.classCode == .discovery {
      // YES, Payload is a series of strings of the form <key=value> separated by ' ' (space)
      let payloadString = NSString(bytes: vita.payloadData, length: vita.payloadSize, encoding: String.Encoding.utf8.rawValue)! as String
      // eliminate any Nulls at the end of the payload & form KeyValuesArray
      let properties = payloadString.trimmingCharacters(in: CharacterSet(charactersIn: "\0")).keyValuesArray()
      
      // process it
      Task { await self._objectModel.process(.local, properties, data) }
    }
  }
}
