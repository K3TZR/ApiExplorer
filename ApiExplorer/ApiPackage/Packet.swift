//
//  Packet.swift
//  SharedFeature/Packet
//
//  Created by Douglas Adams on 10/28/21
//  Copyright © 2021 Douglas Adams. All rights reserved.
//

import Foundation

// ----------------------------------------------------------------------------
// MARK: - Packet Struct

public struct Packet: Identifiable, Comparable, Equatable, Sendable {
  public static func < (lhs: Packet, rhs: Packet) -> Bool {
      lhs.nickname + lhs.model < rhs.nickname + rhs.model
    }
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ source: PacketSource, _ properties: KeyValuesArray) {
    self.source = source
    
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      guard let token = Packet.Property(rawValue: property.key) else {
        // log it and ignore the Key
        log.warning("Packet: Unknown property - \(property.key) = \(property.value)")
        continue
      }
      switch token {
        
        // these fields in the received packet are copied to the Packet struct
      case .availableClients:           availableClients = property.value.iValue
      case .availablePanadapters:       availablePanadapters = property.value.iValue
      case .availableSlices:            availableSlices = property.value.iValue
      case .callsign:                   callsign = property.value
      case .discoveryProtocolVersion:   discoveryProtocolVersion = property.value
      case .fpcMac:                     fpcMac = property.value
      case .guiClientHandles:           guiClientHandles = property.value.replacingOccurrences(of: "\u{7F}", with: "").valuesArray(delimiter: ",")
      case .guiClientHosts:             guiClientHosts = property.value.replacingOccurrences(of: "\u{7F}", with: "").valuesArray(delimiter: ",")
      case .guiClientIps:               guiClientIps = property.value.replacingOccurrences(of: "\u{7F}", with: "").valuesArray(delimiter: ",")
      case .guiClientPrograms:          guiClientPrograms = property.value.replacingOccurrences(of: "\u{7F}", with: "").valuesArray(delimiter: ",")
      case .guiClientStations:          guiClientStations = property.value.replacingOccurrences(of: "\u{7F}", with: "").valuesArray(delimiter: ",")
      case .inUseHost, .inUseHostWan:   inUseHost = property.value
      case .inUseIp, .inUseIpWan:       inUseIp = property.value
      case .licensedClients:            licensedClients = property.value.iValue
      case .maxLicensedVersion:         maxLicensedVersion = property.value
      case .maxPanadapters:             maxPanadapters = property.value.iValue
      case .maxSlices:                  maxSlices = property.value.iValue
      case .minSoftwareVersion:         minSoftwareVersion = property.value
      case .model:                      model = property.value
      case .nickname, .radioName:       nickname = property.value
      case .port:                       port = property.value.iValue
      case .publicIp, .publicIpWan:     publicIp = property.value
      case .publicTlsPort:              publicTlsPort = property.value.iValueOpt
      case .publicUdpPort:              publicUdpPort = property.value.iValueOpt
      case .publicUpnpTlsPort:          publicUpnpTlsPort = property.value.iValueOpt
      case .publicUpnpUdpPort:          publicUpnpUdpPort = property.value.iValueOpt
      case .radioLicenseId:             radioLicenseId = property.value
      case .requiresAdditionalLicense:  requiresAdditionalLicense = property.value.bValue
      case .serial:                     serial = property.value
      case .status:                     status = property.value
      case .upnpSupported:              upnpSupported = property.value.bValue
      case .version:                    version = property.value
      case .wanConnected:               wanConnected = property.value.bValue
        
      case .lastSeen:                   break // ignore this, will only be present in Smartlink properties
      }
    }
//    // all three must be populated
//    if (programs.isEmpty || stations.isEmpty || handles.isEmpty || ips.isEmpty || hosts.isEmpty) == false {
//      // must be an equal number of entries in each
//      if programs.count == stations.count && programs.count == handles.count && programs.count == ips.count && programs.count == hosts.count {
//        for (i, handle) in handles.enumerated() {
//          let newGuiClient = GuiClient( handle: handle, station: stations[i], program: programs[i], ip: ips[i], host: hosts[i] )
//          guiClients.append( newGuiClient )
//        }
//      }
//    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public var id: String { serial + "|" + publicIp }
  public let source: PacketSource

