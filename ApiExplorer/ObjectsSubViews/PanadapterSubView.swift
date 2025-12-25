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
  let filters: Set<String>
  
  @Environment(ViewModel.self) var viewModel
  
  var body: some View {
    
    let panadapters = viewModel.api.panadapters
    
    if panadapters.isEmpty {
      VStack(alignment: .leading) {
        HStack(spacing: 20) {
          Text("PANADAPTER").frame(width: 110, alignment: .leading)
            .foregroundStyle(.yellow)
          Text("----- NONE PRESENT -----").foregroundStyle(.red)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
      .textSelection(.enabled)
      
      
    } else {
      ForEach(panadapters, id: \.id) { panadapter in
        
        if panadapter.clientHandle == handle {
          
          VStack(alignment: .leading) {
            
            // Panadapter
            if filters.contains(StationObjectFilter.panadapters.rawValue) {
              PanadapterDetailView(panadapter: panadapter)
            }
            
            // corresponding Waterfall
            ForEach(viewModel.api.waterfalls.filter { $0.panadapterId == panadapter.id} ) { waterfall in
              if filters.contains(StationObjectFilter.waterfalls.rawValue) {
                WaterfallDetailView(waterfall: waterfall)
              }
            }
            
            // corresponding Slice(s)
            ForEach(viewModel.api.slices.filter { $0.panadapterId == panadapter.id}) { slice in
              if filters.contains(StationObjectFilter.slices.rawValue) {
                SliceDetailView(slice: slice)
              }
              
              // corresponding Slice Meters
              if filters.contains(StationObjectFilter.meters.rawValue) {
                // slice meter(s)
                SliceMeterSubView(sliceId: slice.id, sliceClientHandle: slice.clientHandle, handle: handle) }
            }
          }
          .padding(.bottom, 20)
          .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
          .textSelection(.enabled)
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
          .foregroundStyle(.yellow)

        Text("ID")
        Text(panadapter.id.hex)
          .foregroundStyle(.secondary)
          .gridColumnAlignment(.trailing)
        
        Text("Bandwidth")
        Text(panadapter.bandwidth, format: .number)
          .foregroundStyle(.secondary)
          .monospacedDigit()
          .gridColumnAlignment(.trailing)
        
        Text("Center")
        Text(panadapter.center, format: .number)
          .foregroundStyle(.secondary)
          .monospacedDigit()
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
          .foregroundStyle(.yellow)

        Text("ID")
        Text(waterfall.id.hex)
          .foregroundStyle(.secondary)
          .gridColumnAlignment(.trailing)
        
        Text("Auto Black")
        Text("\(waterfall.autoBlackEnabled ? "Y" : "N")")
          .foregroundStyle(waterfall.autoBlackEnabled ? .green : .red)
          .gridColumnAlignment(.trailing)
        
        Text("Color Gain")
        Text(waterfall.colorGain, format: .number)
          .foregroundStyle(.secondary)
          .monospacedDigit()
          .gridColumnAlignment(.trailing)
        
        Text("Black Level")
        Text(waterfall.blackLevel, format: .number)
          .foregroundStyle(.secondary)
          .monospacedDigit()
          .gridColumnAlignment(.trailing)
        
        Text("Duration")
        Text(waterfall.lineDuration, format: .number)
          .foregroundStyle(.secondary)
          .monospacedDigit()
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
          .foregroundStyle(.yellow)

        Text("ID")
        Text(slice.id.hex)
          .foregroundStyle(.secondary)
          .gridColumnAlignment(.trailing)
        
        Text("Freq")
        Text("\(slice.frequency)")
          .foregroundStyle(.secondary)
          .monospacedDigit()
          .gridColumnAlignment(.trailing)
        
        Text("Mode")
        Text("\(slice.mode)")
          .foregroundStyle(.secondary)
        
        Text("Rx Ant")
          .gridColumnAlignment(.leading)
        
        Text("\(slice.rxAnt)")
          .foregroundStyle(.secondary)
        
        Text("Tx Ant")
          .gridColumnAlignment(.leading)
        
        Text("\(slice.txAnt)")
          .foregroundStyle(.secondary)
        
        Text("DAX_channel")
        Text("\(slice.daxChannel)")
          .foregroundStyle(.secondary)
          .monospacedDigit()
        
        Text("DAX_clients")
        Text("\(slice.daxClients)")
          .foregroundStyle(.secondary)
          .monospacedDigit()
        
        Text("Low")
        Text("\(slice.filterLow)")
          .foregroundStyle(.secondary)
          .monospacedDigit()
          .gridColumnAlignment(.trailing)
        
        Text("High")
        Text("\(slice.filterHigh)")
          .foregroundStyle(.secondary)
          .monospacedDigit()
          .gridColumnAlignment(.trailing)
        
        Text("Active")
        Text("\(slice.active ? "Y" : "N")")
          .foregroundStyle(slice.active ? .green : .red)
        
        Text("Locked")
        Text("\(slice.locked ? "Y" : "N")")
          .foregroundStyle(slice.locked ? .green : .red)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  PanadapterSubView(handle: 1, filters: [])
    .environment(ViewModel(SettingsModel()))
  
    .frame(minWidth: 1000)
}

