//
//  TopButtonsView.swift
//  ApiExplorer/Subviews
//
//  Created by Douglas Adams on 10/06/24.
//

import SwiftUI

import ApiPackage

// ----------------------------------------------------------------------------
// MARK: - View

public struct TopButtonsView: View {
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(SettingsModel.self) private var settings

  private var startButtonDisabled: Bool {
    return !(settings.directEnabled || !settings.localDisabled || settings.smartlinkEnabled)
  }

  public var body: some View {
    @Bindable var settings = settings

    HStack(spacing: 0) {
      // Connection initiation
      Button(viewModel.isConnected ? "Stop" : "Start") {
        viewModel.startButtonTapped()
      }
#if os(iOS)
      .buttonStyle(.bordered)
#endif
      .background(Color(.green).opacity(0.2))
//      .frame(width: 60, alignment: .leading)
      .disabled(startButtonDisabled)
      
      Spacer()
      
      ToggleY(title: "Gui", isOn: $settings.isNonGui)
//        .frame(width: 60, alignment: .leading)
        .disabled(viewModel.isConnected)

      Spacer()
      
      // Connection types
      HStack(spacing: 5) {
        ToggleX(title: "Direct", isOn: $settings.directEnabled)
          .onChange(of: settings.directEnabled) {
            viewModel.directButtonChanged($1)
          }
        ToggleY(title: "Local", isOn: $settings.localDisabled)
          .onChange(of: settings.localDisabled) {
            viewModel.localButtonChanged($1)
          }
        ToggleX(title: "Smartlink", isOn: $settings.smartlinkEnabled)
          .onChange(of: settings.smartlinkEnabled) {
            viewModel.smartlinkButtonChanged($1)
          }
      }
//      .frame(width: 180)
      .disabled(viewModel.isConnected)
      
      Spacer()
      
      Picker("", selection: $settings.daxSelection) {
        ForEach(DaxChoice.allCases, id: \.self) {
          Text($0.rawValue.capitalized).tag($0)
        }
      }
      .frame(width: 180)
      .labelsHidden()
      .disabled(settings.isNonGui == true)
      .onChange(of: settings.daxSelection) {
        viewModel.daxSelectionChanged($0, $1)
      }
      
      Spacer()
      
      HStack(spacing: 10) {
        ToggleX(title: "Rx Audio", isOn: $settings.remoteRxAudioEnabled)
          .disabled(settings.isNonGui == true)
          .onChange(of: settings.remoteRxAudioEnabled) { _, _ in
            viewModel.remoteRxAudioEnabledButtonChanged()
          }
        
        ToggleX(title: "Tx Audio", isOn: $settings.remoteTxAudioEnabled)
          .disabled(settings.isNonGui == true)
          .onChange(of: settings.remoteTxAudioEnabled) { _, _ in
            viewModel.remoteTxAudioEnabledButtonChanged()
          }
      }
    }
//    .toggleStyle(.button)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  TopButtonsView()
    .environment(ViewModel())
    .environment(SettingsModel())
  
    .frame(width: 1000)
}
