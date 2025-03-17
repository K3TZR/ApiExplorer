//
//  SendView.swift
//  ApiExplorer/Subviews
//
//  Created by Douglas Adams on 10/06/24.
//

import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View

public struct SendView: View {
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(SettingsModel.self) private var settings

  public var body: some View {
    @Bindable var settings = settings

    HStack {
      Button("Send") { viewModel.sendButtonTapped() }
        .frame(width: 60, alignment: .leading)
      .keyboardShortcut(.defaultAction)
      .disabled(viewModel.isConnected == false)
      
      HStack(spacing: 0) {
        Image(systemName: "x.circle").font(.title2)
          .onTapGesture {
            viewModel.clearTextButtonTapped()
          }
          .help("Clear the command field")
        
//        Stepper("", onIncrement: {
//          viewModel.previousStepperTapped()
//        }, onDecrement: {
//          viewModel.nextStepperTapped()
//        })
//        .help("Load previously sent commands")
        
        TextField("Command to send", text: $settings.commandToSend)
      }
  
      Toggle("Clear on Send", isOn: $settings.clearOnSend)
        .toggleStyle(.button)
        .help("Clear the field after sending a command")
      
      #if os(iOS)
      Button("Discovery") { viewModel.activeSheet = .discovery }
      Button("Gui Clients") { viewModel.activeSheet = .guiClients }
      Button("Settings") { viewModel.activeSheet = .settings }
      #endif
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  SendView()
    .environment(ViewModel())
    .environment(SettingsModel.shared)
  
    .frame(width: 1000)
}
