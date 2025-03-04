//
//  SendView.swift
//  ApiViewer/Subviews
//
//  Created by Douglas Adams on 10/06/24.
//

import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View

public struct SendView: View {
  @Environment(ViewModel.self) private var viewModel

  public var body: some View {
    @Bindable var viewModelBinding = viewModel

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
        
        Stepper("", onIncrement: {
          viewModel.previousStepperTapped()
        }, onDecrement: {
          viewModel.nextStepperTapped()
        })
        .help("Load previously sent commands")
        
        TextField("Command to send", text: $viewModelBinding.settings.commandToSend)
      }
  
      Toggle("Clear on Send", isOn: $viewModelBinding.settings.clearOnSend)
        .toggleStyle(.button)
        .help("Clear the field after sending a command")
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
    SendView()
      .environment(ViewModel())
  .frame(minWidth: 1250, maxWidth: .infinity)
}

