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
  
  @Environment(ViewModel.self) private var viewModel
  
  private var guiClients: [GuiClient] {
      viewModel.api.radios.flatMap { $0.guiClients }
  }

  var body: some View {
    
    ForEach(guiClients, id: \.id) { guiClient in
      VStack(alignment: .leading, spacing: 0) {
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
            Text(guiClient.isLocalPtt ? "Y" : "N")
              .foregroundColor(guiClient.isLocalPtt ? .green : .red)
              .gridColumnAlignment(.trailing)
            
            Text("ClientId")
            Text("\(guiClient.clientId == nil ? "Unknown" : guiClient.clientId!.uuidString)")
              .foregroundColor(.secondary)
              .gridColumnAlignment(.trailing)
          }
        }
        Divider().frame(height: 2)
      }
      .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
          
      GuiClientDetailView(handle: guiClient.handle.handle!)
    }
    .frame(minHeight: 50)
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

#Preview {
  GuiClientSubView()
    .environment(ViewModel())
  
    .frame(width: 1250)
}
