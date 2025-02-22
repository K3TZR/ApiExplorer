//
//  SLListener.swift
//  ApiViewer
//
//  Created by Douglas Adams on 2/2/25.
//

import Foundation
import SwiftUI

import CocoaAsyncSocket
import JWTDecode

public enum ListenerError: String, Error {
  case wanConnect = "WanConnect Failed"
  case wanValidation = "WanValidation Failed"
}

/// Listener implementation
///
///      listens for the Smartlink messages of a Flex-6000 Radio
///
@MainActor
public final class ListenerSmartlink: NSObject, ObservableObject {
//  // ----------------------------------------------------------------------------
//  // MARK: - Public static constants
//  
//  public static let kTimeout: Double = 5.0

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _appName: String?
  private var _awaitWanHandle: CheckedContinuation<String, Error>?
  private var _callsign: String?
  private var _currentTokens: Tokens?
  private var _domain: String?
  private var _firstName: String?
  private var _host: String?
  private var _lastName: String?
  private let _objectModel: ObjectModel!
  private let _pingQ = DispatchQueue(label: "SmartlinkListener.pingQ")
  private var _pingTimer: DispatchSourceTimer!
  private var _platform: String?
  private var _previousIdToken: IdToken?
  private var _publicIp: String?
  private var _pwd: String?
  private var _serial: String?
  private var _smartlinkImage: Image?
  private let _socketQ = DispatchQueue(label: "WanListener.socketQ")
  private var _tcpSocket: GCDAsyncSocket!
  private var _timeout = 0.0                // seconds
  private var _user: String?
  private var _wanHandle: String?

  // ----------------------------------------------------------------------------
  // MARK: - Private constants
  
  private let kSmartlinkHost = "smartlink.flexradio.com"
  private let kSmartlinkPort: UInt16 = 443
  private let kPlatform = "macOS"

  private let kDomain             = "https://frtest.auth0.com/"
  private let kClientId           = "4Y9fEIIsVYyQo5u6jr7yBWc4lV5ugC2m"
  private let kServiceName        = ".oauth-token"
  
  private let kApplicationJson    = "application/json"
  private let kAuth0Authenticate  = "https://frtest.auth0.com/oauth/ro"
  private let kAuth0AuthenticateURL = URL(string: "https://frtest.auth0.com/oauth/ro")!
  
  private let kAuth0Delegation    = "https://frtest.auth0.com/delegation"
  private let kClaimEmail         = "email"
  private let kClaimPicture       = "picture"
  private let kGrantType          = "password"
  private let kGrantTypeRefresh   = "urn:ietf:params:oauth:grant-type:jwt-bearer"
  private let kHttpHeaderField    = "content-type"
  private let kHttpPost           = "POST"
  private let kConnection         = "Username-Password-Authentication"
  private let kDevice             = "any"
  private let kScope              = "openid offline_access email picture"
  
  private let kKeyClientId        = "client_id"       // dictionary keys
  private let kKeyConnection      = "connection"
  private let kKeyDevice          = "device"
  private let kKeyGrantType       = "grant_type"
  private let kKeyIdToken         = "id_token"
  private let kKeyPassword        = "password"
  private let kKeyRefreshToken    = "refresh_token"
  private let kKeyScope           = "scope"
  private let kKeyTarget          = "target"
  private let kKeyUserName        = "username"
  
