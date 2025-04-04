//
//  GuiClientSubView.swift
//  SDRApi/ObjectsSubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct GuiClientSubView: View {
  let radio: Radio?
  
  @Environment(ViewModel.self) private var viewModel
  
//  private var guiClients: [GuiClient] {
//    if let radioId = viewModel.api.activeSelection?.radioId {
//      if let radio = viewModel.api.radios.first(where: { $0.id == radioId }) {
//        return radio.guiClients
//      }
//    }
//    return []
//  }
  
  var body: some View {
    
    if let radio {
      VStack(alignment: .leading, spacing: 0) {
        ForEach(radio.guiClients, id: \.id) { guiClient in
          Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 0) {
            GridRow {
              Text(guiClient.station)
                .foregroundColor(.yellow)
                .font(.title)
                .frame(width: 200, alignment: .leading)
                .truncationMode(.tail)
                .lineLimit(1)   // This is critical
                .clipped()
                .help(guiClient.station)
              
              Text("Handle")
              Text(guiClient.handle)
                .foregroundColor(.secondary)
                .gridColumnAlignment(.trailing)
              
              Text("Program")
              Text("\(guiClient.program)")
                .foregroundColor(.secondary)
                .gridColumnAlignment(.trailing)
              
              Text("LocalPtt")
              Text(guiClient.pttEnabled ? "Y" : "N")
                .foregroundColor(guiClient.pttEnabled ? .green : .red)
                .gridColumnAlignment(.trailing)
              
              Text("ClientId")
              Text("\(guiClient.clientId == nil ? "Unknown" : guiClient.clientId!.uuidString)")
                .foregroundColor(.secondary)
                .gridColumnAlignment(.trailing)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
          
          //        Divider()
          //          .frame(height: 2)
          //          .background(Color.gray)
          
          GuiClientDetailView(handle: guiClient.handle.handle!)
        }
        
      }
      .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
    } else {
      Text("STATION Objects will be displayed here")
        .frame(maxWidth: .infinity)
    }
    //    .frame(minHeight: 50)
  }
}

private struct GuiClientDetailView: View {
  let handle: UInt32
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(SettingsModel.self) private var settings
  
  var body: some View {
    
    ScrollView([.vertical]) {
      VStack(alignment: .leading) {
        switch settings.stationObjectFilter {
          
        case .all:
          PanadapterSubView(handle: handle, showMeters: true)
          
        case .noMeters:
          PanadapterSubView(handle: handle, showMeters: false)
          
          //      case .amplifiers:        AmplifierSubView()
          //      case .cwx:               CwxSubView()
        case .interlock:         InterlockSubView()
          //      case .memories:          MemorySubView()
          //      case .meters:            MeterSubView(sliceId: nil, sliceClientHandle: nil, handle: handle)
          //      case .network:           NetworkSubView()
          //      case .profiles:          ProfileSubView()
          //      case .streams:           StreamSubView(handle: handle)
          //      case .usbCable:          UsbCableSubView()
          //      case .wan:               WanSubView()
          //      case .waveforms:         WaveformSubView()
          //      case .xvtrs:             XvtrSubView()
        default:                Text("Unknown")
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

//#Preview {
//  GuiClientSubView()
//    .environment(ViewModel())
//  
//    .frame(width: 1250)
//}
