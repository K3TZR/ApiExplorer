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
      .frame(width: 60, alignment: .leading)
      .disabled(startButtonDisabled)
      
      Toggle("Gui", isOn: $viewModelBinding.settingModel.isGui)
        .frame(width: 60, alignment: .leading)

      // Connection types
      ControlGroup {
        Toggle("Direct", isOn: $viewModelBinding.settingModel.directEnabled)
          .onChange(of: viewModel.settingModel.directEnabled) {
            viewModel.directButtonChanged($1)
          }
        Toggle("Local", isOn: $viewModelBinding.settingModel.localEnabled)
          .onChange(of: viewModel.settingModel.localEnabled) {
            viewModel.localButtonChanged($1)
          }
        Toggle("Smartlink", isOn: $viewModelBinding.settingModel.smartlinkEnabled)
          .onChange(of: viewModel.settingModel.smartlinkEnabled) {
            viewModel.smartlinkButtonChanged($1)
          }
       }
      .frame(width: 180)
      .disabled(viewModel.isConnected)
      
      Spacer()
      
      Picker("Dax", selection: $viewModelBinding.settingModel.daxSelection) {
        ForEach(DaxChoice.allCases, id: \.self) {
          Text($0.rawValue.capitalized).tag($0)
        }
      }
      .frame(width: 180)
      .disabled(viewModel.settingModel.isGui == false)

      .onChange(of: viewModel.settingModel.daxSelection) {
        viewModel.daxSelectionChanged($0, $1)
      }
      
      Spacer()
      
      HStack(spacing: 10) {
        Toggle("Rx Audio", isOn: $viewModelBinding.settingModel.remoteRxAudioEnabled)
          .disabled(viewModel.settingModel.isGui == false)
        
          .onChange(of: viewModel.settingModel.remoteRxAudioEnabled) { _, _ in
            viewModel.remoteRxAudioEnabledButtonChanged()
          }
        
        Toggle("Tx Audio", isOn: $viewModelBinding.settingModel.remoteTxAudioEnabled)
          .disabled(viewModel.settingModel.isGui == false)

          .onChange(of: viewModel.settingModel.remoteTxAudioEnabled) { _, _ in
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
