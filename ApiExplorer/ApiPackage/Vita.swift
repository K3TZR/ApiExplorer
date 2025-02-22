//  Vita.swift
//  SharedFeatures/Shared
//
//  Created by Douglas Adams on 5/9/17.
//

import Foundation

public protocol StreamProcessor: AnyObject {
  func streamProcessor(_ vita: Vita) async
}

public protocol AudioProcessor: AnyObject {
  func audioProcessor(_ vita: Vita)
}


///  VITA header struct implementation
///      provides decoding and encoding services for Vita encoding
///      see http://www.vita.com
public struct VitaHeader {
  // this struct mirrors the structure of a Vita Header
  //      some of these fields are optional in a generic Vita-49 header
  //      however they are always present in the Flex usage of Vita-49
  //
  //      all of the UInt16 & UInt32 fields must be BigEndian
  //
  //      This header is 28 bytes / 4 UInt32's
  //
  public var packetDesc                            : UInt8 = 0
  public var timeStampDesc                         : UInt8 = 0   // the lsb four bits are used for sequence number
  public var packetSize                            : UInt16 = 0
  public var streamId                              : UInt32 = 0
  public var oui                                   : UInt32 = 0
  public var classCodes                            : UInt32 = 0
  public var integerTimeStamp                      : UInt32 = 0
  public var fractionalTimeStampMsb                : UInt32 = 0
  public var fractionalTimeStampLsb                : UInt32 = 0
}

///  VITA class implementation
///     this class includes, in a more readily inspectable form, all of the properties
///     needed to populate a Vita Data packet. The "encode" instance method converts this
///     struct into a Vita Data packet. The "decode" static method converts a supplied
///     Vita Data packet into a Vita struct.
public class Vita {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  /// Initialize Vita struct with the defaults above
  public init() {
    // nothing needed, all values are defaulted
  }
  
  /// Initialize Vita with specific settings
  /// - Parameters:
  ///   - type:           the type of Vita
  ///   - streamId:       a StreamId
  ///   - reducedBW:      is for reduced bandwidth
  ///
  public convenience init(type: VitaTypes, streamId: UInt32, reducedBW: Bool = false) {
    switch type {
      
    case .discovery:    self.init(packetType: .extDataWithStream, classCode: .discovery, streamId: streamId, tsi: .utc, tsf: .sampleCount)
    case .netCW:        self.init(packetType: .extDataWithStream, classCode: .daxAudio, streamId: streamId, tsi: .other, tsf: .sampleCount)
    case .opusTxV2:     self.init(packetType: .extDataWithStream, classCode: .daxAudio, streamId: streamId, tsi: .other, tsf: .sampleCount)
    case .opusTx:       self.init(packetType: .extDataWithStream, classCode: .opus, streamId: streamId, tsi: .other, tsf: .sampleCount)
    case .txAudio:
      var classCode = ClassCode.daxAudio
      if reducedBW { classCode = ClassCode.daxAudioReducedBw }
      self.init(packetType: .ifDataWithStream, classCode: classCode, streamId: streamId, tsi: .other, tsf: .sampleCount)
    }
  }
  
