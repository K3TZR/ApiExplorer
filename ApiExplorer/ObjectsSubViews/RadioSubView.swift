//
//  RadioSubView.swift
//  Api6000/SubViews
//
//  Created by Douglas Adams on 1/23/22.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

struct RadioSubView: View {
  
  @Environment(ViewModel.self) var viewModel
  
  @State var showDetails = true
  
  //  @MainActor private func sourceColor(_ packet: Packet) -> Color {
  //    packet.source == .local ? .blue : .red
  //  }
  
  var body: some View {
    
    if viewModel.objectModel.activeSelection != nil {
      let radio = viewModel.objectModel.activeSelection!.radio
      ScrollView([.vertical, .horizontal]) {
        
        VStack(alignment: .leading) {
          Grid(alignment: .trailing, horizontalSpacing: 20, verticalSpacing: 0) {
            GridRow {
              Label("Radio", systemImage: showDetails ? "chevron.down" : "chevron.right")
                .frame(width: 125, alignment: .leading)
                .font(.title)
                .foregroundColor(.green)
                .onTapGesture{ showDetails.toggle() }
                .help("          Tap to toggle details")
                .gridColumnAlignment(.leading)
              
              Line1View(radio: radio)
            }
          }
          
          if showDetails { DetailView() }
        }
      }
    }
  }
}

private struct Line1View: View {
  let radio: Radio
  
  @Environment(ViewModel.self) var viewModel
  
  var body: some View {
    
    Text(radio.packet.source.rawValue.uppercased()).foregroundColor(.green)
    
    Text("ip")
    Text(radio.packet.publicIp).foregroundColor(.green)
    
    Text("FW")
    Text(radio.packet.version).foregroundColor(.green)
    Text("\(radio.alpha ? "(alpha)" : "")").foregroundColor(radio.alpha ? .red : nil)
    
    Text("Model")
    Text(radio.packet.model).foregroundColor(.green)
    
    Text("Serial")
    Text(radio.packet.serial).foregroundColor(.green)
    Text("HW")
    Text(viewModel.objectModel.hardwareVersion ?? "").foregroundColor(.green)
    Text("Uptime")
    Text("\(radio.uptime)").foregroundColor(.green)
    Text("(seconds)")
    Text("TNF's Enabled")
    Text("\(radio.tnfsEnabled ? "Y" : "N")").foregroundColor(radio.tnfsEnabled ? .green : .red)
    Text("MF Enabled")
    Text("\(radio.multiflexEnabled ? "Y" : "N")").foregroundColor(radio.multiflexEnabled ? .green : .red)
  }
}

private struct DetailView: View {

  @Environment(ViewModel.self) var viewModel

  var body: some View {
    
    VStack(alignment: .leading) {
      switch viewModel.settingModel.radioObjectFilter {
      case .all:
        AtuSubView()
        BandSettingSubView()
        EqualizerSubView()
        GpsSubView()
        MemorySubView()
        MeterSubView()
        ListsView()
        TnfSubView()
        TransmitSubView()
      case .atu:          AtuSubView()
      case .bandSettings: BandSettingSubView()
      case .equalizers:   EqualizerSubView()
      case .gps:          GpsSubView()
      case .lists:        ListsView()
      case .memories:     MemorySubView()
      case .meters:       MeterSubView()
      case .tnf:          TnfSubView()
      case .transmit:     TransmitSubView()
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  RadioSubView()
    .environment(ViewModel())
  
    .frame(minWidth: 1250)
}