  private let kDefaultPicture     = "person.fill"
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ objectModel: ObjectModel, timeout: Double = 5.0) {
    _objectModel = objectModel
    
    super.init()
    
    _appName = (Bundle.main.infoDictionary!["CFBundleName"] as! String)
    _timeout = timeout
    
    // get a socket & set it's parameters
    _tcpSocket = GCDAsyncSocket(delegate: self, delegateQueue: _socketQ)
    _tcpSocket.isIPv4PreferredOverIPv6 = true
    _tcpSocket.isIPv6Enabled = false
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public methods
  
  public func start() async {
    
    log.info("Smartlink Listener: STARTED")
  }
  
  /// Start listening given a User / Pwd
  /// - Parameters:
  ///   - user:           user value
  ///   - pwd:            user password
  func start(_ user: String, _ pwd: String) async -> Tokens? {
    if let tokens = await requestTokens(user: user, pwd: pwd) {
      log.debug("Smartlink Listener: IdToken obtained from login credentials")
      return connect(using: tokens)
    }
    log.debug("Smartlink Listener: Failed to obtain IdToken from login credentials")
    return nil
  }
  
  /// stop the listener
  public func stop() {
    _pingTimer?.cancel()
    _tcpSocket?.disconnect()
    log.info("Smartlink Listener: STOPPED")
  }
  
  /// Initiate a smartlink connection to a radio
  /// - Parameters:
  ///   - serialNumber:       the serial number of the Radio
  ///   - holePunchPort:      the negotiated Hole Punch port number
  /// - Returns:              a WanHandle
  public func smartlinkConnect(for serial: String, holePunchPort: Int) async throws -> String {
    
    return try await withCheckedThrowingContinuation{ continuation in
      _awaitWanHandle = continuation
      log.debug("Smartlink Listener: Connect sent to serial \(serial)")
      // send a command to SmartLink to request a connection to the specified Radio
      sendTlsCommand("application connect serial=\(serial) hole_punch_port=\(holePunchPort))")
    }
  }
  
  /// Disconnect a smartlink Radio
  /// - Parameter serialNumber:         the serial number of the Radio
  public func smartlinkDisconnect(for serial: String) {
    log.debug("Smartlink Listener: Disconnect sent to serial \(serial)")
    // send a command to SmartLink to request disconnection from the specified Radio
    sendTlsCommand("application disconnect_users serial=\(serial)")
  }
  
  /// Disconnect a single smartlink Client
  /// - Parameters:
  ///   - serialNumber:         the serial number of the Radio
  ///   - handle:               the handle of the Client
  public func smartlinkDisconnectClient(for serial: String, handle: UInt32) {
    log.debug("Smartlink Listener: Disconnect sent to serial \(serial), handle \(handle.hex)")
    // send a command to SmartLink to request disconnection from the specified Radio
    sendTlsCommand("application disconnect_users serial=\(serial) handle=\(handle.hex)")
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  private func connect(using tokens: Tokens) -> Tokens? {
    _currentTokens = tokens
    // use the ID Token to connect to the Smartlink service
    do {
      try _tcpSocket.connect(toHost: kSmartlinkHost, onPort: kSmartlinkPort, withTimeout: _timeout)
      log.debug("Smartlink Listener: TCP Socket connection initiated")
      return tokens

    } catch {
      log.debug("Smartlink Listener: TCP Socket connection FAILED")
      return nil
    }
  }

  /// Send a command to the server using TLS
  /// - Parameter cmd:                command text
  private func sendTlsCommand(_ cmd: String, timeout: TimeInterval = 5.0, tag: Int = 1) {
    // send the specified command to the SmartLink server using TLS
    let command = cmd + "\n"
    _tcpSocket.write(command.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withTimeout: timeout, tag: 0)
  }

  /// Ping the SmartLink server
  private func startPinging() {
    // create the timer's dispatch source
    _pingTimer = DispatchSource.makeTimerSource(queue: _pingQ)
    
    // Setup the timer
    _pingTimer.schedule(deadline: DispatchTime.now(), repeating: .seconds(10))
    
    // set the event handler
    _pingTimer.setEventHandler(handler: { [self] in
      // send another Ping
      sendTlsCommand("ping from client", timeout: -1)
    })
    // start the timer
    _pingTimer.resume()
    log.debug("Smartlink Listener: STARTED pinging \(self._host ?? "????")")
  }
}

// ----------------------------------------------------------------------------
// MARK: - ListenerSmartlink extension - Tokens Authentication

extension ListenerSmartlink {
  
  /// Given a UserId / Password, request an ID Token & Refresh Token
  /// - Parameters:
  ///   - user:       User name
  ///   - pwd:        User password
  /// - Returns:      an Id Token (if any)
  func requestTokens(user: String, pwd: String) async -> Tokens? {
    // build the request
    var request = URLRequest(url: URL(string: kAuth0Authenticate)!)
    request.httpMethod = kHttpPost
    request.addValue(kApplicationJson, forHTTPHeaderField: kHttpHeaderField)
    
    // add the body data & perform the request
    if let data = createTokensBodyData(user: user, pwd: pwd) {
      request.httpBody = data
      
      let result = try! await performRequest(request, for: [kKeyIdToken, kKeyRefreshToken])
      
      // validate the Id Token
      if result.count == 2 && isValid(result[0]) {
        // save the email & picture
        updateClaims(from: result[0])
        return Tokens(result[0]!, result[1]!)
      }
      return nil
    }
    // invalid Id Token or request failure
    return nil
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private methods
  
  /// Given a Refresh Token, request an ID Token
  /// - Parameter refreshToken:     a Refresh Token
  /// - Returns:                    an Id Token (if any)
  private func requestIdToken(from refreshToken: String) async -> IdToken? {
    // build the request
    var request = URLRequest(url: URL(string: kAuth0Delegation)!)
    request.httpMethod = kHttpPost
    request.addValue(kApplicationJson, forHTTPHeaderField: kHttpHeaderField)
    
    // add the body data & perform the request
    if let data = createRefreshTokenBodyData(for: refreshToken) {
      request.httpBody = data
      let result = try! await performRequest(request, for: [kKeyIdToken, kKeyRefreshToken])
      
      // validate the Id Token
      if result.count > 0, isValid(result[0]) {
        // save the email & picture
        updateClaims(from: result[0])
        // save the Tokens
        //        settingModel.shared.refreshToken = refreshToken
        //        settingModel.shared.previousIdToken = result[0]
        return result[0]
      }
      // invalid response
      return nil
    }
    // invalid Id Token
    return nil
  }
  
  /// Validate an Id Token
  /// - Parameter idToken:        the Id Token
  /// - Returns:                  true / false
  private func isValid(_ idToken: IdToken?) -> Bool {
    if let token = idToken {
      if let jwt = try? decode(jwt: token) {
        let result = IDTokenValidation(issuer: kDomain, audience: kClientId).validate(jwt)
        if result == nil { return true }
      }
    }
    return false
  }
  
  /// Perform a URL Request
  /// - Parameter urlRequest:     the Request
  /// - Returns:                  an Id Token (if any)
  private func performRequest(_ request: URLRequest, for keys: [String]) async throws -> [String?] {
    
    let (responseData, _) = try await URLSession.shared.data(for: request)
    
    return parseJson(responseData, for: keys)
  }
  
  /// Create the Body Data for obtaining an Id Token give a Refresh Token
  /// - Returns:                    the Data (if created)
  private func createRefreshTokenBodyData(for refreshToken: String) -> Data? {
    var dict = [String : String]()
    
    dict[kKeyClientId]      = kClientId
    dict[kKeyGrantType]     = kGrantTypeRefresh
    dict[kKeyRefreshToken]  = refreshToken
    dict[kKeyTarget]        = kClientId
    dict[kKeyScope]         = kScope
    
    return serialize(dict)
  }
  
  /// Create the Body Data for obtaining an Id Token given a User Id / Password
  /// - Returns:                    the Data (if created)
  private func createTokensBodyData(user: String, pwd: String) -> Data? {
    var dict = [String : String]()
    
    dict[kKeyClientId]      = kClientId
    dict[kKeyConnection]    = kConnection
    dict[kKeyDevice]        = kDevice
    dict[kKeyGrantType]     = kGrantType
    dict[kKeyPassword]      = pwd
    dict[kKeyScope]         = kScope
    dict[kKeyUserName]      = user
    
    return serialize(dict)
  }
  
  /// Convert a Data to a JSON dictionary and return the values of the specified keys
  /// - Parameters:
  ///   - data:       the Data
  ///   - keys:       an array of keys
  /// - Returns:      an array of values (some may be nil)
  private func parseJson(_ data: Data, for keys: [String]) -> [String?] {
    var values = [String?]()
    
    // convert data to a dict
    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
      // get the value for each key (some may be nil)
      for key in keys {
        values.append(json[key] as? String)
      }
    }
    return values
  }
  
  /// Convert a JSON dictionary to a Data
  /// - Parameter dict:   the dictionary
  /// - Returns:          a Data
  private func serialize(_ dict: Dictionary<String,String>) -> Data? {
    // try to serialize the data
    return try? JSONSerialization.data(withJSONObject: dict)
  }
  
  /// Update the Smartlink picture and email
  /// - Parameter idToken:    the Id Token
  private func updateClaims(from idToken: IdToken?) {
    if let idToken = idToken, let jwt = try? decode(jwt: idToken) {
      _smartlinkImage = getImage(jwt.claim(name: kClaimPicture).string)
      //      settingModel.shared.smartlinkUser = jwt.claim(name: kClaimEmail).string ?? ""
    }
  }
  
  /// Given a claim, retrieve the gravatar image
  /// - Parameter claimString:    a "picture" claim string
  /// - Returns:                  the image
  private func getImage(_ claimString: String?) -> Image {
    if let urlString = claimString, let url = URL(string: urlString) {
      if let data = try? Data(contentsOf: url), let theImage = NSImage(data: data) {
        return Image(nsImage: theImage)
      }
    }
    return Image( systemName: kDefaultPicture)
  }
}

// ----------------------------------------------------------------------------
// MARK: - ListenerSmartlink extension - GCDAsyncSocketDelegate

extension ListenerSmartlink: @preconcurrency GCDAsyncSocketDelegate {
  //      All are called on the _socketQ
  //
  //      1. A TCP connection is opened to the SmartLink server
  //      2. A TLS connection is then initiated over the TCP connection
  //      3. The TLS connection "secures" and is now ready for use
  //
  //      If a TLS negotiation fails (invalid certificate, etc) then the socket will immediately close,
  //      and the socketDidDisconnect:withError: delegate method will be called with an error code.
  //
  public func socket(_ sock: GCDAsyncSocket,
                     didConnectToHost host: String,
                     port: UInt16) {
    _host = host
    log.debug("Smartlink Listener: TCP Socket didConnectToHost, \(host):\(port)")
    
    // initiate a secure (TLS) connection to the Smartlink server
    var tlsSettings = [String : NSObject]()
    tlsSettings[kCFStreamSSLPeerName as String] = kSmartlinkHost as NSObject
    _tcpSocket.startTLS(tlsSettings)
    
    log.debug("Smartlink Listener: TLS Socket connection initiated")
  }
  
  public func socketDidSecure(_ sock: GCDAsyncSocket) {
    log.debug("Smartlink Listener: TLS socketDidSecure")
    
    // start pinging SmartLink server
    startPinging()
    
    // register the Application / token pair with the SmartLink server
    sendTlsCommand("application register name=\(_appName!) platform=\(kPlatform) token=\(_currentTokens!.idToken)", timeout: _timeout, tag: 0)
    log.debug("Smartlink Listener: Application registered, name=\(self._appName!) platform=\(self.kPlatform)")
    
    // start reading
    _tcpSocket.readData(to: GCDAsyncSocket.lfData(), withTimeout: -1, tag: 0)
    log.info("Smartlink Listener: STARTED")
  }
  
  public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
    // get the bytes that were read
    if let msg = String(data: data, encoding: .ascii) {
      // process the message
      parseVitaPayload(msg)
    }
    // trigger the next read
    _tcpSocket.readData(to: GCDAsyncSocket.lfData(), withTimeout: -1, tag: 0)
  }
  
  public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
    // Disconnected from the Smartlink server
    let error = (err == nil ? "" : " with error: " + err!.localizedDescription)
    if err == nil {
      log.debug("SmartlinkListener: TCP socketDidDisconnect \(error)")
    } else {
      log.error("SmartlinkListener: TCP socketDidDisconnect \(error)")
    }
    if err != nil { stop() }
  }
  
  public func socket(_ sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
    return 0
  }
  
  public func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
    return 30.0
  }
}

