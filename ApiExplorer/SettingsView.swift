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
        Toggle("Require Smartlink Login", isOn: $viewModelBinding.settingModel.smartlinkLoginRequired)
        
        Toggle("Use saved Defaults", isOn: $viewModelBinding.settingModel.useDefaultEnabled)
        
        Toggle("Clear messages on Start", isOn: $viewModelBinding.settingModel.clearOnStart)

        Toggle("Clear messages on Stop", isOn: $viewModelBinding.settingModel.clearOnStop)

        Toggle("Low BW Connect", isOn: $viewModelBinding.settingModel.lowBandwidthDax)
        
        Toggle("Rx Audio Compression", isOn: $viewModelBinding.settingModel.remoteRxAudioCompressed)
          .onChange(of: viewModel.settingModel.remoteRxAudioCompressed) { _, _ in
            viewModel.remoteRxAudioCompressedButtonChanged()
          }
        
        Toggle("Tx Audio Compression", isOn: $viewModelBinding.settingModel.remoteTxAudioCompressed)
          .onChange(of: viewModel.settingModel.remoteTxAudioCompressed) { _, _ in
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
