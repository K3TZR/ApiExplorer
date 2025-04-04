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
    let radio: Radio?
  
  @Environment(ViewModel.self) var viewModel
  @Environment(SettingsModel.self) private var settings

//  var radio: Radio? {
//    let parts = viewModel.api.activeSelection!.split(separator: "|")
//    return viewModel.api.radios.first(where: {$0.id == parts[0] + "|" + parts[1] })
//  }
  
  var body: some View {
    
    if let radio {
      VStack(alignment: .leading, spacing: 0) {
        Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 0) {
          GridRow {
            Text(radio.packet.nickname)
              .frame(width: 200, alignment: .leading)
              .font(.title)
              .foregroundColor(radio.packet.source == .local ? .green : .red)
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
            Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
            
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
//          Divider()
//            .frame(height: 2)
//            .background(Color.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        DetailView(filter: settings.radioObjectFilter, radio: radio)
      }
    } else {
      Text("RADIO Objects will be displayed here")
        .frame(maxWidth: .infinity)
    }
  }
}

private struct DetailView: View {
  let filter: RadioObjectFilter
  let radio: Radio
  
  @Environment(ViewModel.self) var viewModel
  
  var body: some View {
    
    ScrollView([.vertical]) {
      VStack(alignment: .leading) {
        switch filter {
        case .all:
          AtuSubView(radio: radio)
          BandSettingSubView()
          EqualizerSubView()
          GpsSubView(radio: radio)
          InterlockSubView()
          ListsView(radio: radio)
          MemorySubView()
          MeterSubView()
          NetworkSubView()
          TnfSubView()
          TransmitSubView()
        case .atu:          AtuSubView(radio: radio)
        case .bandSettings: BandSettingSubView()
        case .equalizers:   EqualizerSubView()
        case .gps:          GpsSubView(radio: radio)
        case .interlocks:   InterlockSubView()
        case .lists:        ListsView(radio: radio)
        case .memories:     MemorySubView()
        case .meters:       MeterSubView()
        case .network:      NetworkSubView()
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
  RadioSubView(radio: nil)
    .environment(ViewModel())
    .environment(SettingsModel.shared)
  
    .frame(minWidth: 1000)
}