// ----------------------------------------------------------------------------
// MARK: - ListenerSmartlink extension - Smartlink data Parsing

extension ListenerSmartlink {

  /// Parse a Vita payload
  /// - Parameter text:   a Vita payload
  func parseVitaPayload(_ text: String) {
    enum Property: String {
      case application
      case radio
      case Received
    }
    let msg = text.trimmingCharacters(in: .whitespacesAndNewlines)

    let properties = msg.keyValuesArray()

    // Check for unknown properties
    guard let token = Property(rawValue: properties[0].key)  else {
      // log it
      log.warning("Smartlink Listener: \(msg)")
      return
    }
    // which primary message type?
    switch token {

    case .application:    parseApplication(Array(properties.dropFirst()))
    case .radio:          parseRadio(Array(properties.dropFirst()), msg: msg)
    case .Received:       break   // ignore message on Test connection
    }
  }

  // ------------------------------------------------------------------------------
  // MARK: - Private methods

  /// Parse a received "application" message
  /// - Parameter properties:        message KeyValue pairs
  private func parseApplication(_ properties: KeyValuesArray) {
    enum Property: String {
      case info
      case registrationInvalid = "registration_invalid"
      case userSettings        = "user_settings"
    }

    // Check for unknown properties
    guard let token = Property(rawValue: properties[0].key)  else {
      // log it and ignore the message
      log.warning("Smartlink Listener: unknown application property, \(properties[1].key)")
      return
    }
    switch token {

    case .info:                     parseApplicationInfo(Array(properties.dropFirst()))
    case .registrationInvalid:      parseRegistrationInvalid(properties)
    case .userSettings:             parseUserSettings(Array(properties.dropFirst()))
    }
  }

