//
//  Extensions.swift
//  SharedFeature/Extensions
//
//  Created by Douglas Adams on 3/19/22.
//

//import ComposableArchitecture
import Foundation
import SwiftUI

public typealias KeyValuesArray = [(key:String, value:String)]
public typealias ValuesArray = [String]

// ----------------------------------------------------------------------------
// MARK: - Functions

//struct TimedOutError: Error, Equatable {}

///
/// Execute an operation in the current task subject to a timeout.
///
/// - Parameters:
///   - seconds: The duration in seconds `operation` is allowed to run before timing out.
///   - operation: The async operation to perform.
/// - Returns: Returns the result of `operation` if it completed in time.
/// - Throws: Throws ``TimedOutError`` if the timeout expires before `operation` completes.
///   If `operation` throws an error before the timeout expires, that error is propagated to the caller.
public func withTimeout<R: Sendable>(
  seconds: TimeInterval,
  errorToThrow: ApiError,
  operation: @escaping @Sendable () async throws -> R
) async throws -> R {
  return try await withThrowingTaskGroup(of: R.self) { group in
    let deadline = Date(timeIntervalSinceNow: seconds)
    
    // Start actual work.
    group.addTask {
      return try await operation()
    }
    // Start timeout child task.
    group.addTask {
      let interval = deadline.timeIntervalSinceNow
      if interval > 0 {
        try await Task.sleep(nanoseconds: UInt64(seconds) * NSEC_PER_SEC)
      }
      try Task.checkCancellation()
      // We’ve reached the timeout.
      throw errorToThrow
    }
    // First finished child task wins, cancel the other task.
    let result = try await group.next()!
    group.cancelAll()
    return result
  }
}

// ----------------------------------------------------------------------------
// MARK: - Array Extensions

extension Swift.Array: Swift.RawRepresentable where Element: Codable {
  public init?(rawValue: String) {
    guard let data = rawValue.data(using: .utf8),
          let result = try? JSONDecoder().decode([Element].self, from: data)
    else {
      return nil
    }
    self = result
  }
  
  public var rawValue: String {
    guard let data = try? JSONEncoder().encode(self),
          let result = String(data: data, encoding: .utf8)
    else {
      return "[]"
    }
    return result
  }
}

// ----------------------------------------------------------------------------
// MARK: - Bool Extensions

public extension Bool {
  var as1or0Int   : Int     { self ? 1 : 0 }
  var as1or0      : String  { self ? "1" : "0" }
  var asTrueFalse : String  { self ? "True" : "False" }
  var asTF        : String  { self ? "T" : "F" }
  var asOnOff     : String  { self ? "on" : "off" }
  var asPassFail  : String  { self ? "PASS" : "FAIL" }
  var asYesNo     : String  { self ? "YES" : "NO" }
}

// ----------------------------------------------------------------------------
// MARK: - CGFloat Extensions

public extension CGFloat {
  /// Force a CGFloat to be within a min / max value range
  /// - Parameters:
  ///   - min:        min CGFloat value
  ///   - max:        max CGFloat value
  /// - Returns:      adjusted value
  func bracket(_ min: CGFloat, _ max: CGFloat) -> CGFloat {
    
    var value = self
    if self < min { value = min }
    if self > max { value = max }
    return value
  }
  
  /// Create a CGFloat from a String
  /// - Parameters:
  ///   - string:     a String
  ///
  /// - Returns:      CGFloat value of String or 0
  init(_ string: String) {
    self = CGFloat(Float(string) ?? 0)
  }
  
  /// Format a String with the value of a CGFloat
  /// - Parameters:
  ///   - width:      number of digits before the decimal point
  ///   - precision:  number of digits after the decimal point
  ///   - divisor:    divisor
  /// - Returns:      a String representation of the CGFloat
  private func floatToString(width: Int, precision: Int, divisor: CGFloat) -> String {
    return String(format: "%\(width).\(precision)f", self / divisor)
  }
}

