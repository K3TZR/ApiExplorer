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
    
    if viewModel.api.panadapters.count == 0 {
      VStack(alignment: .leading) {
        HStack(spacing: 20) {
          Text("PANADAPTER").frame(width: 110, alignment: .leading)
          Text("----- NONE PRESENT -----").foregroundColor(.red)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment

      
    } else {
      ForEach(viewModel.api.panadapters, id: \.id) { panadapter in
        
        if panadapter.clientHandle == handle {
          
          VStack(alignment: .leading) {
            
          // Panadapter
            PanadapterDetailView(panadapter: panadapter)
            
            // corresponding Waterfall
            ForEach(viewModel.api.waterfalls.filter { $0.panadapterId == panadapter.id} ) { waterfall in
              WaterfallDetailView(waterfall: waterfall)
            }
            
            // corresponding Slice(s)
            ForEach(viewModel.api.slices.filter { $0.panadapterId == panadapter.id}) { slice in
              SliceDetailView(slice: slice)
              
              // slice meter(s)
              if showMeters { SliceMeterSubView(sliceId: slice.id, sliceClientHandle: slice.clientHandle, handle: handle) }
            }
          }
          .padding(.bottom, 20)
          .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
        }
      }
    }
  }
}

private struct PanadapterDetailView: View {
  var panadapter: Panadapter
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      
      GridRow {
        Text("PANADAPTER")
          .frame(width: 110, alignment: .leading)

        Text("ID")
        Text(panadapter.id.hex)
          .foregroundColor(.secondary)
          .gridColumnAlignment(.trailing)
        
        Text("Bandwidth")
        Text(panadapter.bandwidth, format: .number)
          .foregroundColor(.secondary)
          .gridColumnAlignment(.trailing)
        
        Text("Center")
        Text(panadapter.center, format: .number)
          .foregroundColor(.secondary)
          .gridColumnAlignment(.trailing)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
  }
}

private struct WaterfallDetailView: View {
  var waterfall: Waterfall
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        Text("WATERFALL")
          .frame(width: 110, alignment: .trailing)

        Text("ID")
        Text(waterfall.id.hex)
          .foregroundColor(.secondary)
          .gridColumnAlignment(.trailing)

        Text("Auto Black")
        Text("\(waterfall.autoBlackEnabled ? "Y" : "N")")
          .foregroundColor(waterfall.autoBlackEnabled ? .green : .red)
          .gridColumnAlignment(.trailing)

        Text("Color Gain")
        Text(waterfall.colorGain, format: .number)
          .foregroundColor(.secondary)
          .gridColumnAlignment(.trailing)

        Text("Black Level")
        Text(waterfall.blackLevel, format: .number)
          .foregroundColor(.secondary)
          .gridColumnAlignment(.trailing)

        Text("Duration")
        Text(waterfall.lineDuration, format: .number)
          .foregroundColor(.secondary)
          .gridColumnAlignment(.trailing)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
  }
}

private struct SliceDetailView: View {
  var slice: Slice
  
  var body: some View {
    
    Grid(alignment: .leading, horizontalSpacing: 10) {
      GridRow {
        Text("SLICE")
          .frame(width: 110, alignment: .trailing)
        
        Text("ID")
        Text(slice.id.hex)
          .foregroundColor(.secondary)
          .gridColumnAlignment(.trailing)
        
        Text("Freq")        
        Text("\(slice.frequency)")
          .foregroundColor(.secondary)
          .gridColumnAlignment(.trailing)        
        
        Text("Mode")
        Text("\(slice.mode)")
          .foregroundColor(.secondary)
        
        Text("Rx Ant")
          .gridColumnAlignment(.leading)
        
        Text("\(slice.rxAnt)")
          .foregroundColor(.secondary)
        
        Text("Tx Ant")
          .gridColumnAlignment(.leading)
        
        Text("\(slice.txAnt)")
          .foregroundColor(.secondary)

        Text("DAX_channel")
        Text("\(slice.daxChannel)")
          .foregroundColor(.secondary)
        
        Text("DAX_clients")
        Text("\(slice.daxClients)")
          .foregroundColor(.secondary)
        
        Text("Low")
        Text("\(slice.filterLow)")
          .foregroundColor(.secondary)
          .gridColumnAlignment(.trailing)

        Text("High")
        Text("\(slice.filterHigh)")
          .foregroundColor(.secondary)
          .gridColumnAlignment(.trailing)

        Text("Active")
        Text("\(slice.active ? "Y" : "N")")
          .foregroundColor(slice.active ? .green : .red)
        
        Text("Locked")
        Text("\(slice.locked ? "Y" : "N")")
          .foregroundColor(slice.locked ? .green : .red)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  PanadapterSubView(handle: 1, showMeters: true)
    .environment(ViewModel(SettingsModel()))
  
    .frame(minWidth: 1000)
}
