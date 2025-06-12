//
//  AlertView.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 6/12/25.
//

import SwiftUI

public struct AlertView: View {
  
  @Environment(ViewModel.self) private var viewModel
  @Environment(\.dismiss) var dismiss
  
  public var body: some View {
    @Bindable var settings = viewModel.settings
    
    VStack(alignment: .center, spacing: 20) {
      Text(viewModel.alertInfo?.title ?? "AN Unknown event has been logged")
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
        Toggle("Error", isOn: $settings.alertOnError)
          .toggleStyle(.checkbox)
        
        Toggle("Warning", isOn: $settings.alertOnWarning)
          .toggleStyle(.checkbox)
        
        Spacer()
          
        Button("OK") { dismiss() }
          .keyboardShortcut(.defaultAction)
        }
      }
    .padding()
    .frame(minWidth: 300)
  }
}

#Preview {
  AlertView()
}