// ---------- Color Extension ----------
extension SwiftUI.Color: Swift.RawRepresentable {
  public init?(rawValue: String) {
    guard let data = Data(base64Encoded: rawValue) else {
      // invalid raw value
      return nil
    }
    
    do {
      let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) ?? .systemPink
      self = Color(color)
    } catch {
      self = .pink
    }
  }
  
  public var rawValue: String {
    do {
      let data = try NSKeyedArchiver.archivedData(withRootObject: NSColor(self), requiringSecureCoding: false) as Data
      return data.base64EncodedString()
    } catch {
      return ""
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Dictionary Extensions

//extension Dictionary: RawRepresentable where Key == String, Value == String {
//  public init?(rawValue: String) {
//    guard let data = rawValue.data(using: .utf8),  // convert from String to Data
//          let result = try? JSONDecoder().decode([String:String].self, from: data)
//    else {
//      return nil
//    }
//    self = result
//  }
//  
//  public var rawValue: String {
//    guard let data = try? JSONEncoder().encode(self),   // data is  Data type
//          let result = String(data: data, encoding: .utf8) // coerce NSData to String
//    else {
//      return "{}"  // empty Dictionary represented as String
//    }
//    return result
//  }
//}

// ----------------------------------------------------------------------------
// MARK: - FileManager Extensions

extension FileManager {
  public static func appFolder(for bundleIdentifier: String) -> URL {
    let fileManager = FileManager.default
    let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask )
    let appFolderUrl = urls.first!.appendingPathComponent( bundleIdentifier )
    
    // does the folder exist?
    if !fileManager.fileExists( atPath: appFolderUrl.path ) {
      
      // NO, create it
      do {
        try fileManager.createDirectory( at: appFolderUrl, withIntermediateDirectories: true, attributes: nil)
      } catch let error as NSError {
        fatalError("Error creating App Support folder: \(error.localizedDescription)")
      }
    }
    return appFolderUrl
  }
}

// ----------------------------------------------------------------------------
// MARK: - Float Extensions

public extension Float {
    // return the Power value of a Dbm (1 watt) value
    var powerFromDbm: Float {
        return Float( pow( Double(10.0), Double( (self - 30.0)/10.0) ) )
    }
}

// ----------------------------------------------------------------------------
// MARK: - Int Extensions

public extension Int {
  var hzToMhz: String { String(format: "%02.6f", Double(self) / 1_000_000.0) }
  func toHex(_ format: String = "0x%04X") -> String { String(format: format, self) }
}

public extension UInt16 {
  var hex: String { return String(format: "0x%04X", self) }
  func toHex(_ format: String = "0x%04X") -> String { String(format: format, self) }
}

public extension UInt32 {
  var hex: String { return String(format: "0x%08X", self) }
  func toHex(_ format: String = "0x%08X") -> String { String(format: format, self) }
}

// ----------------------------------------------------------------------------
// MARK: - NSColor Extensions

//public extension NSColor {
//  // return a float4 version of an rgba NSColor
//  var float4Color: SIMD4<Float> { return SIMD4<Float>( Float(self.redComponent),
//                                                       Float(self.greenComponent),
//                                                       Float(self.blueComponent),
//                                                       Float(self.alphaComponent))
//  }
//  // return a bgr8Unorm version of an rgba NSColor
//  var bgra8Unorm: UInt32 {
//    
//    // capture the component values (assumes that the Blue & Red are swapped)
//    //      see the Note at the top of this class
//    let alpha = UInt32( UInt8( self.alphaComponent * CGFloat(UInt8.max) ) ) << 24
//    let red = UInt32( UInt8( self.redComponent * CGFloat(UInt8.max) ) ) << 16
//    let green = UInt32( UInt8( self.greenComponent * CGFloat(UInt8.max) ) ) << 8
//    let blue = UInt32( UInt8( self.blueComponent * CGFloat(UInt8.max) ) )
//    
//    // return the UInt32 (in bgra format)
//    return alpha + red + green + blue
//  }
//}

// ----------------------------------------------------------------------------
// MARK: - NumberFormatter Extensions

extension NumberFormatter {
  public static let dotted: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.groupingSeparator = "."
    formatter.numberStyle = .decimal
    return formatter
  }()
}
//
//// ----------------------------------------------------------------------------
//// MARK: - URL Extension
//
//extension URL {
//  static let appSettings = Self
//    .applicationSupportDirectory
//    .appending(path: "appSettings.json")
//}
//
//// ----------------------------------------------------------------------------
//// MARK: - PersistenceKey Extension
//
//extension PersistenceKey
//where Self == PersistenceKeyDefault<
//  FileStorageKey<AppSettings>
//> {
//  public static var appSettings: Self {
//    PersistenceKeyDefault(
//      .fileStorage(),
//      AppSettings()
//    )
//  }
//}

// ----------------------------------------------------------------------------
// MARK: - String Extensions

