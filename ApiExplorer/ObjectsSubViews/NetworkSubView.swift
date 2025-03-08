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
    
    Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 0) {
      GridRow {
        Text("NETWORK")
          .frame(width: 110, alignment: .leading)
        
        Text("Stream")
        Text("Packets")
        Text("Errors")
        Text("Error PerCent")
        Spacer()
      }
      
      DetailView(streamModel: viewModel.api.streamModel!)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct DetailView: View {
  @ObservedObject var streamModel: StreamModel

  @State var throttledPackets: Int = 0
  
//  var errorPerCent: Float {
//    if stream.errors == 0 { return 0 }
//    return Float(stream.errors) / Float(stream.packets)
//  }
  
  var body: some View {
   
    GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
      Text(streamModel.stats[6].type.rawValue)
      Group {
        Text(throttledPackets.formatted(.number))
//        Text(stream.errors.formatted(.number))
//        Text(errorPerCent.formatted(.percent.precision(.fractionLength(4))))
      }
      .foregroundColor(.secondary)
      .gridColumnAlignment(.trailing)
    }
    
    .onReceive(streamModel.$stats.throttle(for: 1, scheduler: RunLoop.main, latest: true) ) {
      self.throttledPackets = $0[6].packets
    }
  }
}


// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  NetworkSubView()
}