//  public var guiClients = [GuiClient]()
  public var isPortForwardOn = false
  public var localInterfaceIP = ""
  public var negotiatedHolePunchPort = 0
  public var requiresHolePunch = false
  public var stations = [String]()

  // PACKET TYPE                                       LAN   WAN
  public var availableClients = 0                   //  X
  public var availablePanadapters = 0               //  X
  public var availableSlices = 0                    //  X
  public var callsign = ""                          //  X     X
  public var discoveryProtocolVersion = ""          //  X
  public var fpcMac = ""                            //  X
  public var guiClientHandles = [String]()
  public var guiClientHosts = [String]()
  public var guiClientIps = [String]()
  public var guiClientPrograms = [String]()
  public var guiClientStations = [String]()
  public var inUseHost = ""                         //  X     X
  public var inUseIp = ""                           //  X     X
  public var licensedClients = 0                    //  X
  public var maxLicensedVersion = ""                //  X     X
  public var maxPanadapters = 0                     //  X
  public var maxSlices = 0                          //  X
  public var minSoftwareVersion = ""                //
  public var model = ""                             //  X     X
  public var nickname = ""                          //  X     X   in WAN as "radio_name"
  public var port = 0                               //  X
  public var publicIp = ""                          //  X     X   in LAN as "ip"
  public var publicTlsPort: Int?                    //        X
  public var publicUdpPort: Int?                    //        X
  public var publicUpnpTlsPort: Int?                //        X
  public var publicUpnpUdpPort: Int?                //        X
  public var radioLicenseId = ""                    //  X     X
  public var requiresAdditionalLicense = false      //  X     X
  public var serial = ""                            //  X     X
  public var status = ""                            //  X     X
  public var upnpSupported = false                  //        X
  public var version = ""                           //  X     X
  public var wanConnected = false                   //  X

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var handles = [String]()
  private var hosts = [String]()
  private var ips = [String]()
  private var programs = [String]()
  
  private enum Property: String {
    case availableClients           = "available_clients"
    case availablePanadapters       = "available_panadapters"
    case availableSlices            = "available_slices"
    case callsign
    case discoveryProtocolVersion   = "discovery_protocol_version"
    case fpcMac                     = "fpc_mac"
    case guiClientHandles           = "gui_client_handles"
    case guiClientHosts             = "gui_client_hosts"
    case guiClientIps               = "gui_client_ips"
    case guiClientPrograms          = "gui_client_programs"
    case guiClientStations          = "gui_client_stations"
    case inUseHost                  = "inuse_host"
    case inUseHostWan               = "inusehost"
    case inUseIp                    = "inuse_ip"
    case inUseIpWan                 = "inuseip"
    case lastSeen                   = "last_seen"
    case licensedClients            = "licensed_clients"
    case maxLicensedVersion         = "max_licensed_version"
    case maxPanadapters             = "max_panadapters"
    case maxSlices                  = "max_slices"
    case minSoftwareVersion         = "min_software_version"
    case model
    case nickname                   = "nickname"
    case port
    case publicIp                   = "ip"
    case publicIpWan                = "public_ip"
    case publicTlsPort              = "public_tls_port"
    case publicUdpPort              = "public_udp_port"
    case publicUpnpTlsPort          = "public_upnp_tls_port"
    case publicUpnpUdpPort          = "public_upnp_udp_port"
    case radioLicenseId             = "radio_license_id"
    case radioName                  = "radio_name"
    case requiresAdditionalLicense  = "requires_additional_license"
    case serial                     = "serial"
    case status
    case upnpSupported              = "upnp_supported"
    case version                    = "version"
    case wanConnected               = "wan_connected"
  }
}


// ----------------------------------------------------------------------------
// MARK: - Packet Struct

