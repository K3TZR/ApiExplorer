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

    VStack(alignment: .center) {
      
      VStack(alignment: .leading) {
        Toggle("Require Smartlink Login", isOn: $settings.smartlinkLoginRequired)
        
        Toggle("Use saved Defaults", isOn: $settings.useDefaultEnabled)
        
        Toggle("Clear messages on Start", isOn: $settings.clearOnStart)

        Toggle("Clear messages on Stop", isOn: $settings.clearOnStop)

        Toggle("Low BW Connect", isOn: $settings.lowBandwidthDax)
        
        Toggle("Rx Audio Compression", isOn: $settings.remoteRxAudioCompressed)
          .onChange(of: settings.remoteRxAudioCompressed) { _, _ in
            viewModel.remoteRxAudioCompressedButtonChanged()
          }
        
        Toggle("Tx Audio Compression", isOn: $settings.remoteTxAudioCompressed)
          .onChange(of: settings.remoteTxAudioCompressed) { _, _ in
            viewModel.remoteTxAudioCompressedButtonChanged()
          }
      }
      .disabled(viewModel.isConnected)

      Divider()

      HStack() {
        Spacer()
        Button("Close") { dismiss() }
          .keyboardShortcut(.defaultAction)
      }
    }
    .frame(width: 300)
    .padding(10)
  }
}
  
// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview("SettingsView") {
  SettingsView()
    
    .environment(ViewModel())
}
