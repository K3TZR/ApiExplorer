//
//  TopButtonsView.swift
//  ApiExplorer/Subviews
//
//  Created by Douglas Adams on 10/06/24.
//

import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View

public struct TopButtonsView: View {
  @Environment(ViewModel.self) private var viewModel

  private var startButtonDisabled: Bool {
    return !(SettingsModel.shared.directEnabled || SettingsModel.shared.localEnabled || SettingsModel.shared.smartlinkEnabled)
  }

  public var body: some View {
    @Bindable var viewModelBinding = viewModel
    @Bindable var settings = SettingsModel.shared

    HStack(spacing: 30) {
      // Connection initiation
      Button(viewModel.isConnected ? "Stop" : "Start") {
        viewModel.startButtonTapped()
      }
      .background(Color(.green).opacity(0.2))
      .frame(width: 60, alignment: .leading)
      .disabled(startButtonDisabled)
      
      Toggle("Gui", isOn: $settings.isGui)
        .frame(width: 60, alignment: .leading)

      // Connection types
      ControlGroup {
        Toggle("Direct", isOn: $settings.directEnabled)
          .onChange(of: SettingsModel.shared.directEnabled) {
            viewModel.directButtonChanged($1)
          }
        Toggle("Local", isOn: $settings.localEnabled)
          .onChange(of: SettingsModel.shared.localEnabled) {
            viewModel.localButtonChanged($1)
          }
        Toggle("Smartlink", isOn: $settings.smartlinkEnabled)
          .onChange(of: SettingsModel.shared.smartlinkEnabled) {
            viewModel.smartlinkButtonChanged($1)
          }
       }
      .frame(width: 180)
      .disabled(viewModel.isConnected)
      
      Spacer()
      
      Picker("Dax", selection: $settings.daxSelection) {
        ForEach(DaxChoice.allCases, id: \.self) {
          Text($0.rawValue.capitalized).tag($0)
        }
      }
      .frame(width: 180)
      .disabled(SettingsModel.shared.isGui == false)

      .onChange(of: SettingsModel.shared.daxSelection) {
        viewModel.daxSelectionChanged($0, $1)
      }
      
      Spacer()
      
      HStack(spacing: 10) {
        Toggle("Rx Audio", isOn: $settings.remoteRxAudioEnabled)
          .disabled(SettingsModel.shared.isGui == false)
        
          .onChange(of: SettingsModel.shared.remoteRxAudioEnabled) { _, _ in
            viewModel.remoteRxAudioEnabledButtonChanged()
          }
        
        Toggle("Tx Audio", isOn: $settings.remoteTxAudioEnabled)
          .disabled(SettingsModel.shared.isGui == false)

          .onChange(of: SettingsModel.shared.remoteTxAudioEnabled) { _, _ in
            viewModel.remoteTxAudioEnabledButtonChanged()
          }
      }
      .frame(width: 150)

    }
    .toggleStyle(.button)
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