public struct Clients: Equatable, Sendable {
  
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ source: PacketSource, _ properties: KeyValuesArray) {
    self.source = source
    
    // process each key/value pair, <key=value>
    for property in properties {
      // check for unknown Keys
      switch Clients.Property(rawValue: property.key) {
        
      case .guiClientHandles:           handles = property.value.replacingOccurrences(of: "\u{7F}", with: "").valuesArray(delimiter: ",")
      case .guiClientHosts:             hosts = property.value.replacingOccurrences(of: "\u{7F}", with: "").valuesArray(delimiter: ",")
      case .guiClientIps:               ips = property.value.replacingOccurrences(of: "\u{7F}", with: "").valuesArray(delimiter: ",")
      case .guiClientPrograms:          programs = property.value.replacingOccurrences(of: "\u{7F}", with: "").valuesArray(delimiter: ",")
      case .guiClientStations:          stations = property.value.replacingOccurrences(of: "\u{7F}", with: "").valuesArray(delimiter: ",")
      default:                          break
      }
    }
    // all three must be populated
    if (programs.isEmpty || stations.isEmpty || handles.isEmpty || ips.isEmpty || hosts.isEmpty) == false {
      // must be an equal number of entries in each
      if programs.count == stations.count && programs.count == handles.count && programs.count == ips.count && programs.count == hosts.count {
        for (i, handle) in handles.enumerated() {
          let newGuiClient = GuiClient( handle: handle, station: stations[i], program: programs[i], ip: ips[i], host: hosts[i] )
          guiClients.append( newGuiClient )
        }
      }
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
//  public var id: String { serial + "|" + publicIp }
  public let source: PacketSource

  public var guiClients = [GuiClient]()
//  public var isPortForwardOn = false
//  public var localInterfaceIP = ""
//  public var negotiatedHolePunchPort = 0
//  public var requiresHolePunch = false
//  public var stations = [String]()

  // PACKET TYPE                                       LAN   WAN
//  public var availableClients = 0                   //  X
//  public var availablePanadapters = 0               //  X
//  public var availableSlices = 0                    //  X
//  public var callsign = ""                          //  X     X
//  public var discoveryProtocolVersion = ""          //  X
//  public var fpcMac = ""                            //  X
//  public var guiClientHandles = [String]()
//  public var guiClientHosts = [String]()
//  public var guiClientIps = [String]()
//  public var guiClientPrograms = [String]()
//  public var guiClientStations = [String]()
//  public var inUseHost = ""                         //  X     X
//  public var inUseIp = ""                           //  X     X
//  public var licensedClients = 0                    //  X
//  public var maxLicensedVersion = ""                //  X     X
//  public var maxPanadapters = 0                     //  X
//  public var maxSlices = 0                          //  X
//  public var minSoftwareVersion = ""                //
//  public var model = ""                             //  X     X
//  public var nickname = ""                          //  X     X   in WAN as "radio_name"
//  public var port = 0                               //  X
//  public var publicIp = ""                          //  X     X   in LAN as "ip"
//  public var publicTlsPort: Int?                    //        X
//  public var publicUdpPort: Int?                    //        X
//  public var publicUpnpTlsPort: Int?                //        X
//  public var publicUpnpUdpPort: Int?                //        X
//  public var radioLicenseId = ""                    //  X     X
//  public var requiresAdditionalLicense = false      //  X     X
//  public var serial = ""                            //  X     X
//  public var status = ""                            //  X     X
//  public var upnpSupported = false                  //        X
//  public var version = ""                           //  X     X
//  public var wanConnected = false                   //  X

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var handles = [String]()
  private var hosts = [String]()
  private var ips = [String]()
  private var programs = [String]()
  private var stations = [String]()

  private enum Property: String {
    case availableClients           = "available_clients"
    case availablePanadapters       = "available_panadapters"
    case availableSlices            = "available_slices"
    case callsign
    case discoveryProtocolVersion   = "discovery_protocol_version"
    case fpcMac                     = "fpc_mac"
    case guiClientHandles           = "gui_client_handles"
    case guiClientHosts             = "gui_client_hosts"
    case guiClientIps               = "gui_client_ips"
    case guiClientPrograms          = "gui_client_programs"
    case guiClientStations          = "gui_client_stations"
    case inUseHost                  = "inuse_host"
    case inUseHostWan               = "inusehost"
    case inUseIp                    = "inuse_ip"
    case inUseIpWan                 = "inuseip"
    case lastSeen                   = "last_seen"
    case licensedClients            = "licensed_clients"
    case maxLicensedVersion         = "max_licensed_version"
    case maxPanadapters             = "max_panadapters"
    case maxSlices                  = "max_slices"
    case minSoftwareVersion         = "min_software_version"
    case model
    case nickname                   = "nickname"
    case port
    case publicIp                   = "ip"
    case publicIpWan                = "public_ip"
    case publicTlsPort              = "public_tls_port"
    case publicUdpPort              = "public_udp_port"
    case publicUpnpTlsPort          = "public_upnp_tls_port"
    case publicUpnpUdpPort          = "public_upnp_udp_port"
    case radioLicenseId             = "radio_license_id"
    case radioName                  = "radio_name"
    case requiresAdditionalLicense  = "requires_additional_license"
    case serial                     = "serial"
    case status
    case upnpSupported              = "upnp_supported"
    case version                    = "version"
    case wanConnected               = "wan_connected"
  }
}