public extension String {
  var bValue          : Bool            { (Int(self) ?? 0) == 1 ? true : false }
  var cgValue         : CGFloat         { CGFloat(self) }
  var dValue          : Double          { Double(self) ?? 0 }
  var fValue          : Float           { Float(self) ?? 0 }
  var handle          : UInt32?         { self.hasPrefix("0x") ? UInt32(String(self.dropFirst(2)), radix: 16) : UInt32(self, radix: 16) }
  var iValue          : Int             { Int(self) ?? 0 }
  var iValueOpt       : Int?            { self == "-1" ? nil : Int(self) }
  var list            : [String]        { self.components(separatedBy: ",") }
  var mhzToHz         : Int             { Int( (Double(self) ?? 0) * 1_000_000 ) }
  var objectId        : UInt32?         { UInt32(self, radix: 10) }
  var sequenceNumber  : Int             { Int(self, radix: 10) ?? 0 }
  var streamId        : UInt32?         { self.hasPrefix("0x") ? UInt32(String(self.dropFirst(2)), radix: 16) : UInt32(self, radix: 16) }
  var trimmed         : String          { self.trimmingCharacters(in: CharacterSet.whitespaces) }
  var tValue          : Bool            { self.lowercased() == "true" ? true : false }
  var uValue          : UInt            { UInt(self) ?? 0 }
  var uValue32        : UInt32          { UInt32(self) ?? 0 }
  
  var toMhz           : String          {
    if let doubleFreq = Double(self) {
      switch doubleFreq {
      case 1..<75:                    // MHz
        return String(doubleFreq)
      case 1_000..<75_000:            // KHz
        return String(doubleFreq / 1_000)
      case 1_000_000..<75_000_000:    // Hz
        return String(doubleFreq / 1_000_000)
      default:
        return ""
      }
    } else {
      return ""
    }
  }
  
  var isValidFrequency: Bool {
    let digitsCharacters = CharacterSet(charactersIn: "0123456789.")
    return CharacterSet(charactersIn: self).isSubset(of: digitsCharacters) && self.filter{ $0 == "."}.count <= 1
  }
  
  /// Parse a String of <key=value>'s separated by the given Delimiter
  /// - Parameters:
  ///   - delimiter:          the delimiter between key values (defaults to space)
  ///   - keysToLower:        convert all Keys to lower case (defaults to YES)
  ///   - valuesToLower:      convert all values to lower case (defaults to NO)
  /// - Returns:              a KeyValues array
  func keyValuesArray(delimiter: String = " ", keysToLower: Bool = true, valuesToLower: Bool = false) -> KeyValuesArray {
    var kvArray = KeyValuesArray()
    
    // split it into an array of <key=value> values
    let keyAndValues = self.components(separatedBy: delimiter)
    
    for index in 0..<keyAndValues.count {
      // separate each entry into a Key and a Value
      var kv = keyAndValues[index].components(separatedBy: "=")
      
      // when "delimiter" is last character there will be an empty entry, don't include it
      if kv[0] != "" {
        // if no "=", set value to empty String (helps with strings with a prefix to KeyValues)
        // make sure there are no whitespaces before or after the entries
        if kv.count == 1 {
          
          // remove leading & trailing whitespace
          kvArray.append( (kv[0].trimmingCharacters(in: NSCharacterSet.whitespaces),"") )
        }
        if kv.count == 2 {
          // lowercase as needed
          if keysToLower { kv[0] = kv[0].lowercased() }
          if valuesToLower { kv[1] = kv[1].lowercased() }
          
          // remove leading & trailing whitespace
          kvArray.append( (kv[0].trimmingCharacters(in: NSCharacterSet.whitespaces), kv[1].trimmingCharacters(in: NSCharacterSet.whitespaces)) )
        }
      }
    }
    return kvArray
  }
  
  func padRight(_ length: Int, _ char: String = " ") -> String {
    self.padding(toLength: length, withPad: char, startingAt: 0)
  }
  
  /// Parse a String of <value>'s separated by the given Delimiter
  /// - Parameters:
  ///   - delimiter:          the delimiter between values (defaults to space)
  ///   - valuesToLower:      convert all values to lower case (defaults to NO)
  /// - Returns:              a values array
  func valuesArray(delimiter: String = " ", valuesToLower: Bool = false) -> ValuesArray {
    guard self != "" else {return [String]() }
    
    // split it into an array of <value> values, lowercase as needed
    var array = valuesToLower ? self.components(separatedBy: delimiter).map {$0.lowercased()} : self.components(separatedBy: delimiter)
    array = array.map { $0.trimmingCharacters(in: .whitespaces) }
    
    return array
  }
  
