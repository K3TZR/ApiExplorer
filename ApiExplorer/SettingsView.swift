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
  @Environment(\.dismiss) var dismiss

  public var body: some View {
    @Bindable var viewModelBinding = viewModel

    VStack(alignment: .center) {
      
      VStack(alignment: .leading) {
        Toggle("Require Smartlink Login", isOn: $viewModelBinding.settings.smartlinkLoginRequired)
        
        Toggle("Use saved Defaults", isOn: $viewModelBinding.settings.useDefaultEnabled)
        
        Toggle("Clear messages on Start", isOn: $viewModelBinding.settings.clearOnStart)

        Toggle("Clear messages on Stop", isOn: $viewModelBinding.settings.clearOnStop)

        Toggle("Low BW Connect", isOn: $viewModelBinding.settings.lowBandwidthDax)
        
        Toggle("Rx Audio Compression", isOn: $viewModelBinding.settings.remoteRxAudioCompressed)
          .onChange(of: viewModel.settings.remoteRxAudioCompressed) { _, _ in
            viewModel.remoteRxAudioCompressedButtonChanged()
          }
        
        Toggle("Tx Audio Compression", isOn: $viewModelBinding.settings.remoteTxAudioCompressed)
          .onChange(of: viewModel.settings.remoteTxAudioCompressed) { _, _ in
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
