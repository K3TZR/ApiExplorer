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
      VStack(alignment: .leading, spacing: 0) {
        Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 0) {
          GridRow {
            Text(radio.packet.nickname)
              .frame(width: 200, alignment: .leading)
              .font(.title)
              .foregroundColor(.green)
              .gridColumnAlignment(.leading)
              .truncationMode(.tail)
              .lineLimit(1)   // This is critical
              .clipped()
              .help(radio.packet.nickname)
            
            HStack(spacing: 5) {
              Text("Source")
              Text(radio.packet.source.rawValue
                .uppercased())
              .foregroundColor(.secondary)
            }
            
            HStack(spacing: 5) {
              Text("ip")
              Text(radio.packet.publicIp)
                .foregroundColor(.secondary)
                .gridColumnAlignment(.trailing)
            }
            
            HStack(spacing: 5) {
              Text("FW")
              Text(radio.packet.version + "\(radio.alpha ? "(alpha)" : "")")
                .foregroundColor(radio.alpha ? .red : .secondary)
            }
            
            HStack(spacing: 5) {
              Text("Model")
              Text(radio.packet.model)
                .foregroundColor(.secondary)
            }
            
            HStack(spacing: 5) {
              Text("Serial")
              Text(radio.packet.serial)
                .foregroundColor(.secondary)
            }
          }
          
          GridRow {
            Color.clear.gridCellUnsizedAxes([.horizontal, .vertical]).border(.red)
            
            HStack(spacing: 5) {
              Text("HW")
              Text(viewModel.api.hardwareVersion ?? "")
                .foregroundColor(.secondary)
            }
            
            HStack(spacing: 5) {
              Text("Uptime")
              Text("\(radio.uptime) (seconds)")
                .foregroundColor(.secondary)
            }
            
            HStack(spacing: 5) {
              Text("TNF's Enabled")
              Text("\(radio.tnfsEnabled ? "Y" : "N")")
                .foregroundColor(radio.tnfsEnabled ? .green : .red)
            }
            
            HStack(spacing: 5) {
              Text("MF Enabled")
              Text("\(radio.multiflexEnabled ? "Y" : "N")")
                .foregroundColor(radio.multiflexEnabled ? .green : .red)
            }
          }
          Divider()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        DetailView(filter: settings.radioObjectFilter)
      }
    }
  }
}

private struct DetailView: View {
  let filter: RadioObjectFilter
  
  @Environment(ViewModel.self) var viewModel
  
  var body: some View {
    
    ScrollView([.vertical]) {
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
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  RadioSubView()
    .environment(ViewModel())
    .environment(SettingsModel.shared)
  
    .frame(minWidth: 1000)
}
