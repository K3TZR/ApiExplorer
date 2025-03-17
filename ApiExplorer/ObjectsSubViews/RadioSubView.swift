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
  @Environment(SettingsModel.self) private var settings

  var body: some View {
    
    if viewModel.api.activeSelection != nil {
      let radio = viewModel.api.activeSelection!.radio
      
      ScrollView([.vertical]) {
        VStack(alignment: .leading, spacing: 0) {
          Grid(alignment: .trailing, horizontalSpacing: 10, verticalSpacing: 0) {
            GridRow {
              Text(radio.packet.nickname)
                .frame(width: 110, alignment: .leading)
                .font(.title)
                .foregroundColor(.green)
                .gridColumnAlignment(.leading)
                .truncationMode(.tail)
                .lineLimit(1)   // This is critical
                .clipped()
                .help(radio.packet.nickname)
              
              Text(radio.packet.source.rawValue
                .uppercased())
                .foregroundColor(.secondary)
              
              Text("ip")
              Text(radio.packet.publicIp)
                .foregroundColor(.secondary)
                .gridColumnAlignment(.trailing)
              
              Text("FW")
              Text(radio.packet.version + "\(radio.alpha ? "(alpha)" : "")")
                .foregroundColor(radio.alpha ? .red : .secondary)
                .gridColumnAlignment(.trailing)
              
              Text("Model")
              Text(radio.packet.model)
                .foregroundColor(.secondary)
                .gridColumnAlignment(.trailing)
              
              Text("Serial")
              Text(radio.packet.serial)
                .foregroundColor(.secondary)
                .gridColumnAlignment(.trailing)
              
              Text("HW")
              Text(viewModel.api.hardwareVersion ?? "")
                .foregroundColor(.secondary)
                .gridColumnAlignment(.trailing)
              
              Text("Uptime")
              Text("\(radio.uptime) (seconds)")
                .foregroundColor(.secondary)
                .gridColumnAlignment(.trailing)
              
              Text("TNF's Enabled")
              Text("\(radio.tnfsEnabled ? "Y" : "N")")
                .foregroundColor(radio.tnfsEnabled ? .green : .red)
                .gridColumnAlignment(.trailing)
              
              Text("MF Enabled")
              Text("\(radio.multiflexEnabled ? "Y" : "N")")
                .foregroundColor(radio.multiflexEnabled ? .green : .red)
                .gridColumnAlignment(.trailing)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          
          DetailView(filter: settings.radioObjectFilter)
        }
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
        InterlockSubView()
        MemorySubView()
        MeterSubView()
        ListsView()
        TnfSubView()
        TransmitSubView()
      case .atu:          AtuSubView()
      case .bandSettings: BandSettingSubView()
      case .equalizers:   EqualizerSubView()
      case .gps:          GpsSubView()
      case .interlocks:   InterlockSubView()
      case .lists:        ListsView()
      case .memories:     MemorySubView()
      case .network:      NetworkSubView()
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
    .environment(SettingsModel.shared)
  
    .frame(minWidth: 1000)
}
