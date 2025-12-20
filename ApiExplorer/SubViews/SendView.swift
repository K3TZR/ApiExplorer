//
//  SendView.swift
//  ApiExplorer/Subviews
//
//  Created by Douglas Adams on 10/06/24.
//

import SwiftUI
import ApiPackage

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

  public var body: some View {
    @Bindable var settings = viewModel.settings

    HStack {
      Button("Send") { viewModel.sendButtonTapped() }
        .keyboardShortcut(.defaultAction)
        .disabled(viewModel.isConnected == false)
      
      HStack {
        ClearableTextField(placeholder: "Command to send", text: $settings.commandToSend)
        Spacer()
        //        Button("Clear on Send") {viewModel.settings.clearOnSend.toggle()}
        Toggle("Clear on Send", isOn: $settings.clearOnSend)
          .toggleStyle(CustomToggleStyle())
      }
    }
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview {
  SendView()
    .environment(ViewModel(SettingsModel()))
  
    .frame(width: 1000)
}


public struct ClearableTextField: View {
  var placeholder: String = ""
  @Binding var text: String
  
  public var body: some View {
    ZStack(alignment: .trailing) {
      TextField(placeholder, text: $text)
        .textFieldStyle(.roundedBorder)
#if os(iOS)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .keyboardType(.asciiCapable)
        .onSubmit {
          hideKeyboard()
        }
#endif
      
      if !text.isEmpty {
        Button(action: { text = "" }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.gray)
        }
        .buttonStyle(.plain)
        .padding(.trailing, 8)
      }
    }
  }
}
