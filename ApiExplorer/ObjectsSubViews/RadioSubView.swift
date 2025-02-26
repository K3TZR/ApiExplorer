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
      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          Grid(alignment: .trailing, horizontalSpacing: 20, verticalSpacing: 0) {
            GridRow {
              Label("Radio", systemImage: showDetails ? "chevron.down" : "chevron.right")
                .frame(width: 125, alignment: .leading)
                .font(.title)
                .foregroundColor(.green)
                .onTapGesture{ showDetails.toggle() }
                .gridColumnAlignment(.leading)
              
              Text(radio.packet.source.rawValue.uppercased()).foregroundColor(.green)
              
              Text("ip")
              Text(radio.packet.publicIp).foregroundColor(.green)
                .gridColumnAlignment(.trailing)
              
              Text("FW")
              Text(radio.packet.version + "\(radio.alpha ? "(alpha)" : "")").foregroundColor(radio.alpha ? .red : .green)
                .gridColumnAlignment(.trailing)
              
              Text("Model")
              Text(radio.packet.model).foregroundColor(.green)
                .gridColumnAlignment(.trailing)
              
              Text("Serial")
              Text(radio.packet.serial).foregroundColor(.green)
                .gridColumnAlignment(.trailing)
              
              Text("HW")
              Text(viewModel.objectModel.hardwareVersion ?? "").foregroundColor(.green)
                .gridColumnAlignment(.trailing)
              
              Text("Uptime")
              Text("\(radio.uptime) (seconds)").foregroundColor(.green)
                .gridColumnAlignment(.trailing)
              
              Text("TNF's Enabled")
              Text("\(radio.tnfsEnabled ? "Y" : "N")").foregroundColor(radio.tnfsEnabled ? .green : .red)
                .gridColumnAlignment(.trailing)
              
              Text("MF Enabled")
              Text("\(radio.multiflexEnabled ? "Y" : "N")").foregroundColor(radio.multiflexEnabled ? .green : .red)
                .gridColumnAlignment(.trailing)
            }
          }
          
          if showDetails { DetailView(filter: viewModel.settingModel.radioObjectFilter) }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
      }
    }
  }
}

private struct DetailView: View {
  let filter: RadioObjectFilter
  
  @Environment(ViewModel.self) var viewModel
  
  var body: some View {
    
    VStack(alignment: .leading) {
      switch filter {
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
