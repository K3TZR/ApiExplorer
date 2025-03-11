//
//  NetworkSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 10/3/22.
//

import SwiftUI

import ApiPackage
//import VitaFeature

// ----------------------------------------------------------------------------
// MARK: - View

public struct NetworkSubView: View {
  
  @Environment(ViewModel.self) private var viewModel
  
  public var body: some View {
    
    VStack(alignment: .leading) {
      Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 0) {
        GridRow {
          Text("NETWORK")
            .frame(width: 110, alignment: .leading)
          
          Text("Stream")
          Text("Packets")
          Text("Errors")
          Text("Error PerCent")
        }
        DetailView(streamModel: viewModel.api.streamModel!)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

private struct DetailView: View {
  @ObservedObject var streamModel: StreamModel

  @State var throttledStats: [StreamStatus] = [
    StreamStatus(.daxAudio),            // = 0
    StreamStatus(.daxAudioReducedBw),   // = 1
    StreamStatus(.daxIq24),             // = 2
    StreamStatus(.daxIq48),             // = 3
    StreamStatus(.daxIq96),             // = 4
    StreamStatus(.daxIq192),            // = 5
    StreamStatus(.meter),               // = 6
    StreamStatus(.opus),                // = 7
    StreamStatus(.panadapter),          // = 8
    StreamStatus(.waterfall),           // = 9
  ]
  
  func errorPerCent(_ packets: Int, _ errors: Int) -> Float {
    if packets == 0 { return 0 }
    return Float(errors) / Float(packets)
  }
  
  var body: some View {
   
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
      Text(streamModel.stats[6].type.rawValue)
      Group {
        Text(throttledStats[6].packets.formatted(.number))
        Text(throttledStats[6].errors.formatted(.number))
        Text(errorPerCent(throttledStats[6].errors, throttledStats[6].packets).formatted(.percent.precision(.fractionLength(4))))
      }
      .foregroundColor(.secondary)
      .gridColumnAlignment(.trailing)
    }
    
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
      Text(streamModel.stats[8].type.rawValue)
      Group {
        Text(throttledStats[8].packets.formatted(.number))
        Text(throttledStats[8].errors.formatted(.number))
        Text(errorPerCent(throttledStats[8].errors, throttledStats[6].packets).formatted(.percent.precision(.fractionLength(4))))
      }
      .foregroundColor(.secondary)
      .gridColumnAlignment(.trailing)
    }

    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
      Text(streamModel.stats[9].type.rawValue)
      Group {
        Text(throttledStats[9].packets.formatted(.number))
        Text(throttledStats[9].errors.formatted(.number))
        Text(errorPerCent(throttledStats[9].errors, throttledStats[9].packets).formatted(.percent.precision(.fractionLength(4))))
      }
      .foregroundColor(.secondary)
      .gridColumnAlignment(.trailing)
    }

    .onReceive(streamModel.$stats.throttle(for: 1, scheduler: RunLoop.main, latest: true) ) {
      self.throttledStats = $0
    }
  }
}


// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  NetworkSubView()
    .environment(ViewModel())

    .frame(minWidth: 1000)
}
