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
          
          VStack(alignment: .leading) {
            // Panadapter
            PanadapterDetailView(panadapter: panadapter)
            
            // corresponding Waterfall
            ForEach(viewModel.objectModel.waterfalls.filter { $0.panadapterId == panadapter.id} ) { waterfall in
              WaterfallDetailView(waterfall: waterfall)
            }
            
            //          // corresponding Slice(s)
            //          ForEach(viewModel.objects.slices.filter { $0.panadapterId == panadapter.id}) { slice in
            //            SliceDetailView(slice: slice)
            //
            //            // slice meter(s)
            //            if showMeters { MeterSubView(sliceId: slice.id, sliceClientHandle: slice.clientHandle, handle: handle) }
            //          }
          }
        }
      }
    }
  }
}

private struct PanadapterDetailView: View {
  var panadapter: Panadapter
  
  var body: some View {
    HStack(spacing: 20) {
      
      Text("PANADAPTER").frame(width: 100, alignment: .leading)
      
      HStack(spacing: 5) {
        Text("ID")
        Text(panadapter.id.hex).padding(.leading, 5).foregroundColor(.secondary)
      }
      
      HStack(spacing: 5) {
        Text("Bandwidth")
        Text(panadapter.bandwidth, format: .number).foregroundColor(.secondary)
      }
      
      HStack(spacing: 5) {
        Text("Center")
        Text(panadapter.center, format: .number).foregroundColor(.secondary)
      }
      Spacer()
    }
  }
}

private struct WaterfallDetailView: View {
  var waterfall: Waterfall
  
  var body: some View {
    HStack(spacing: 20) {
      Text("WATERFALL").frame(width: 100, alignment: .leading)
      
      HStack(spacing: 5) {
        Text("ID")
        Text(waterfall.id.hex).padding(.leading, 5).foregroundColor(.secondary)
      }
      
      HStack(spacing: 5) {
        Text("Auto Black")
        Text("\(waterfall.autoBlackEnabled ? "ON" : "OFF")").foregroundColor(.secondary)
      }

      HStack(spacing: 5) {
        Text("Color Gain")
        Text(waterfall.colorGain, format: .number).foregroundColor(.secondary)
      }
      
      HStack(spacing: 5) {
        Text("Black Level")
        Text(waterfall.blackLevel, format: .number).foregroundColor(.secondary)
      }
      
      HStack(spacing: 5) {
        Text("Duration")
        Text(waterfall.lineDuration, format: .number).foregroundColor(.secondary)
      }
      Spacer()
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
    VStack(alignment: .leading) {
      HStack(spacing: 20) {
        HStack(spacing: 5) {
          Text("SLICE")
        }.frame(width: 80, alignment: .leading)
        
        Text(String(format: "%02d", slice.id)).foregroundColor(.secondary)
        
        Text("\(slice.frequency)").foregroundColor(.secondary).frame(width: 105, alignment: .trailing)
        
        Group {
          HStack(spacing: 5) {
            Text("Mode")
            Text("\(slice.mode)").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Rx Ant")
            Text("\(slice.rxAnt)").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Tx Ant")
            Text("\(slice.txAnt)").foregroundColor(.secondary)
          }
        }.frame(width: 100, alignment: .leading)
        
        Group {
          HStack(spacing: 5) {
            Text("Low")
            Text("\(slice.filterLow)").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("High")
            Text("\(slice.filterHigh)").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Active")
            Text("\(slice.active ? "Yes" : "No")").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Locked")
            Text("\(slice.locked ? "Yes" : "No")").foregroundColor(.secondary)
          }

        }.frame(width: 100, alignment: .leading)
      }
      HStack(spacing: 20) {
        Text("").frame(width: 80, alignment: .leading)
        
        Group {
          HStack(spacing: 5) {
            Text("DAX_channel")
            Text("\(slice.daxChannel)").foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("DAX_clients")
            Text("\(slice.daxClients)").foregroundColor(.secondary)
          }
        }.frame(width: 100, alignment: .leading)
        
        Group {
          HStack(spacing: 5) {
            Text("Rx Ant List")
            Text(stringArrayToString(slice.rxAntList)).foregroundColor(.secondary)
          }
          
          HStack(spacing: 5) {
            Text("Tx Ant List")
            Text(stringArrayToString(slice.txAntList)).foregroundColor(.secondary)
          }
        }.frame(width: 340, alignment: .leading)
      }
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
