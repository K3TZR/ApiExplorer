//
//  Profile.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 8/17/17.
//  Copyright © 2017 Douglas Adams. All rights reserved.
//

import Foundation

//import SharedFeature



@MainActor
@Observable
public final class Profile {
  // ------------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(_ id: String) {
    self.id = id
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public properties

  public let id: String
  
  public var current: String = ""
  public var list = [String]()

  // ----------------------------------------------------------------------------
  // MARK: - Public types
  
  public enum Property: String {
    case list = "list"
    case current = "current"
  }

  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
  private var _initialized = false

  // ----------------------------------------------------------------------------
  // MARK: - Public Static status method
  
  public static func status(_ objectModel: ObjectModel, _ properties: KeyValuesArray, _ inUse: Bool) {
    // get the id
    let id = properties[0].key
    let index = objectModel.profiles.firstIndex(where: { $0.id == id })
    // is it in use?
    if inUse {
      // YES, add it if not already present
      if index == nil {
        objectModel.profiles.append(Profile(id))
        objectModel.profiles.last!.parse(properties)
      } else {
        // parse the properties
        objectModel.profiles[index!].parse(properties)
      }
      
    } else {
      // NO, remove it
      objectModel.profiles.remove(at: index!)
      log.debug("Tnf \(id): REMOVED")
    }
  }

  // ----------------------------------------------------------------------------
  // MARK: - Public Static command methods
  
  /* ----- from the FlexApi source -----
   "profile transmit save \"" + profile_name.Replace("*","") + "\""
   "profile transmit create \"" + profile_name.Replace("*", "") + "\""
   "profile transmit reset \"" + profile_name.Replace("*", "") + "\""
   "profile transmit delete \"" + profile_name.Replace("*", "") + "\""
   "profile mic delete \"" + profile_name.Replace("*","") + "\""
   "profile mic save \"" + profile_name.Replace("*", "") + "\""
   "profile mic reset \"" + profile_name.Replace("*", "") + "\""
   "profile mic create \"" + profile_name.Replace("*", "") + "\""
   "profile global save \"" + profile_name + "\""
   "profile global delete \"" + profile_name + "\""
   
   "profile mic load \"" + _profileMICSelection + "\""
   "profile tx load \"" + _profileTXSelection + "\""
   "profile global load \"" + _profileGlobalSelection + "\""
   
   "profile global info"
   "profile tx info"
   "profile mic info"
   */

  // ----------------------------------------------------------------------------
  // MARK: - Public Parse methods
  
  /// Parse Profile key/value pairs
  /// - Parameter statusMessage:       String
  public func parse(_ properties: KeyValuesArray) {
    let components = properties[0].key.components(separatedBy: " ")

    // check for unknown Key
    guard let token = Profile.Property(rawValue: components[1]) else {
      // log it and ignore the Key
      log.warning("Profile: unknown property, \(properties[1].key)")
      return
    }
    // known keys
    switch token {
    case .list:
      if properties.count < 2 {
        list = []
      } else {
        list = properties[1].key.valuesArray(delimiter: "^")
      }
//      print("---->>>> list =", list)

    case .current:
      if properties.count < 2 {
        current = ""
      } else {
        current = properties[1].key
      }
//      print("---->>>> current =", current)

    }
    // is it initialized?
    if _initialized == false {
      // NO, it is now
      _initialized = true
      log.debug("Profile: ADDED")
    }
  }
}
