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
  
  private let labelWidth: CGFloat = 200
  
  var body: some View {
    
    if let radio {
      VStack(alignment: .leading, spacing: 0) {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 0) {
          GridRow {
            Text(radio.packet.nickname)
              .frame(width: labelWidth, alignment: .leading)
              .bold()
//              .underline()
//              .font(.title)
              .foregroundStyle(radio.packet.source == .local ? .green : .red)
              .gridColumnAlignment(.leading)
              .truncationMode(.tail)
              .lineLimit(1)   // This is critical
              .clipped()
              .help(radio.packet.nickname)
              .accessibilityLabel("Nickname: \(radio.packet.nickname)")
            
            LabeledValue(label: "Model", value: radio.packet.model)
            
            LabeledValue(label: "ip", value: radio.packet.publicIp, alignTrailing: true)
            
            LabeledValue(label: "FW", value: radio.packet.version, valueStyle: radio.alpha ? .red : .secondary)
            
            LabeledValue(label: "Serial", value: radio.packet.serial)
              .gridCellColumns(2)
       }
          
          GridRow {
            Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
            
  
            LabeledValue(label: "HW", value: viewModel.api.hardwareVersion ?? "")
            
            LabeledValue(label: "Uptime", value: "\(radio.uptime)")
            
            LabeledValue(label: "Ant List", value: radio.antList.joined(separator: ", "))
              .gridCellColumns(3)
            
        }
          
          GridRow {
            Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])

            ToggleRow(label: "TNF's Enabled", isOn: radio.tnfsEnabled)
            
            ToggleRow(label: "MF Enabled", isOn: radio.multiflexEnabled)
            
            LabeledValue(label: "Mic List", value: radio.micList.joined(separator: ", "))
              .gridCellColumns(3)
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
// MARK: - Helper Views

private struct LabeledValue: View {
  let label: String
  let value: String
  var valueStyle: Color = .secondary
  var alignTrailing: Bool = false
  var body: some View {
    HStack(spacing: 5) {
      Text(label)
      Text(value)
        .foregroundStyle(valueStyle)
        .monospaced()
        .gridColumnAlignment(alignTrailing ? .trailing : .leading)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(Text("\(label): \(value)"))
  }
}

private struct ToggleRow: View {
  let label: String
  let isOn: Bool
  var onText: String = "Y"
  var offText: String = "N"
  var body: some View {
    HStack(spacing: 5) {
      Text(label)
      Text(isOn ? onText : offText)
        .foregroundStyle(isOn ? .green : .red)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(Text("\(label): \(isOn ? "Yes" : "No")"))
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  RadioSubView(radio: nil, viewMode: .all)
    .environment(ViewModel(SettingsModel()))
  
    .frame(minWidth: 1000)
}
