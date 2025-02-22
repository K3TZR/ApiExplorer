//
//  GuiClientSubView.swift
//  SDRApi/ObjectsSubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

//import FlexApiFeature
//import SharedFeature

// ----------------------------------------------------------------------------
// MARK: - View

struct GuiClientSubView: View {
  
  @Environment(ViewModel.self) private var viewModel
  
  @State var showSubView = true
  
  //  @MainActor func getGuiClientId(_ id: String) -> String {
  //    return viewModel.objects.guiClientIds.first(where: { $0.id == id })?.clientId?.uuidString ?? ""
  //  }
  
  var body: some View {
    
    ForEach(viewModel.objectModel.radios, id: \.id) { radio in
      
      if radio.id == viewModel.objectModel.activeSelection?.radio.id {
        let guiClients = radio.guiClients
        ForEach(guiClients, id: \.id) { guiClient in
          ScrollView([.vertical, .horizontal]) {
            VStack(alignment: .leading) {
              HStack(spacing: 20) {
                
                HStack(spacing: 0) {
                  Label("Gui", systemImage: showSubView ? "chevron.down" : "chevron.right")
                    .foregroundColor(.yellow)
                    .font(.title)
                    .frame(width: 120, alignment: .leading)
                    .onTapGesture{ showSubView.toggle() }
                    .help("          Tap to toggle details")
                  
                  Text("\(guiClient.station)").foregroundColor(.yellow)
                    .frame(width: 120, alignment: .leading)
                }
                
                Group {
                  HStack(spacing: 5) {
                    Text("Handle")
                    Text(guiClient.handle).foregroundColor(.secondary)
                  }
                  
                  HStack(spacing: 5) {
                    Text("Program")
                    Text("\(guiClient.program)").foregroundColor(.secondary)
                  }
                  
                  HStack(spacing: 5) {
                    Text("LocalPtt")
                    Text(guiClient.isLocalPtt ? "Y" : "N").foregroundColor(guiClient.isLocalPtt ? .green : .red)
                  }
                }.frame(width: 150, alignment: .leading)
                
                HStack(spacing: 5) {
                  Text("ClientId")
                  Text("\(guiClient.clientId == nil ? "Unknown" : guiClient.clientId!.uuidString)").foregroundColor(.secondary)
                }
                
                Spacer()
              }
              .frame(minWidth: 1250, maxWidth: .infinity)
              
              if showSubView {
                GuiClientDetailView(handle: guiClient.handle.handle!)
              }
            }
          }
        }
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
        
        //      case .all:
        //        PanadapterSubView(handle: handle, showMeters: true)
        
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
  GuiClientSubView()
    .environment(ViewModel())
  
    .frame(width: 1250)
}