  /// Replace spaces with a specified value
  /// - Parameters:
  ///   - value:      the String to replace spaces
  /// - Returns:      the adjusted String
  func replacingSpaces(with value: String = "\u{007F}") -> String {
    return self.replacingOccurrences(of: " ", with: value)
  }
  
  enum TruncationPosition {
    case head
    case middle
    case tail
  }
  
  func truncated(limit: Int, position: TruncationPosition = .tail, leader: String = "...") -> String {
    guard self.count > limit else { return self }
    
    switch position {
    case .head:
      return leader + self.suffix(limit)
    case .middle:
      let headCharactersCount = Int(ceil(Float(limit - leader.count) / 2.0))
      
      let tailCharactersCount = Int(floor(Float(limit - leader.count) / 2.0))
      
      return "\(self.prefix(headCharactersCount))\(leader)\(self.suffix(tailCharactersCount))"
    case .tail:
      return self.prefix(limit) + leader
    }
  }
  
  /// Replace spaces and equal signs in a CWX Macro with alternate characters
  /// - Returns:      the String after processing
  func fix(spaceReplacement: String = "\u{007F}", equalsReplacement: String = "*") -> String {
    var newString: String = ""
    var quotes = false
    
    // We could have spaces inside quotes, so we have to convert them to something else for key/value parsing.
    // We could also have an equal sign '=' (for Prosign BT) inside the quotes, so we're converting to a '*' so that the split on "="
    // will still work.  This will prevent the character '*' from being stored in a macro.  Using the ascii byte for '=' will not work.
    for char in self {
      if char == "\"" {
        quotes = !quotes
        
      } else if char == " " && quotes {
        newString += spaceReplacement
        
      } else if char == "=" && quotes {
        newString += equalsReplacement
        
      } else {
        newString.append(char)
      }
    }
    return newString
  }
  
  /// Undo any changes made to a Cwx Macro string by the fix method    ///
  /// - Returns:          the String after undoing the fixString changes
  func unfix(spaceReplacement: String = "\u{007F}", equalsReplacement: String = "*") -> String {
    var newString: String = ""
    
    for char in self {
      if char == Character(spaceReplacement) {
        newString += " "
        
      } else if char == Character(equalsReplacement) {
        newString += "="
        
      } else {
        newString.append(char)
      }
    }
    return newString
  }
}

// ----------------------------------------------------------------------------
// MARK: - URL Extensions

extension URL {
  public static var appSupport : URL { return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first! }
}

// ----------------------------------------------------------------------------
// MARK: - Version Extensions

extension Version {
  // Flex6000 specific versions
  public var isV3: Bool { major >= 3 }
  public var isV2NewApi: Bool { major == 2 && minor >= 5 }
  public var isGreaterThanV22: Bool { major >= 2 && minor >= 2 }
  public var isV2: Bool { major == 2 && minor < 5 }
  public var isV1: Bool { major == 1 }
  
  public var isNewApi: Bool { isV3 || isV2NewApi }
  public var isOldApi: Bool { isV1 || isV2 }
}

// ----------------------------------------------------------------------------
// MARK: - View Extensions

//extension View {
//  public func cursor(_ cursor: NSCursor) -> some View {
//    if #available(macOS 13.0, *) {
//      return self.onContinuousHover { phase in
//        switch phase {
//        case .active(let p):
//          
//          print("p = \(p)")
//          cursor.push()
//        case .ended:
//          NSCursor.pop()
//        }
//      }
//    } else {
//      return self.onHover { inside in
//        if inside {
//          cursor.push()
//        } else {
//          NSCursor.pop()
//        }
//      }
//    }
//  }
//}

// ----------------------------------------------------------------------------
// MARK: - Property Wrappers

@propertyWrapper
final public class Atomic<Value> {
    private let queue = DispatchQueue(label: "net.k3tzr.atomic", qos: .userInitiated, attributes: [.concurrent])
    private var value: Value

    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    public var wrappedValue: Value {
        get {
            queue.sync { value }
        }
        set {
            queue.sync(flags: .barrier) { value = newValue }
        }
    }

    public func mutate(_ mutation: (inout Value) -> Void) {
        return queue.sync(flags: .barrier)  { mutation(&value) }
    }
}
