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
  
  private var startButtonDisabled: Bool {
    return !(viewModel.settings.directEnabled || viewModel.settings.localEnabled || viewModel.settings.smartlinkEnabled)
  }
  
  public var body: some View {
    @Bindable var settings = viewModel.settings
    
    HStack(spacing: 0) {
      // Connection initiation
      Button(viewModel.isConnected ? "Stop" : "Start") {
        viewModel.startButtonTapped()
      }
      .foregroundColor(viewModel.isConnected ? .red : .green)
      .disabled(startButtonDisabled)
      
      Spacer()
      
      Toggle("Gui", isOn: $settings.isGui)
        .toggleStyle(.button)
        .disabled(viewModel.isConnected)
      
      Spacer()
      
      // Connection types
      HStack(spacing: 5) {
        Toggle("Direct", isOn: $settings.directEnabled)
          .onChange(of: settings.directEnabled) { oldValue, newValue in
            viewModel.directButtonChanged(newValue)
          }
        Toggle("Local", isOn: $settings.localEnabled)
          .onChange(of: settings.localEnabled) { oldValue, newValue in
            viewModel.localButtonChanged(newValue)
          }
        Toggle("Smartlink", isOn: $settings.smartlinkEnabled)
          .onChange(of: settings.smartlinkEnabled) { oldValue, newValue in
            viewModel.smartlinkButtonChanged(newValue)
          }
      }
      .disabled(viewModel.isConnected)
      .toggleStyle(.button)
      
      Spacer()
      
      Picker("", selection: $settings.daxSelection) {
        ForEach(DaxChoice.allCases, id: \.self) {
          Text($0.rawValue.capitalized).tag($0)
        }
      }
      .frame(width: 180)
      .labelsHidden()
      .disabled(settings.isGui == false)
      .onChange(of: settings.daxSelection) {
        viewModel.daxSelectionChanged($0, $1)
      }
      
      Spacer()
      
      HStack(spacing: 10) {
        Toggle("Rx Audio", isOn: $settings.remoteRxAudioEnabled)
          .disabled(settings.isGui == false)
          .onChange(of: settings.remoteRxAudioEnabled) { _, _ in
            viewModel.remoteRxAudioEnabledButtonChanged()
          }
        
        Toggle( "Tx Audio", isOn: $settings.remoteTxAudioEnabled)
          .disabled(settings.isGui == false)
          .onChange(of: settings.remoteTxAudioEnabled) { _, _ in
            viewModel.remoteTxAudioEnabledButtonChanged()
          }
      }
      .toggleStyle(.button)
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  TopButtonsView()
    .environment(ViewModel(SettingsModel()))
  
    .frame(width: 1000)
}
