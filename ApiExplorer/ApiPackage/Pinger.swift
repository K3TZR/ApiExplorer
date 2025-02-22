//
//  Pinger.swift
//  FlexApiFeature/Objects
//
//  Created by Douglas Adams on 12/14/16.
//  Copyright © 2018 Douglas Adams & Mario Illgen. All rights reserved.
//

import Foundation
import SwiftUI

///  Pinger  implementation
///
///      generates "ping" messages every pingInterval second(s)
///
@MainActor
public final class Pinger {
  // ----------------------------------------------------------------------------
  // MARK: - Initialization
  
  public init(pingInterval: Int = 1, _ objectModel: ObjectModel) {
    _objectModel = objectModel

    // create the timer's dispatch source
    _pingTimer = DispatchSource.makeTimerSource(queue: _pingQ)

    // Setup the timer
    _pingTimer.schedule(deadline: DispatchTime.now(), repeating: .seconds(pingInterval))

    // set the event handler
    _pingTimer.setEventHandler(handler: { [self] in
//      Task { await MainActor.run {_objectModel.sendTcp("ping") }}
        Task { _objectModel.sendTcp("ping") }
    })
    // start the timer
    _pingTimer.resume()
  }
  
  // ----------------------------------------------------------------------------
  // MARK: - Private properties
  
//  private nonisolated let _objectModel: ObjectModel
  private let _objectModel: ObjectModel
  private let _pingQ = DispatchQueue(label: "PingQ")
  private let _pingTimer: DispatchSourceTimer!
}
