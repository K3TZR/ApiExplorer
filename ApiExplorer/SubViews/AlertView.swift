//
//  AlertView.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 6/12/25.
//

import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View

public struct AlertView: View {
  let simpleAlert: Bool
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss
  
  public var body: some View {
    @Bindable var settings = viewModel.settings
    
    VStack(alignment: .center, spacing: 20) {
      Text(viewModel.alertInfo?.title ?? "An Unknown event has been logged")
        .font(.headline)
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)

      
      Text(viewModel.alertInfo?.message ?? "Something BAD happened")
        .font(.body)
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)

      // Checkboxes
      HStack {
        if !simpleAlert {
          Toggle("Error", isOn: $settings.alertOnError)
//            .toggleStyle(.checkbox)
          
          Toggle("Warning", isOn: $settings.alertOnWarning)
//            .toggleStyle(.checkbox)
        }
        
        Spacer()
          
        Button("OK") { dismiss() }
          .keyboardShortcut(.defaultAction)
        }
      }
    .padding()
    .frame(minWidth: 300)
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview

#Preview("Normal)") {
  AlertView(simpleAlert: false)
    .environment(ViewModel(SettingsModel()))
}

#Preview("Simple") {
  AlertView(simpleAlert: true)
    .environment(ViewModel(SettingsModel()))
}
