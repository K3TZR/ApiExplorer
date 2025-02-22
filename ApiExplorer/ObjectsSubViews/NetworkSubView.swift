//
//  NetworkSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 10/3/22.
//

import SwiftUI

//import FlexApiFeature
//import VitaFeature

// ----------------------------------------------------------------------------
// MARK: - View

//public struct NetworkSubView: View {
//
//  public var body: some View {
//      Grid (alignment: .leading) {
//        GridRow {
//          Text("NETWORK")
//            .frame(width: 100, alignment: .leading)
//            .foregroundColor(.yellow)
//          
//          Text("Stream")
//          Text("Packets")
//          Text("Errors")
//          Text("Error PerCent")
//          Spacer()
//        }
//
//        ForEach(StreamStatistics.shared.stats) { stream in
//          DetailView(stream: stream)
//        }
//      }
//  }
//}
//
//private struct DetailView: View {
//  @ObservedObject var stream: StreamStatus
//  @State var throttledPackets: Int = 0
//  
//  var errorPerCent: Float {
//    if stream.errors == 0 { return 0 }
//    return Float(stream.errors) / Float(stream.packets)
//  }
//  
//  var body: some View {
//    GridRow {
//      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
//      Text(stream.type.description())
//      Group {
//        Text(throttledPackets.formatted(.number))
//        Text(stream.errors.formatted(.number))
//        Text(errorPerCent.formatted(.percent.precision(.fractionLength(4))))
//      }
//      .foregroundColor(.secondary)
//      .gridColumnAlignment(.trailing)
//    }
//    
//    .onReceive(stream.$packets.throttle(for: 1, scheduler: RunLoop.main, latest: true) ) {
//      self.throttledPackets = $0
//    }
//  }
//}
//
//
//// ----------------------------------------------------------------------------
//// MARK: - Preview
//
//#Preview {
//  NetworkSubView()
//}
