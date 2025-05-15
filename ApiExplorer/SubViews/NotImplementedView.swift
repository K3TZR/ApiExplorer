//
//  NotImplementedView.swift
//  ApiExplorer
//
//  Created by Douglas Adams on 3/1/25.
//

import SwiftUI

// ----------------------------------------------------------------------------
// MARK: - View(s)

public struct NotImplementedView: View {
  
  @Environment(ViewModel.self) var viewModel
  @Environment(\.dismiss) var dismiss
  
  public var body: some View {
    
    VStack(spacing: 20) {
      Spacer()
      Text("Not Implemented (yet)").font(.title)
      Spacer()
      
      Divider()
        .frame(height: 2)
        .background(Color.gray)

      HStack {
        Spacer()
        Button("Cancel") {
          dismiss()
        }
        .keyboardShortcut(.cancelAction)
      }
    }
    .frame(width: 250, height: 200)
    .padding()
  }
}

// ----------------------------------------------------------------------------
// MARK: - Preview(s)

#Preview() {
  NotImplementedView()
    .environment(ViewModel(SettingsModel()))
}
