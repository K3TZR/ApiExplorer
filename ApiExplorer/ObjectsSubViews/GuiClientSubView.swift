//
//  GuiClientSubView.swift
//  SDRApi/ObjectsSubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import ApiPackage
//import SharedFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct GuiClientSubView: View {
  let radio: Radio
  
  @Environment(ViewModel.self) private var viewModel
  
  @State var showSubView = true
  
  //  @MainActor func getGuiClientId(_ id: String) -> String {
  //    return viewModel.objects.guiClientIds.first(where: { $0.id == id })?.clientId?.uuidString ?? ""
  //  }
  
  var body: some View {
    
    ForEach(radio.guiClients, id: \.id) { guiClient in
      ScrollView([.vertical]) {
        VStack(alignment: .leading, spacing: 0) {
          Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 0) {
            GridRow {
              Label("Gui", systemImage: showSubView ? "chevron.down" : "chevron.right")
                .foregroundColor(.yellow)
                .font(.title)
                .frame(width: 100, alignment: .leading)
                .onTapGesture{ showSubView.toggle() }

              Text("\(guiClient.station)")
                .foregroundColor(.yellow)
              
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
          
          if showSubView {
            GuiClientDetailView(handle: guiClient.handle.handle!)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
      }
    }
  }
}

private struct GuiClientDetailView: View {
  let handle: UInt32
  
  @Environment(ViewModel.self) private var viewModel
  
  var body: some View {
    
    VStack(alignment: .leading) {
      switch viewModel.settingModel.stationObjectFilter {
        
      case .all:
        PanadapterSubView(handle: handle, showMeters: true)
        
      case .noMeters:
        PanadapterSubView(handle: handle, showMeters: false)
        
        //      case .amplifiers:        AmplifierSubView()
        //      case .cwx:               CwxSubView()
      case .interlock:         InterlockSubView()
        //      case .memories:          MemorySubView()
        //      case .meters:            MeterSubView(sliceId: nil, sliceClientHandle: nil, handle: handle)
        //      case .misc:              MiscSubView()
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
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  GuiClientSubView(radio: Radio(Packet(.local, "".keyValuesArray()), [GuiClient](), nil))
    .environment(ViewModel())
  
    .frame(width: 1250)
}
