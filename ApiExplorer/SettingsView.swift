//
//  SettingsView.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 3/1/25.
//


import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View(s)

public struct SettingsView: View {
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(SettingsModel.self) private var settings
  @Environment(\.dismiss) var dismiss
  
  public var body: some View {
    @Bindable var viewModelBinding = viewModel
    @Bindable var settings = settings
    
    Grid(alignment: .leading) {
      GridRow {
        Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
        Text("Settings")
          .font(.title)
      }
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)
      
      GridRow {
        Text("Station Name")
        TextField("", text: $settings.stationName)
          .frame(width: 200)
      }
      
      GridRow {
        Text("Require Smartlink Login")
        Toggle("", isOn: $settings.smartlinkLoginRequired)
      }
      
      GridRow {
        Text("Use saved Defaults")
        Toggle("", isOn: $settings.useDefaultEnabled)
      }
      
      GridRow {
        Text("Clear messages on Start")
        Toggle("", isOn: $settings.clearOnStart)
      }
      
      GridRow {
        Text("Clear messages on Stop")
        Toggle("", isOn: $settings.clearOnStop)
      }
      
      GridRow {
        Text("Low BW Connect")
        Toggle("", isOn: $settings.lowBandwidthConnect)
      }
      
      GridRow {
        Text("Low BW Dax")
        Toggle("", isOn: $settings.lowBandwidthDax)
      }
      
      GridRow {
        Text("Rx Audio Compression")
        Toggle("", isOn: $settings.remoteRxAudioCompressed)
      }
      
      GridRow {
        Text("Tx Audio Compression")
        Toggle("", isOn: $settings.remoteTxAudioCompressed)
      }

      GridRow {
        Text("Dark mode")
        Toggle("", isOn: $settings.darkMode)
      }

      GridRow {
        Text("Ignore Gps status")
        Toggle("", isOn: $settings.ignoreGps)
      }
    }
    .padding(.horizontal, 10)
    .disabled(viewModel.isConnected)
//    .frame(width: .infinity, alignment: .leading)

    Divider()
      .frame(height: 2)
      .background(Color.gray)
    
    HStack() {
      Spacer()
      Button("Close") { dismiss() }
        .keyboardShortcut(.defaultAction)
#if os(iOS)
        .buttonStyle(.bordered)
#endif
    }
//    .frame(width: 300)
    .padding(.trailing, 10)
    .padding(.bottom, 10)
  }
}


// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview("SettingsView") {
  SettingsView()
  
    .environment(ViewModel())
    .environment(SettingsModel.shared)
}
