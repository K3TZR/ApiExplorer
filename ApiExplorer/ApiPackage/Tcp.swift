//
//  TcpCommand.swift
//  FlexApiFeature/Tcp
//
//  Created by Douglas Adams on 12/24/21.
//

import CocoaAsyncSocket
import Foundation

//import SharedFeature

// ----------------------------------------------------------------------------
// MARK: - Public structs and enums

public enum TcpStatusType {
  case didConnect
  case didSecure
  case didDisconnect
}

public struct TcpStatus: Identifiable, Equatable {
  public static func == (lhs: TcpStatus, rhs: TcpStatus) -> Bool {
    lhs.id == rhs.id
  }
  
  public init(_ statusType: TcpStatusType, host: String, port: UInt16, error: Error? = nil, reason: String? = nil) {
    self.statusType = statusType
    self.host = host
    self.port = port
    self.error = error
    self.reason = reason
  }
  
  public var id = UUID()
  public var statusType: TcpStatusType = .didDisconnect
  public var host = ""
  public var port: UInt16 = 0
  public var error: Error?
  public var reason: String?
}

///  Tcp Command Class implementation
///      manages all Tcp communication with a Radio
public final class Tcp: NSObject {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(delegate: TcpProcessor, timeout: Double = 0.5) {
    _delegate = delegate
    _timeout = timeout
    super.init()
    
    // get a socket & set it's parameters
    _socket = GCDAsyncSocket(delegate: self, delegateQueue: _receiveQ)
    _socket.isIPv4PreferredOverIPv6 = true
    _socket.isIPv6Enabled = false
    
    log.debug("Tcp: socket initialized")
  }
  // ----------------------------------------------------------------------------
  // MARK: - Public properties

  public private(set) var interfaceIpAddress = "0.0.0.0"
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties

  private var _delegate: TcpProcessor
  private var _isWan: Bool = false
  private let _receiveQ = DispatchQueue(label: "TcpStream.receiveQ")
  private var _socket: GCDAsyncSocket!
  private var _timeout = 0.0   // seconds
  private var _startTime: Date?
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  /// Attempt to connect to a Radio
  /// - Parameters:
  ///   - packet:                 a DiscoveryPacket
  /// - Returns:                  success / failure
  public func connect(_ isWan: Bool, _ requiresHolePunch: Bool, _ holePunchPort: Int, _ publicTlsPort: Int?, _ port: Int, _ publicIp: String, _ localInterfaceIP: String) -> Bool {
    var portToUse = 0
    var localInterface: String?
    var success = true

    _isWan = isWan
    
    // identify the port
    switch (isWan, requiresHolePunch) {
      
    case (true, true):  portToUse = holePunchPort
    case (true, false): portToUse = publicTlsPort!
    default:            portToUse = port
    }
    // attempt a connection
    do {
      if isWan && requiresHolePunch {
        // insure that the localInterfaceIp has been specified
        guard localInterfaceIP != "0.0.0.0" else { return false }
        // create the localInterfaceIp value
        localInterface = localInterfaceIP + ":" + String(portToUse)
        
        // connect via the localInterface
        try _socket.connect(toHost: publicIp, onPort: UInt16(portToUse), viaInterface: localInterface, withTimeout: _timeout)
        log.debug("Tcp: connect on the \(String(describing: localInterface)) interface to \(publicIp) port \(portToUse)")

      } else {
        // connect on the default interface
        try _socket.connect(toHost: publicIp, onPort: UInt16(portToUse), withTimeout: _timeout)
        log.debug("Tcp: connect on the default interface to \(publicIp) port \(portToUse)")
      }
      
    } catch _ {
      // connection attemp failed
      log.debug("Tcp: connection failed")
      success = false
    }
    if success {
      log.debug("Tcp: connection successful")
    }
    return success
  }
  
  /// Disconnect TCP from the Radio (hardware)
  public func disconnect() {
    _socket.disconnect()
    _startTime = nil
  }
  
  /// Send a Command to the connected Radio
  /// - Parameters:
  ///   - cmd:            a Command string
  ///   - diagnostic:     whether to add "D" suffix
  /// - Returns:          the Sequence Number of the Command
  public func send(_ command: String, _ sequenceNumber: Int) {
    _socket.write(command.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withTimeout: -1, tag: sequenceNumber)
  }
}



// ----------------------------------------------------------------------------
// MARK: - GCDAsyncSocketDelegate

extension Tcp: GCDAsyncSocketDelegate {
  
  /// Receive a command
  /// - Parameters:
  ///   - sock: the connected socket
  ///   - data: the data received
  ///   - tag: the tag on the received data
  public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
    // remove the EOL
    if let text = String(data: data, encoding: .ascii)?.dropLast() {
      let delegate = _delegate
      delegate.tcpProcessor( String(text), isInput: true )
    }
    // trigger the next read
    _socket.readData(to: GCDAsyncSocket.lfData(), withTimeout: -1, tag: 0)
  }
  
  /// TLS did secure
  /// - Parameter sock: the connected socket
  public func socketDidSecure(_ sock: GCDAsyncSocket) {
    // TLS connection complete
    _socket.readData(to: GCDAsyncSocket.lfData(), withTimeout: -1, tag: 0)
//    _statusStream( TcpStatus(.didSecure,
//                            host: sock.connectedHost ?? "",
//                            port: sock.connectedPort,
//                            error: nil))
  }
  
  /// TLS did receive trust
  /// - Parameters:
  ///   - sock: the connected socket
  ///   - trust: a SecTrust class
  ///   - completionHandler: a completion handler
  public func socket(_ sock: GCDAsyncSocket, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
    // no validation required
    log.debug("Tcp: TLS socket did receive trust")
    completionHandler(true)
  }
  
  /// TCP did disconnect
  /// - Parameters:
  ///   - sock: the connected socket
  ///   - err: an error (if any)
  public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
//    _statusStream( TcpStatus(.didDisconnect, host: "", port: 0, error: err) )
  }
  
  /// TCP did connect
  /// - Parameters:
  ///   - sock: the socket
  ///   - host: the host
  ///   - port: the port
  public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
    // Connected
    interfaceIpAddress = host
    
    // is this a Wan connection?
    if _isWan {
      // YES, secure the connection using TLS
      sock.startTLS( [GCDAsyncSocketManuallyEvaluateTrust : 1 as NSObject] )

    } else {
      // NO, we're connected
//      _statusStream( TcpStatus(.didConnect, host: host, port: port, error: nil) )
      // trigger the next read
      _socket.readData(to: GCDAsyncSocket.lfData(), withTimeout: -1, tag: 0)
    }
  }
}