  /// Parse a received "radio" message
  /// - Parameter msg:        the message (after the primary type)
  private func parseRadio(_ properties: KeyValuesArray, msg: String) {
    enum Property: String {
      case connectReady   = "connect_ready"
      case list
      case testConnection = "test_connection"
    }

    // Check for unknown properties
    guard let token = Property(rawValue: properties[0].key)  else {
      // log it and ignore the message
      log.warning("Smartlink Listener: unknown radio property, \(properties[1].key)")
      return
    }
    // which secondary message type?
    switch token {

    case .connectReady:
      parseRadioConnectReady(Array(properties.dropFirst()))
    case .list:               parseRadioList(msg.dropFirst(11))
    case .testConnection:     parseTestConnectionResults(Array(properties.dropFirst()))
    }
  }

  /// Parse a received "application" message
  /// - Parameter properties:         a KeyValuesArray
  private func parseApplicationInfo(_ properties: KeyValuesArray) {
    enum Property: String {
      case publicIp = "public_ip"
    }

    log.debug("Smartlink Listener: ApplicationInfo received")

    // process each key/value pair, <key=value>
    for property in properties {
      // Check for unknown properties
      guard let token = Property(rawValue: property.key)  else {
        // log it and ignore the Key
        log.warning("Smartlink Listener: unknown info property, \(property.key)")
        continue
      }
      // Known tokens, in alphabetical order
      switch token {

      case .publicIp:       _publicIp = property.value
      }
      if _publicIp != nil {
        // stream it

        // NOTE:
//        Task {
//        _listenerModel.statusUpdate(WanStatus(.publicIp, _firstName! + " " + _lastName!, _callsign!, _serial, _wanHandle, _publicIp))
//        }
      }
    }
  }

