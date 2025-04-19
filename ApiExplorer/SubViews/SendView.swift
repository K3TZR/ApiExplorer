//
//  SendView.swift
//  ApiExplorer/Subviews
//
//  Created by Douglas Adams on 10/06/24.
//

import SwiftUI

#if os(iOS)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

// ----------------------------------------------------------------------------
// MARK: - View

public struct SendView: View {
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(SettingsModel.self) private var settings

  public var body: some View {
    @Bindable var settings = settings

    HStack {
      ButtonX(title: "Send") { viewModel.sendButtonTapped() }
      .keyboardShortcut(.defaultAction)
      .disabled(viewModel.isConnected == false)
      
      HStack(spacing: 0) {
        Image(systemName: "x.circle").font(.title2)
          .onTapGesture {
            viewModel.clearTextButtonTapped()
          }
          .help("Clear the command field")
        
        TextField("Command to send", text: $settings.commandToSend)
        #if os(iOS)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled(true)
          .onSubmit {
              hideKeyboard()
          }
        #endif
      }
  
      ToggleX(title: "Clear on Send", isOn: $settings.clearOnSend)
        .toggleStyle(.button)
        .help("Clear the field after sending a command")
      
      #if os(iOS)
      ButtonX(title: "Discovery") { viewModel.activeSheet = .discovery }
      ButtonX(title: "Gui Clients") { viewModel.activeSheet = .guiClients }
      ButtonX(title: "Settings") { viewModel.activeSheet = .settings }
      #endif
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  SendView()
    .environment(ViewModel())
    .environment(SettingsModel())
  
    .frame(width: 1000)
}
