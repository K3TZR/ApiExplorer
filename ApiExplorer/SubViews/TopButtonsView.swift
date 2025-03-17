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
    return !(settings.directEnabled || settings.localEnabled || settings.smartlinkEnabled)
  }

  public var body: some View {
    @Bindable var settings = settings

    HStack(spacing: 0) {
      // Connection initiation
      Button(viewModel.isConnected ? "Stop" : "Start") {
        viewModel.startButtonTapped()
      }
      .background(Color(.green).opacity(0.2))
      .frame(width: 60, alignment: .leading)
      .disabled(startButtonDisabled)
      
      ToggleX(title: "Gui", isOn: $settings.isGui, width: 50)
//        .frame(width: 60, alignment: .leading)

      Spacer()
      
      // Connection types
      HStack(spacing: 5) {
        ToggleX(title: "Direct", isOn: $settings.directEnabled, width: 70)
          .onChange(of: settings.directEnabled) {
            viewModel.directButtonChanged($1)
          }
        ToggleX(title: "Local", isOn: $settings.localEnabled, width: 70)
          .onChange(of: settings.localEnabled) {
            viewModel.localButtonChanged($1)
          }
        ToggleX(title: "Smartlink", isOn: $settings.smartlinkEnabled, width: 90)
          .onChange(of: settings.smartlinkEnabled) {
            viewModel.smartlinkButtonChanged($1)
          }
      }
//      .frame(width: 180)
      .disabled(viewModel.isConnected)
      
      Spacer()
      
      Picker("Dax", selection: $settings.daxSelection) {
        ForEach(DaxChoice.allCases, id: \.self) {
          Text($0.rawValue.capitalized).tag($0)
        }
      }
      .frame(width: 180)
      .disabled(settings.isGui == false)
      .onChange(of: settings.daxSelection) {
        viewModel.daxSelectionChanged($0, $1)
      }
      
      Spacer()
      
      HStack(spacing: 10) {
        ToggleX(title: "Rx Audio", isOn: $settings.remoteRxAudioEnabled, width: 80)
          .disabled(settings.isGui == false)
          .onChange(of: settings.remoteRxAudioEnabled) { _, _ in
            viewModel.remoteRxAudioEnabledButtonChanged()
          }
        
        ToggleX(title: "Tx Audio", isOn: $settings.remoteTxAudioEnabled, width: 80)
          .disabled(settings.isGui == false)
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
    .environment(SettingsModel.shared)
  
    .frame(width: 1000)
}
