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
  let viewMode: ViewMode
  
  @Environment(ViewModel.self) var viewModel
  
  var body: some View {
    
    if let radio {
      VStack(alignment: .leading, spacing: 0) {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 0) {
          GridRow {
            Text(radio.packet.nickname)
              .frame(width: 200, alignment: .leading)
              .bold()
              .underline()
//              .font(.title)
              .foregroundColor(radio.packet.source == .local ? .green : .red)
              .gridColumnAlignment(.leading)
              .truncationMode(.tail)
              .lineLimit(1)   // This is critical
              .clipped()
              .help(radio.packet.nickname)
            
            HStack(spacing: 5) {
              Text("Model")
              Text(radio.packet.model)
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
              Text(radio.packet.version)
                .foregroundColor(radio.alpha ? .red : .secondary)
            }
            
            HStack(spacing: 5) {
              Text("Serial")
              Text(radio.packet.serial)
                .foregroundColor(.secondary)
            }.gridCellColumns(2)
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
              Text("\(radio.uptime)")
                .foregroundColor(.secondary)
            }
            
            HStack(spacing: 5) {
              Text("Ant List")
              Text(radio.antList.joined(separator: ", ")).foregroundColor(.secondary)
            }.gridCellColumns(3)
            
        }
          
          GridRow {
            Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])

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
            
            HStack(spacing: 5) {
              Text("Mic List")
              Text(radio.micList.joined(separator: ", ")).foregroundColor(.secondary)
            }.gridCellColumns(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        if viewMode != .messages {
          DetailView(filters: viewModel.settings.radioObjectFilters, radio: radio)
        }
      }
    } else {
      Spacer()
    }
  }
}

private struct DetailView: View {
  let filters: Set<String>
  let radio: Radio
  
  @Environment(ViewModel.self) var viewModel
  
  var body: some View {
    ScrollView([.vertical]) {
      VStack(alignment: .leading) {

        if filters.contains(RadioObjectFilter.amplifiers.rawValue) {AmplifierSubView()}
        if filters.contains(RadioObjectFilter.atu.rawValue) {AtuSubView(radio: radio)}
        if filters.contains(RadioObjectFilter.bandSettings.rawValue) {BandSettingSubView()}
        if filters.contains(RadioObjectFilter.cwx.rawValue) {CwxSubView()}
        if filters.contains(RadioObjectFilter.equalizers.rawValue) {EqualizerSubView()}
        if filters.contains(RadioObjectFilter.gps.rawValue) {GpsSubView(radio: radio)}
        if filters.contains(RadioObjectFilter.interlocks.rawValue) {InterlockSubView()}
        if filters.contains(RadioObjectFilter.memories.rawValue) {MemorySubView()}
        if filters.contains(RadioObjectFilter.meters.rawValue) {MeterSubView()}
        if filters.contains(RadioObjectFilter.streams.rawValue) {StreamSubView()}
        if filters.contains(RadioObjectFilter.profiles.rawValue) {ProfileSubView()}
        if filters.contains(RadioObjectFilter.tnfs.rawValue) {TnfSubView()}
        if filters.contains(RadioObjectFilter.transmit.rawValue) {TransmitSubView()}
        if filters.contains(RadioObjectFilter.usbCables.rawValue) {UsbCableSubView()}
        if filters.contains(RadioObjectFilter.wan.rawValue) {WanSubView()}
        if filters.contains(RadioObjectFilter.waveforms.rawValue) {WaveformSubView()}
        if filters.contains(RadioObjectFilter.xvtrs.rawValue) {XvtrSubView()}
      }
      .textSelection(.enabled)
      .font(.system(size: CGFloat(viewModel.settings.fontSize), weight: .regular, design: .monospaced))
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  RadioSubView(radio: nil, viewMode: .all)
    .environment(ViewModel(SettingsModel()))
  
    .frame(minWidth: 1000)
}
