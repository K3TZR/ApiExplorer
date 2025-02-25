//
//  PanadapterSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/24/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct PanadapterSubView: View {
  let handle: UInt32
  let showMeters: Bool
  
  @Environment(ViewModel.self) var viewModel
  
  var body: some View {
    
    if viewModel.objectModel.panadapters.count == 0 {
      HStack(spacing: 20) {
        Text("PANADAPTER").frame(width: 100, alignment: .leading)
        Text("None present").foregroundColor(.red)
      }
      
    } else {
      ForEach(viewModel.objectModel.panadapters, id: \.id) { panadapter in
        
        if panadapter.clientHandle == handle {
          
          Grid(alignment: .trailing, horizontalSpacing: 20, verticalSpacing: 0) {
            // Panadapter
            PanadapterDetailView(panadapter: panadapter)
            
            // corresponding Waterfall
            ForEach(viewModel.objectModel.waterfalls.filter { $0.panadapterId == panadapter.id} ) { waterfall in
              WaterfallDetailView(waterfall: waterfall)
            }
            
            // corresponding Slice(s)
            ForEach(viewModel.objectModel.slices.filter { $0.panadapterId == panadapter.id}) { slice in
              SliceDetailView(slice: slice)
//              
//              //            // slice meter(s)
//              //            if showMeters { MeterSubView(sliceId: slice.id, sliceClientHandle: slice.clientHandle, handle: handle) }
            }
          }
        }
      }
    }
  }
}

private struct PanadapterDetailView: View {
  var panadapter: Panadapter
  
  var body: some View {
    
    GridRow {
      Text("PANADAPTER")
        .gridColumnAlignment(.leading)
      
      Text("ID")
        .gridColumnAlignment(.leading)
      Text(panadapter.id.hex).foregroundColor(.secondary)
      
      Text("Bandwidth")
        .gridColumnAlignment(.leading)
      Text(panadapter.bandwidth, format: .number).foregroundColor(.secondary)
      
      Text("Center")
        .gridColumnAlignment(.leading)
      Text(panadapter.center, format: .number).foregroundColor(.secondary)
    }
  }
}

private struct WaterfallDetailView: View {
  var waterfall: Waterfall
  
  var body: some View {
    GridRow {
      Text("WATERFALL")
      
      Text("ID")
      Text(waterfall.id.hex).foregroundColor(.secondary)
      
      Text("Auto Black")
      Text("\(waterfall.autoBlackEnabled ? "Y" : "N")").foregroundColor(waterfall.autoBlackEnabled ? .green : .red)
      
      Text("Color Gain")
      Text(waterfall.colorGain, format: .number).foregroundColor(.secondary)
      
      Text("Black Level")
      Text(waterfall.blackLevel, format: .number).foregroundColor(.secondary)
      
      Text("Duration")
      Text(waterfall.lineDuration, format: .number).foregroundColor(.secondary)
    }
  }
}

private struct SliceDetailView: View {
  var slice: Slice
  
  func stringArrayToString( _ list: [String]?) -> String {
    
    guard list != nil else { return "Unknown"}
    let str = list!.reduce("") {$0 + $1 + ", "}
    return String(str.dropLast(2))
  }
  
  var body: some View {
    
    GridRow {
      Text("SLICE")
      
      Text("ID")
      Text(String(format: "%02d", slice.id)).foregroundColor(.secondary)
      
      Text("Freq")
      Text("\(slice.frequency)").foregroundColor(.secondary)
      
      Text("Mode")
      Text("\(slice.mode)").foregroundColor(.secondary)
      
      Text("Rx Ant")
        .gridColumnAlignment(.leading)
      Text("\(slice.rxAnt)").foregroundColor(.secondary)
      
      Text("Tx Ant")
        .gridColumnAlignment(.leading)
      Text("\(slice.txAnt)").foregroundColor(.secondary)
      
      
    }
    
    GridRow {
      Text("SLICE").hidden()
      
      Text("DAX_channel")
      Text("\(slice.daxChannel)").foregroundColor(.secondary)
      
      Text("DAX_clients")
      Text("\(slice.daxClients)").foregroundColor(.secondary)
      
      Text("Low")
      Text("\(slice.filterLow)").foregroundColor(.secondary)
      
      Text("High")
      Text("\(slice.filterHigh)").foregroundColor(.secondary)
      
      Text("Active")
      Text("\(slice.active ? "Y" : "N")").foregroundColor(slice.active ? .green : .red)
      
      Text("Locked")
        .gridColumnAlignment(.leading)
      Text("\(slice.locked ? "Y" : "N")").foregroundColor(slice.locked ? .green : .red)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  PanadapterSubView(handle: 1, showMeters: true)
    .environment(ViewModel())
  
    .frame(minWidth: 1250)
}
