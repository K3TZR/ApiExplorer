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
    return !(viewModel.settings.directEnabled || viewModel.settings.localEnabled || viewModel.settings.smartlinkEnabled)
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
      
      Toggle("Gui", isOn: $viewModelBinding.settings.isGui)
        .frame(width: 60, alignment: .leading)

      // Connection types
      ControlGroup {
        Toggle("Direct", isOn: $viewModelBinding.settings.directEnabled)
          .onChange(of: viewModel.settings.directEnabled) {
            viewModel.directButtonChanged($1)
          }
        Toggle("Local", isOn: $viewModelBinding.settings.localEnabled)
          .onChange(of: viewModel.settings.localEnabled) {
            viewModel.localButtonChanged($1)
          }
        Toggle("Smartlink", isOn: $viewModelBinding.settings.smartlinkEnabled)
          .onChange(of: viewModel.settings.smartlinkEnabled) {
            viewModel.smartlinkButtonChanged($1)
          }
       }
      .frame(width: 180)
      .disabled(viewModel.isConnected)
      
      Spacer()
      
      Picker("Dax", selection: $viewModelBinding.settings.daxSelection) {
        ForEach(DaxChoice.allCases, id: \.self) {
          Text($0.rawValue.capitalized).tag($0)
        }
      }
      .frame(width: 180)
      .disabled(viewModel.settings.isGui == false)

      .onChange(of: viewModel.settings.daxSelection) {
        viewModel.daxSelectionChanged($0, $1)
      }
      
      Spacer()
      
      HStack(spacing: 10) {
        Toggle("Rx Audio", isOn: $viewModelBinding.settings.remoteRxAudioEnabled)
          .disabled(viewModel.settings.isGui == false)
        
          .onChange(of: viewModel.settings.remoteRxAudioEnabled) { _, _ in
            viewModel.remoteRxAudioEnabledButtonChanged()
          }
        
        Toggle("Tx Audio", isOn: $viewModelBinding.settings.remoteTxAudioEnabled)
          .disabled(viewModel.settings.isGui == false)

          .onChange(of: viewModel.settings.remoteTxAudioEnabled) { _, _ in
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