  /// Respond to an Invalid registration
  /// - Parameter msg:                the message text
  private func parseRegistrationInvalid(_ properties: KeyValuesArray) {
    log.warning("Smartlink Listener: invalid registration: \(properties.count == 3 ? properties[2].key : "")")
  }

  /// Parse a received "user settings" message
  /// - Parameter properties:         a KeyValuesArray
  private func parseUserSettings(_ properties: KeyValuesArray) {
    enum Property: String {
      case callsign
      case firstName    = "first_name"
      case lastName     = "last_name"
    }

    log.debug("Smartlink Listener: UserSettings received")

    // process each key/value pair, <key=value>
    for property in properties {
      // Check for Unknown properties
      guard let token = Property(rawValue: property.key)  else {
        // log it and ignore the Key
        log.warning("Smartlink Listener: unknown user setting, \(property.key)")
        continue
      }
      // Known tokens, in alphabetical order
      switch token {

      case .callsign:       _callsign = property.value
      case .firstName:      _firstName = property.value
      case .lastName:       _lastName = property.value
      }
    }

    if _firstName != nil && _lastName != nil && _callsign != nil {
      // NOTE:
//      Task {
//      _listenerModel.statusUpdate(WanStatus(.settings, _firstName! + " " + _lastName!, _callsign!, _serial, _wanHandle, _publicIp))
//      }
    }
  }

