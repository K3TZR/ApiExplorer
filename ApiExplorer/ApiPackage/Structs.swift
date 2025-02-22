//
//  Structs.swift
//  SharedFeatures/Shared
//
//  Created by Douglas Adams on 10/23/21.
//

import AVFoundation
//import IdentifiedCollections
import Foundation
import SwiftUI

public typealias Hz = Int
public typealias MHz = Double

// ----------------------------------------------------------------------------
// MARK: - Constants

public let kVersionSupported = Version("3.2.34")
public let kConnected = "connected"
public let kDisconnected = "disconnected"
public let kNoError = "0"
public let kNotInUse = "in_use=0"
public let kRemoved = "removed"

public let FlexSuite = "group.net.k3tzr.flexapps"

// ----------------------------------------------------------------------------
// MARK: - Structs & Enums

public struct ControlsOptions: OptionSet, Sendable {
  
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  public let rawValue: Int
  
  public static let rx  = ControlsOptions(rawValue: 1 << 0)
  public static let tx  = ControlsOptions(rawValue: 1 << 1)
  public static let ph1 = ControlsOptions(rawValue: 1 << 2)
  public static let ph2 = ControlsOptions(rawValue: 1 << 3)
  public static let cw  = ControlsOptions(rawValue: 1 << 4)
  public static let eq  = ControlsOptions(rawValue: 1 << 5)
  
  public static let all: ControlsOptions = [.rx, .tx, .ph1, ph2, .cw, .eq]
}

public enum SpectrumType: String, Equatable, CaseIterable {
  case line = "Line"
  case filled = "Filled"
  case gradient = "Gradient"
}

public enum ConnectionStatus {
  case disconnected
  case inProcess
  case connected
}

public struct Antenna: Hashable, Codable {
  public var stdName: String
  public var customName: String
  
  public init(stdName: String, customName: String) {
    self.stdName = stdName
    self.customName = customName
  }
}

public struct KnownRadio: Identifiable, Hashable, Codable {
  public var id: UUID
  public var name: String
  public var ipAddress: String
  
  public init(_ name: String, _ location: String, _ ipAddress: String) {
    self.id = UUID()
    self.name = name
    self.ipAddress = ipAddress
  }
}

public struct SpectrumGradient {
  public var stops: [Gradient.Stop] =
  [
    .init(color: .green.opacity(0.2), location: 0.4),
    .init(color: .yellow.opacity(0.3), location: 0.6),
    .init(color: .red.opacity(0.4), location: 0.9),
  ]
  
  public init() {}
  
  public mutating func setStops( stops: [Gradient.Stop] ) {
    guard stops.count == 3 else { return }
    self.stops[0] = stops[0]
    self.stops[1] = stops[1]
    self.stops[2] = stops[2]
  }
}

public enum ApiError: String, Error {
  case instantiation = "Failed to create Radio object"
  case connection = "Failed to connect to Radio"
  case replyError = "Reply with error"
  case tcpConnect = "Tcp Failed to connect"
  case udpBind = "Udp Failed to bind"
  case wanConnect = "WanConnect Failed"
  case wanValidation = "WanValidation Failed"
  case statusTimeout = "Timeout waiting for receipt of the first Status message from the Radio"
}

public enum ConnectionType: String, Equatable {
  case gui = "Radio"
  case nonGui = "Station"
}

/// Struct to hold a Semantic Version number
///     with provision for a Build Number
///
public struct Version: Sendable {
  var major: Int = 1
  var minor: Int = 0
  var patch: Int = 0
  var build: Int = 1
  
  public init(_ versionString: String = "1.0.0") {
    let components = versionString.components(separatedBy: ".")
    switch components.count {
    case 3:
      major = Int(components[0]) ?? 1
      minor = Int(components[1]) ?? 0
      patch = Int(components[2]) ?? 0
      build = 1
    case 4:
      major = Int(components[0]) ?? 1
      minor = Int(components[1]) ?? 0
      patch = Int(components[2]) ?? 0
      build = Int(components[3]) ?? 1
    default:
      major = 1
      minor = 0
      patch = 0
      build = 1
    }
  }
  
  public init() {
    // only useful for Apps & Frameworks (which have a Bundle), not Packages
    let versions = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "?"
    let build   = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as? String ?? "?"
    self.init(versions + ".\(build)")
  }
  
  public var longString: String { "\(major).\(minor).\(patch) (\(build))" }
  public var string: String { "\(major).\(minor).\(patch)" }
  
  public static func == (lhs: Version, rhs: Version) -> Bool { lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch }
  