  /// Initialize a Vita struct as a dataWithStream (Ext or If)
  /// - Parameters:
  ///   - packetType:     a Vita Packet Type (.extDataWithStream || .ifDataWithStream)
  ///   - classCode:      a Vita Class Code
  ///   - streamId:       a Stream ID (as a String, no "0x")
  ///   - tsi:            the type of Integer Time Stamp
  ///   - tsf:            the type of Fractional Time Stamp
  /// - Returns:          a partially populated Vita struct
  init(packetType: PacketTypes, classCode: ClassCode, streamId: UInt32, tsi: TsiTypes, tsf: TsfTypes) {
    assert(packetType == .extDataWithStream || packetType == .ifDataWithStream)
    
    self.packetType = packetType
    self.classCode = classCode
    self.streamId = streamId
    self.tsiType = tsi
    self.tsfType = tsf
    if tsi == .utc {
      self.integerTimestamp = CFSwapInt32HostToBig(UInt32(Date().timeIntervalSince1970))
    }
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Public properties
  
  public static let DiscoveryStreamId              : UInt32 = 0x00000800
  public var classCode                             : ClassCode = .panadapter      // Packet class code
  public var classIdPresent                        : Bool = true                         // Class ID present
  public var packetSize                            : Int = 0                             // Size of packet (32 bit chunks)
  public var payloadData                           = [UInt8]()                           // Array of bytes in payload
  public var payloadSize                           : Int = 0                             // Size of payload (bytes)
  public var streamId                              : UInt32 = 0                          // Stream ID
  
  // ----------------------------------------------------------------------------
  // MARK: - Static properties
  
  // Flex specific codes
  static let kFlexOui                       : UInt32 = 0x1c2d
  static let kOuiMask                       : UInt32 = 0x00ffffff
  static let kFlexInformationClassCode      : UInt32 = 0x534c
  
  static let kClassIdPresentMask            : UInt8 = 0x08
  static let kTrailerPresentMask            : UInt8 = 0x04
  
  // ----------------------------------------------------------------------------
  // MARK: - Internal properties
  
  // filled with defaults, values are changed when created
  //      Types are shown for clarity
  
  var packetType                            : PacketTypes = .extDataWithStream    // Packet type
  var trailerPresent                        : Bool = false                        // Trailer present
  var tsiType                               : TsiTypes = .utc                     // Integer timestamp type
  var tsfType                               : TsfTypes = .sampleCount             // Fractional timestamp type
  public var sequence                       : Int = 0                             // Mod 16 packet sequence number
  var integerTimestamp                      : UInt32 = 0                          // Integer portion
  var fracTimeStampMsb                      : UInt32 = 0                          // fractional portion - MSB 32 bits
  var fracTimeStampLsb                      : UInt32 = 0                          // fractional portion -LSB 32 bits
  var oui                                   : UInt32 = kFlexOui                   // Flex Radio oui
  var informationClassCode                  : UInt32 = kFlexInformationClassCode  // Flex Radio classCode
  var trailer                               : UInt32 = 0                          // Trailer, 4 bytes (if used)
  var headerSize                            : Int = MemoryLayout<VitaHeader>.size // Header size (bytes)
  
  /// Decode a Data type into a Vita class
  /// - Parameter data:         a Data type containing a Vita stream
  /// - Returns:                a Vita class
  ///
  public class func decode(from data: Data) -> Vita? {
    let kVitaMinimumBytes                   = 28                                  // Minimum size of a Vita packet (bytes)
    let kPacketTypeMask                     : UInt8 = 0xf0                        // Bit masks
    let kClassIdPresentMask                 : UInt8 = 0x08
    let kTrailerPresentMask                 : UInt8 = 0x04
    let kTsiTypeMask                        : UInt8 = 0xc0
    let kTsfTypeMask                        : UInt8 = 0x30
    let kPacketSequenceMask                 : UInt8 = 0x0f
    let kInformationClassCodeMask           : UInt32 = 0xffff0000
    let kClassCodeMask                      : UInt32 = 0x0000ffff
    let kOffsetOptionals                    = 4                                   // byte offset to optional header section
    let kTrailerSize                        = 4                                   // Size of a trailer (bytes)
    
    var headerCount = 0
    
    let vita = Vita()
    
    // packet too short - return
    if data.count < kVitaMinimumBytes { return nil }
    
    // map the packet to the VitaHeader struct
    let vitaHeader = (data as NSData).bytes.bindMemory(to: VitaHeader.self, capacity: 1)
    
    // ensure the packet has our OUI
    guard CFSwapInt32BigToHost(vitaHeader.pointee.oui) == Vita.kFlexOui else { return nil }
    
    // capture Packet Type
    guard let pt = PacketTypes(rawValue: (vitaHeader.pointee.packetDesc & kPacketTypeMask) >> 4) else {return nil}
    vita.packetType = pt
    
    // ensure its one of the supported types
    guard vita.packetType == .ifDataWithStream || vita.packetType == .extDataWithStream else { return nil }
    
    // capture ClassId & TrailerId present
    vita.classIdPresent = (vitaHeader.pointee.packetDesc & kClassIdPresentMask) == kClassIdPresentMask
    vita.trailerPresent = (vitaHeader.pointee.packetDesc & kTrailerPresentMask) == kTrailerPresentMask
    
    // capture Time Stamp Integer
    guard let intStamp = TsiTypes(rawValue: (vitaHeader.pointee.timeStampDesc & kTsiTypeMask) >> 6) else {return nil}
    vita.tsiType = intStamp
    
    // capture Time Stamp Fractional
    guard let fracStamp = TsfTypes(rawValue: (vitaHeader.pointee.timeStampDesc & kTsfTypeMask) >> 4) else {return nil}
    vita.tsfType = fracStamp
    
    // capture PacketCount & PacketSize
    vita.sequence = Int((vitaHeader.pointee.timeStampDesc & kPacketSequenceMask))
    vita.packetSize = Int(CFSwapInt16BigToHost(vitaHeader.pointee.packetSize)) * 4
    
    // create an UnsafePointer<UInt32> to the optional words of the packet
    let vitaOptionals = (data as NSData).bytes.advanced(by: kOffsetOptionals).bindMemory(to: UInt32.self, capacity: 6)
    
    // capture Stream Id (if any)
    if vita.packetType == .ifDataWithStream || vita.packetType == .extDataWithStream {
      vita.streamId = CFSwapInt32BigToHost(vitaOptionals.pointee)
      
      // Increment past this item
      headerCount += 1
    }
    
    // capture Oui, InformationClass code & PacketClass code (if any)
    if vita.classIdPresent == true {
      vita.oui = CFSwapInt32BigToHost(vitaOptionals.advanced(by: headerCount).pointee) & kOuiMask
      
      let value = CFSwapInt32BigToHost(vitaOptionals.advanced(by: headerCount + 1).pointee)
      vita.informationClassCode = (value & kInformationClassCodeMask) >> 16
      
      guard let cc = ClassCode(rawValue: UInt16(value & kClassCodeMask)) else {return nil}
      vita.classCode = cc
      
      // Increment past these items
      headerCount += 2
    }
    
    // capture the Integer Time Stamp (if any)
    if vita.tsiType != .none {
      // Integer Time Stamp present
      vita.integerTimestamp = CFSwapInt32BigToHost(vitaOptionals.advanced(by: headerCount).pointee)
      
      // Increment past this item
      headerCount += 1
    }
    
    // capture the Fractional Time Stamp (if any)
    if vita.tsfType != .none {
      // Fractional Time Stamp present
      vita.fracTimeStampMsb = CFSwapInt32BigToHost(vitaOptionals.advanced(by: headerCount).pointee)
      vita.fracTimeStampLsb = CFSwapInt32BigToHost(vitaOptionals.advanced(by: headerCount + 1).pointee)
      
      // Increment past these items
      headerCount += 2
    }
    
    // calculate the Header size (bytes)
    vita.headerSize = ( 4 * (headerCount + 1) )
    // calculate the payload size (bytes)
    // NOTE: The data payload size is NOT necessarily a multiple of 4 bytes (it can be any number of bytes)
    vita.payloadSize = data.count - vita.headerSize - (vita.trailerPresent ? kTrailerSize : 0)
    
    // initialize the payload array & copy the payload data into it
    vita.payloadData = [UInt8](repeating: 0x00, count: vita.payloadSize)
    (data as NSData).getBytes(&vita.payloadData, range: NSMakeRange(vita.headerSize, vita.payloadSize))
    
    // capture the Trailer (if any)
    if vita.trailerPresent {
      // calculate the pointer to the Trailer (must be the last 4 bytes of the packet)
      let vitaTrailer = (data as NSData).bytes.advanced(by: data.count - 4).bindMemory(to: UInt32.self, capacity: 1)
      
      // capture the Trailer
      vita.trailer = CFSwapInt32BigToHost(vitaTrailer.pointee)
    }
    return vita
  }
  
  /// Encode a Vita class as a Data type
  /// - Returns:          a Data type containing the Vita stream
  public class func encodeAsData(_ vita: Vita, sequenceNumber: UInt8) -> Data? {
    // TODO: Handle optional fields
    
    // create a Header struct
    var header = VitaHeader()
    
    // populate the header fields from the Vita struct
    
    // packet type
    header.packetDesc = (vita.packetType.rawValue & 0x0f) << 4
    
    // class id & trailer flags
    if vita.classIdPresent { header.packetDesc |= Vita.kClassIdPresentMask }
    if vita.trailerPresent { header.packetDesc |= Vita.kTrailerPresentMask }
    
    // time stamps
    header.timeStampDesc = ((vita.tsiType.rawValue & 0x03) << 6) | ((vita.tsfType.rawValue & 0x03) << 4) | (sequenceNumber & 0x0f)
    
    header.integerTimeStamp = CFSwapInt32HostToBig(vita.integerTimestamp)
    header.fractionalTimeStampLsb = CFSwapInt32HostToBig(vita.fracTimeStampLsb)
    header.fractionalTimeStampMsb = CFSwapInt32HostToBig(vita.fracTimeStampMsb)
    
    // sequence number
    header.timeStampDesc |= (UInt8(vita.sequence) & 0x0f)
    
    // oui
    header.oui = CFSwapInt32HostToBig(Vita.kFlexOui & Vita.kOuiMask)
    
    // class codes
    let classCodes = UInt32(vita.informationClassCode << 16) | UInt32(vita.classCode.rawValue)
    header.classCodes = CFSwapInt32HostToBig(classCodes)
    
    // packet size (round up to allow for OpusTx with payload bytes not a multiple of 4)
    let adjustedPacketSize = UInt16( (Float(vita.packetSize) / 4.0).rounded(.up))
    header.packetSize = CFSwapInt16HostToBig( adjustedPacketSize )
    
    // stream id
    header.streamId = CFSwapInt32HostToBig(vita.streamId)
    
    // create the Data type and populate it with the VitaHeader
    var data = Data(bytes: &header, count: MemoryLayout<VitaHeader>.size)
    
    // append the payload bytes
    data.append(&vita.payloadData, count: vita.payloadSize)
    
    // is there a Trailer?
    if vita.trailerPresent {
      // YES, append the trailer bytes
      data.append( Data(bytes: &vita.trailer, count: MemoryLayout<UInt32>.size) )
    }
    
    // pad to 32 bit boundary with nulls
    let null: [UInt8] = [0]
    if vita.packetSize % 4 != 0 {
      data.append(null, count: 4 - (vita.packetSize % 4))
    }
    
    
    
    // return the Data type
    return data
  }
  
  /// Create a Data type containing a Vita Discovery packet
  /// - Parameter payload:        the Discovery payload (as an array of String)
  /// - Returns:                  a Data type containing a Vita Discovery packet
  public class func discovery(payload: [String], sequenceNumber: UInt8) -> Data? {
    // create a new Vita class (w/defaults & extDataWithStream / Discovery)
    let vita = Vita(type: .discovery, streamId: Vita.DiscoveryStreamId)
    
    // concatenate the strings, separated by space
    let payloadString = payload.joined(separator: " ")
    
    // calculate the actual length of the payload (in bytes)
    vita.payloadSize = payloadString.lengthOfBytes(using: .ascii)
    
    //        // calculate the number of UInt32 that can contain the payload bytes
    //        let payloadWords = Int((Float(vita.payloadSize) / Float(MemoryLayout<UInt32>.size)).rounded(.awayFromZero))
    //        let payloadBytes = payloadWords * MemoryLayout<UInt32>.size
    
    // create the payload array at the appropriate size (always a multiple of UInt32 size)
    var payloadArray = [UInt8](repeating: 0x20, count: vita.payloadSize)
    
    // packet size is Header + Payload (no Trailer)
    vita.packetSize = vita.payloadSize + MemoryLayout<VitaHeader>.size
    
    // convert the payload to an array of UInt8
    let cString = payloadString.cString(using: .ascii)!
    for i in 0..<cString.count - 1 {
      payloadArray[i] = UInt8(cString[i])
    }
    // give the Vita struct a pointer to the payload
    vita.payloadData = payloadArray
    
    // return the encoded Vita class as Data
    return Vita.encodeAsData(vita, sequenceNumber: sequenceNumber)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Vita types

extension Vita {
  /// Types
  public  enum VitaTypes {
    case discovery
    case netCW
    case opusTxV2
    case opusTx
    case txAudio
  }
  
  /// Packet Types
  public enum PacketTypes : UInt8 {          // Packet Types
    case ifData             = 0x00
    case ifDataWithStream   = 0x01
    case extData            = 0x02
    case extDataWithStream  = 0x03
    case ifContext          = 0x04
    case extContext         = 0x05
    
    func description() -> String {
      switch self {
      case .ifData:             return "IfData"
      case .ifDataWithStream:   return "IfDataWithStream"
      case .extData:            return "ExtData"
      case .extDataWithStream:  return "ExtDataWithStream"
      case .ifContext:          return "IfContext"
      case .extContext:         return "ExtContext"
      }
    }
  }
  
  /// Tsi Types
  public enum TsiTypes : UInt8 {             // Timestamp - Integer
    case none   = 0x00
    case utc    = 0x01
    case gps    = 0x02
    case other  = 0x03
    
    func description() -> String {
      switch self {
      case .none:   return "None"
      case .utc:    return "Utc"
      case .gps:    return "Gps"
      case .other:  return "Other"
      }
    }
  }
  
  /// Tsf Types
  public enum TsfTypes : UInt8 {             // Timestamp - Fractional
    case none         = 0x00
    case sampleCount  = 0x01
    case realtime     = 0x02
    case freeRunning  = 0x03
    
    func description() -> String {
      switch self {
      case .none:         return "None"
      case .sampleCount:  return "SampleCount"
      case .realtime:     return "Realtime"
      case .freeRunning:  return "FreeRunning"
      }
    }
  }
  
  /// Class codes
  public enum ClassCode: UInt16 {    // Packet Class Codes
    case daxAudio          = 0x03e3
    case daxAudioReducedBw = 0x0123
    case daxIq24           = 0x02e3
    case daxIq48           = 0x02e4
    case daxIq96           = 0x02e5
    case daxIq192          = 0x02e6
    case discovery         = 0xffff
    case meter             = 0x8002
    case opus              = 0x8005
    case panadapter        = 0x8003
    case waterfall         = 0x8004

    public func description() -> String {
      switch self {
      case .daxAudio:          return "DaxAudio"
      case .daxAudioReducedBw: return "DaxAudioReducedBw"
      case .daxIq24:           return "DaxIq24"
      case .daxIq48:           return "DaxIq48"
      case .daxIq96:           return "DaxIq96"
      case .daxIq192:          return "DaxIq192"
      case .discovery:         return "Discovery"
      case .meter:             return "Meter"
      case .opus:              return "Opus"
      case .panadapter:        return "Panadapter"
      case .waterfall:         return "Waterfall"
      }
    }
  }
}