  /// Parse a received "connect ready" message
  /// - Parameter properties:         a KeyValuesArray
  private func parseRadioConnectReady(_ properties: KeyValuesArray) {
    enum Property: String {
      case handle
      case serial
    }

    log.debug("Smartlink Listener: ConnectReady received")

    // process each key/value pair, <key=value>
    for property in properties {
      // Check for unknown properties
      guard let token = Property(rawValue: property.key)  else {
        // log it and ignore the Key
        log.warning("Smartlink Listener: unknown connect property, \(property.key)")
        continue
      }
      // Known tokens, in alphabetical order
      switch token {

      case .handle:         _wanHandle = property.value
      case .serial:         _serial = property.value
      }
    }
    // return to the waiting caller
    if _wanHandle != nil && _serial != nil {
      _awaitWanHandle?.resume(returning: _wanHandle!)
    } else {
      _awaitWanHandle?.resume(throwing: ListenerError.wanConnect)
    }
  }

  /// Parse a received "radio list" message
  /// - Parameter msg:        the list
  private func parseRadioList(_ msg: String.SubSequence) {
    var publicTlsPortToUse: Int?
    var publicUdpPortToUse: Int?
    var packet: Packet

    // several radios are possible, separate list into its components
    let radioMessages = msg.components(separatedBy: "|")

    for message in radioMessages where message != "" {
      packet = Packet( .smartlink, message.keyValuesArray() )
      // now continue to fill the radio parameters
      // favor using the manually defined forwarded ports if they are defined
      if let tlsPort = packet.publicTlsPort, let udpPort = packet.publicUdpPort {
        publicTlsPortToUse = tlsPort
        publicUdpPortToUse = udpPort
        packet.isPortForwardOn = true;
      } else if (packet.upnpSupported) {
        publicTlsPortToUse = packet.publicUpnpTlsPort!
        publicUdpPortToUse = packet.publicUpnpUdpPort!
        packet.isPortForwardOn = false
      }

      if ( !packet.upnpSupported && !packet.isPortForwardOn ) {
        /* This will require extra negotiation that chooses
         * a port for both sides to try
         */
        // TODO: We also need to check the NAT for preserve_ports coming from radio here
        // if the NAT DOES NOT preserve ports then we can't do hole punch
        packet.requiresHolePunch = true
      }
      packet.publicTlsPort = publicTlsPortToUse
      packet.publicUdpPort = publicUdpPortToUse
      if let localAddr = _tcpSocket.localHost {
        packet.localInterfaceIP = localAddr
      }
      // processs the packet
      let guiClients: [GuiClient] = []
      _objectModel?.process(.smartlink, message.keyValuesArray() ,nil)

      log.debug("Smartlink Listener: RadioList RECEIVED, \(packet.nickname)")
    }
  }

  /// Parse a received "test results" message
  /// - Parameter properties:         a KeyValuesArray
  private func parseTestConnectionResults(_ properties: KeyValuesArray) {
    enum Property: String {
      case forwardTcpPortWorking = "forward_tcp_port_working"
      case forwardUdpPortWorking = "forward_udp_port_working"
      case natSupportsHolePunch  = "nat_supports_hole_punch"
      case radioSerial           = "serial"
      case upnpTcpPortWorking    = "upnp_tcp_port_working"
      case upnpUdpPortWorking    = "upnp_udp_port_working"
    }

    var result = SmartlinkTestResult()

    // process each key/value pair, <key=value>
    for property in properties {
      // Check for unknown properties
      guard let token = Property(rawValue: property.key)  else {
        // log it and ignore the Key
        log.warning("Smartlink Listener: unknown testConnection property, \(property.key)")
        continue
      }

      // Known tokens, in alphabetical order
      switch token {

      case .forwardTcpPortWorking:      result.forwardTcpPortWorking = property.value.tValue
      case .forwardUdpPortWorking:      result.forwardUdpPortWorking = property.value.tValue
      case .natSupportsHolePunch:       result.natSupportsHolePunch = property.value.tValue
      case .radioSerial:                result.radioSerial = property.value
      case .upnpTcpPortWorking:         result.upnpTcpPortWorking = property.value.tValue
      case .upnpUdpPortWorking:         result.upnpUdpPortWorking = property.value.tValue
      }

//      Task { [newResult = result] in
//        await MainActor.run {
//          _listenerModel.smartlinkTestResult = newResult
//        }
//      }
    }
    // log the result
    if result.success {
      log.debug("Smartlink Listener: Test result received, SUCCESS")
    } else {
      log.warning("Smartlink Listener: Test result received, FAILURE")
    }
  }
}

