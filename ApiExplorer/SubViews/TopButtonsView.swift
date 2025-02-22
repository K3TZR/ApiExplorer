//
//  TopButtonsView.swift
//  ApiViewer/Subviews
//
//  Created by Douglas Adams on 10/06/24.
//

import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View

public struct TopButtonsView: View {
  @Environment(ViewModel.self) private var viewModel

  private var startButtonDisabled: Bool {
    return !(viewModel.settingModel.directEnabled || viewModel.settingModel.localEnabled || viewModel.settingModel.smartlinkEnabled)
  }

  public var body: some View {
    @Bindable var viewModelBinding = viewModel

    HStack(spacing: 30) {
      // Connection initiation
      Button(viewModel.isConnected ? "Stop" : "Start") {
        viewModel.startButtonTapped()
      }
      .background(Color(.green).opacity(0.2))
      .frame(width: 100)
      .disabled(startButtonDisabled)
      .help("At least one connection type must be selected")
      
      Toggle("Gui", isOn: $viewModelBinding.settingModel.isGui)
 
      // Connection types
      ControlGroup {
        Toggle("Direct", isOn: $viewModelBinding.settingModel.directEnabled)
          .onChange(of: viewModel.settingModel.directEnabled) {
            viewModel.directChanged($1)
          }
        Toggle("Local", isOn: $viewModelBinding.settingModel.localEnabled)
          .onChange(of: viewModel.settingModel.localEnabled) {
            viewModel.localChanged($1)
          }
        Toggle("Smartlink", isOn: $viewModelBinding.settingModel.smartlinkEnabled)
          .onChange(of: viewModel.settingModel.smartlinkEnabled) {
            viewModel.smartlinkChanged($1)
          }
       }
      .frame(width: 180)
      .disabled(viewModel.isConnected)
      .help("At least one connection type must be selected")
      
      Toggle("Use Default", isOn: $viewModelBinding.settingModel.useDefaultEnabled)
        .disabled(viewModel.isConnected)
        .help("Skip the Radio Picker")
      
      Toggle("Smartlink Login", isOn: $viewModelBinding.settingModel.smartlinkLoginRequired)
        .disabled(viewModel.isConnected)
        .help("User must enter Login credentials")
      
      Spacer()
      
      HStack(spacing: 0) {
        Picker("Dax", selection: $viewModelBinding.settingModel.daxSelection) {
          ForEach(DaxChoice.allCases, id: \.self) {
            Text($0.rawValue.capitalized).tag($0)
          }
        }
        .onChange(of: viewModel.settingModel.daxSelection) {
          viewModel.daxSelectionChanged($0, $1)
        }
        
        Toggle("Low BW", isOn: $viewModelBinding.settingModel.lowBandwidthDax)
          .disabled(viewModel.isConnected)
          .help("Enable Low Bandwidth Dax")
      }
      .frame(width: 180)
      .disabled(viewModel.settingModel.isGui == false)


      HStack(spacing: 0) {
        Toggle("Rx Audio", isOn: $viewModelBinding.settingModel.remoteRxAudioEnabled)
          .disabled(viewModel.settingModel.isGui == false)
          .help("Enable audio from the Radio to this Mac")
          .onChange(of: viewModel.settingModel.remoteRxAudioEnabled) { _, _ in
            viewModel.remoteRxAudioEnabledChanged()
          }

        Toggle("Compress", isOn: $viewModelBinding.settingModel.remoteRxAudioCompressed)
          .help("Enable Rx Audio compression")
          .onChange(of: viewModel.settingModel.remoteRxAudioCompressed) { _, _ in
            viewModel.remoteRxAudioCompressedChanged()
          }
      }
      .disabled(viewModel.settingModel.isGui == false)
      .frame(width: 180)
      
      Toggle("Tx Audio", isOn: $viewModelBinding.settingModel.remoteTxAudioEnabled)
        .help("Enable audio from this Mac to the Radio")
        .onChange(of: viewModel.settingModel.remoteTxAudioEnabled) { _, _ in
          viewModel.remoteTxAudioEnabledChanged()
        }
    }.toggleStyle(.button)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  Grid(alignment: .leading, horizontalSpacing: 20) {
    TopButtonsView()
      .environment(ViewModel())
  }
  .frame(minWidth: 1250, maxWidth: .infinity)
}
