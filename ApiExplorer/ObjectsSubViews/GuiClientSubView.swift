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
  
  @Environment(ViewModel.self) private var viewModel
  
  @State var showSubView = true
  
  //  @MainActor func getGuiClientId(_ id: String) -> String {
  //    return viewModel.objects.guiClientIds.first(where: { $0.id == id })?.clientId?.uuidString ?? ""
  //  }
  
  var body: some View {
    
    ForEach(viewModel.objectModel.radios, id: \.id) { radio in
      
      if radio.id == viewModel.objectModel.activeSelection?.radio.id {
        ForEach(radio.guiClients, id: \.id) { guiClient in
          ScrollView([.vertical]) {
            VStack(alignment: .leading) {

              Grid(alignment: .trailing, horizontalSpacing: 30, verticalSpacing: 0) {
                GridRow {
                  Label("Gui", systemImage: showSubView ? "chevron.down" : "chevron.right")
                    .foregroundColor(.yellow)
                    .font(.title)
                    .frame(width: 120, alignment: .leading)
                    .onTapGesture{ showSubView.toggle() }
                    .help("          Tap to toggle details")
                    .gridColumnAlignment(.leading)
                  
                  Text("\(guiClient.station)").foregroundColor(.yellow)
                    .frame(width: 120, alignment: .leading)
                  
                  Text("Handle")
                    .gridColumnAlignment(.leading)
                  Text(guiClient.handle).foregroundColor(.secondary)
                  Text("Program")
                    .gridColumnAlignment(.leading)
                  Text("\(guiClient.program)").foregroundColor(.secondary)
                  Text("LocalPtt")
                    .gridColumnAlignment(.leading)
                  Text(guiClient.isLocalPtt ? "Y" : "N").foregroundColor(guiClient.isLocalPtt ? .green : .red)
                  Text("ClientId")
                    .gridColumnAlignment(.leading)
                 Text("\(guiClient.clientId == nil ? "Unknown" : guiClient.clientId!.uuidString)").foregroundColor(.secondary)
                }
              }
//              .frame(minWidth: 1250, maxWidth: .infinity)
              
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
  GuiClientSubView()
    .environment(ViewModel())
  
    .frame(width: 1250)
}