  public static func < (lhs: Version, rhs: Version) -> Bool {
    switch (lhs, rhs) {
      
    case (let lhs, let rhs) where lhs == rhs: return false
    case (let lhs, let rhs) where lhs.major < rhs.major: return true
    case (let lhs, let rhs) where lhs.major == rhs.major && lhs.minor < rhs.minor: return true
    case (let lhs, let rhs) where lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch < rhs.patch: return true
    default: return false
    }
  }
  public static func >= (lhs: Version, rhs: Version) -> Bool {
    switch (lhs, rhs) {
      
    case (let lhs, let rhs) where lhs == rhs: return true
    case (let lhs, let rhs) where lhs.major > rhs.major: return true
    case (let lhs, let rhs) where lhs.major == rhs.major && lhs.minor > rhs.minor: return true
    case (let lhs, let rhs) where lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch > rhs.patch: return true
    default: return false
    }
  }
}

//public enum TcpMessageDirection {
//  case received
//  case sent
//}

public struct TcpMessage: Identifiable, Equatable, Sendable {
  public var id: UUID
  public var text: String
  public var isInput: Bool
  public var timeStamp: Date
  public var interval: Double
  public var color: Color

  public static func == (lhs: TcpMessage, rhs: TcpMessage) -> Bool {
    lhs.id == rhs.id
  }
  
  public init
  (
    text: String,
    isInput: Bool = true,
    timeStamp: Date = Date(),
    interval: Double,
    color: Color = .primary
  )
  {
    self.id = UUID()
    self.text = text
    self.isInput = isInput
    self.timeStamp = timeStamp
    self.interval = interval
    self.color = color
  }
}

public enum WanStatusType {
  case connect
  case publicIp
  case settings
}

public struct WanStatus: Equatable {
  public var type: WanStatusType
  public var name: String?
  public var callsign: String?
  public var serial: String?
  public var wanHandle: String?
  public var publicIp: String?

  public init(
    _ type: WanStatusType,
    _ name: String?,
    _ callsign: String?,
    _ serial: String?,
    _ wanHandle: String?,
    _ publicIp: String?
  )
  {
    self.type = type
    self.name = name
    self.callsign = callsign
    self.serial = serial
    self.wanHandle = wanHandle
    self.publicIp = publicIp
  }
}

public enum PacketSource: String, Equatable, Codable, Sendable {
  case direct = "Direct"
  case local = "Local"
  case smartlink = "Smartlink"
}

public enum WanListenerError: Error {
  case kFailedToObtainIdToken
  case kFailedToConnect
}

public struct Band: Identifiable{
  
  public init(_ label: String, _ number: String = "") {
    self.label = label
    self.number = number
  }
  public var id = UUID()
  public var label: String
  public var number: String
}


public struct SmartlinkTestResult: Equatable {
  public var upnpTcpPortWorking = false
  public var upnpUdpPortWorking = false
  public var forwardTcpPortWorking = false
  public var forwardUdpPortWorking = false
  public var natSupportsHolePunch = false
  public var radioSerial = ""
  
  public init() {}
  
  // format the result as a String
  public var description: String {
        """
        Forward Tcp Port:\t\t\(forwardTcpPortWorking)
        Forward Udp Port:\t\t\(forwardUdpPortWorking)
        UPNP Tcp Port:\t\t\(upnpTcpPortWorking)
        UPNP Udp Port:\t\t\(upnpUdpPortWorking)
        Nat Hole Punch:\t\t\(natSupportsHolePunch)
        """
  }
  
  // result was Success / Failure
  public var success: Bool {
    (
      forwardTcpPortWorking == true &&
      forwardUdpPortWorking == true &&
      upnpTcpPortWorking == false &&
      upnpUdpPortWorking == false &&
      natSupportsHolePunch  == false) ||
    (
      forwardTcpPortWorking == false &&
      forwardUdpPortWorking == false &&
      upnpTcpPortWorking == true &&
      upnpUdpPortWorking == true &&
      natSupportsHolePunch  == false)
  }
}

// struct & enums for use in the Log Viewer
public struct LogLine: Identifiable, Equatable {
  public var id = UUID()
  public var text: String
  public var color: Color
  
  public init(text: String, color: Color = .primary) {
    self.text = text
    self.color = color
  }
}

public enum LogFilter: String, CaseIterable {
  case none
  case includes
  case excludes
  case prefix
}

public enum AudioCompression: String {
  case none
  case opus
}

// Helper struct used by Audio routines
public struct AudioDevice : Identifiable, Equatable {
  public var id: AudioDeviceID
  
  public init(_ id: AudioDeviceID) {
    self.id = id
  }
  
  public var hasOutput: Bool {
    get {
      var address:AudioObjectPropertyAddress = AudioObjectPropertyAddress(
        mSelector:AudioObjectPropertySelector(kAudioDevicePropertyStreamConfiguration),
        mScope:AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
        mElement:0)
      
      var propsize: UInt32 = UInt32(MemoryLayout<CFString?>.size);
      if AudioObjectGetPropertyDataSize(id, &address, 0, nil, &propsize) != 0 {
        return false;
      }
      
      let bufferList = UnsafeMutablePointer<AudioBufferList>.allocate(capacity:Int(propsize))
      if AudioObjectGetPropertyData(id, &address, 0, nil, &propsize, bufferList) != 0 {
        return false
      }
      
      let buffers = UnsafeMutableAudioBufferListPointer(bufferList)
      for bufferNum in 0..<buffers.count {
        if buffers[bufferNum].mNumberChannels > 0 { return true }
      }
      return false
    }
  }
  
  public var uid: String? {
    get {
      var address:AudioObjectPropertyAddress = AudioObjectPropertyAddress(
        mSelector:AudioObjectPropertySelector(kAudioDevicePropertyDeviceUID),
        mScope:AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
        mElement:AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
      
      var deviceUid: CFString? = nil
      var propSize = UInt32(MemoryLayout<CFString?>.size)
      guard AudioObjectGetPropertyData(id, &address, 0, nil, &propSize, &deviceUid) == 0 else { return nil }
      return deviceUid as String?
    }
  }
  
  public var name: String? {
    get {
      var address:AudioObjectPropertyAddress = AudioObjectPropertyAddress(
        mSelector:AudioObjectPropertySelector(kAudioDevicePropertyDeviceNameCFString),
        mScope:AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
        mElement:AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
      
      var deviceName: CFString? = nil
      var propSize = UInt32(MemoryLayout<CFString?>.size)
      guard AudioObjectGetPropertyData(id, &address, 0, nil, &propSize, &deviceName) == 0 else { return nil }
      return deviceName as String?
    }
  }
  
  public static func getDevices() -> [AudioDevice] {
    var devices = [AudioDevice]()
    var propsize: UInt32 = 0
    var address: AudioObjectPropertyAddress = AudioObjectPropertyAddress(mSelector:AudioObjectPropertySelector(kAudioHardwarePropertyDevices),
                                                                         mScope:AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
                                                                         mElement:AudioObjectPropertyElement(kAudioObjectPropertyElementMain))
    
    if AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address, UInt32(MemoryLayout<AudioObjectPropertyAddress>.size), nil, &propsize) != 0 {
      return devices
    }
    var deviceIds = [AudioDeviceID](repeating: AudioDeviceID(0), count: Int(propsize / UInt32(MemoryLayout<AudioDeviceID>.size)))
    if AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &propsize, &deviceIds) != 0 {
      return devices
    }
    for deviceId in deviceIds {
      devices.append(AudioDevice(deviceId))
//      print("----->>>>> ", AudioDevice(deviceId).id, AudioDevice(deviceId).name)
    }
    return devices
  }
}

public struct SignalLevel {
  public init(rms: Float, peak: Float) {
    self.rms = CGFloat(rms)
    self.peak = CGFloat(peak)
  }
  
  public var rms: CGFloat
  public var peak: CGFloat
  
  public var desc: String {
    String(format: "%3.2f", rms) + ", " + String(format: "%3.2f", peak)
  }
}

public enum MeterUnits : String {
  case none
  case amps
  case db
  case dbfs
  case dbm
  case degc
  case degf
  case percent
  case rpm
  case swr
  case volts
  case watts
}

public enum ConnectionState: String, Sendable {
  case connected
  case connecting
  case disconnected
  case disconnecting
  case errorOnConnect
  case errorOnDisconnect
}

public struct DaxPanelOptions: OptionSet, Sendable {        // FIXME: move to Shared
  public init(rawValue: UInt8) {
    self.rawValue = rawValue
  }
  
  public let rawValue: UInt8
  
  public static let tx  = DaxPanelOptions(rawValue: 1 << 0)
  public static let mic = DaxPanelOptions(rawValue: 1 << 1)
  public static let rx = DaxPanelOptions(rawValue: 1 << 2)
  public static let iq = DaxPanelOptions(rawValue: 1 << 3)
  
  public static let all: DaxPanelOptions = [.tx, .mic, .rx, iq]
}

public struct AlertInfo: Sendable {
  public var title: String
  public var message: String
  
  public init(_ title: String, _ message: String) {
    self.title = title
    self.message = message
  }
}

public enum DiscoveryDisplayType: String, CaseIterable {
  case fields = "Vita Fields"
  case keyValues = "Payload Key Values"
  case hex = "Vita hex map"
}

